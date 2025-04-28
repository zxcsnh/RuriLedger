import 'package:flutter/material.dart';
// import 'package:myapp/src/utils/BillListData.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/utils/model.dart';
// import 'package:myapp/src/utils/db.dart';
// import 'package:myapp/src/utils/DatePickerUtil.dart';
import 'package:myapp/src/utils/appColors.dart';
// import 'package:myapp/src/categories/index.dart';
import 'package:myapp/src/state/categories.dart';
import 'package:myapp/src/state/monthstate.dart';

class MonthPage extends StatefulWidget {
  const MonthPage({super.key});
  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  void refresh() {
    String tempTableName = Provider.of<BillCategories>(context, listen: false).tablename;
    Provider.of<MonthBillList>(context).fetchBills(tableName: tempTableName);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          HeaderCard(),
          Expanded(
            child: BillCard(),
          ),
        ],
      ),
    );
  }
}

class HeaderCard extends StatelessWidget {
  const HeaderCard({super.key});
  @override
  Widget build(BuildContext context) {
    final billList = Provider.of<MonthBillList>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => billList.selectDate(context),
                    child: Text(
                      '${billList.currentDate.year}年',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${billList.billsByMonth.length}个月',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAmountCard('总收入', billList.totalIncome, AppColors.income),
              _buildAmountCard('总支出', billList.totalPay, AppColors.expense),
              _buildAmountCard('结余', billList.totalIncome - billList.totalPay, 
                  (billList.totalIncome - billList.totalPay) >= 0 
                      ? AppColors.balancePositive 
                      : AppColors.balanceNegative),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class BillCard extends StatefulWidget {
  const BillCard({super.key});
  @override
  State<BillCard> createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.offset > 100 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 100 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billList = Provider.of<MonthBillList>(context);
    final billInfo = Provider.of<BillCategories>(context);
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => billList.fetchBills(tableName: billInfo.tablename),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // <=== 这一行！
            controller: _scrollController,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final month = billList.billsByMonth[index].key;
                    final bills = billList.billsByMonth[index].value;
                    return MonthBillItem(
                      month: month, 
                      bills: bills,
                      onTap: () {
                        // 可以添加点击月份跳转到日详情页面的逻辑
                      },
                    );
                  },
                  childCount: billList.billsByMonth.length,
                ),
              ),
            ],
          ),
        ),
        if (_showScrollToTop)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.background,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class MonthBillItem extends StatelessWidget {
  final String month;
  final List<BillSummary> bills;
  final VoidCallback onTap;

  const MonthBillItem({
    super.key,
    required this.month,
    required this.bills,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final income = bills.where((b) => b.type == 'income').fold(0.0, (sum, b) => sum + b.money);
    final expense = bills.where((b) => b.type == 'pay').fold(0.0, (sum, b) => sum + b.money);
    final balance = income - expense;

    return Card(
      color: AppColors.expandedCardBackground,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$month月',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   '${bills.length}笔',
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: AppColors.textHint,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountIndicator('收入', income, AppColors.income),
                  _buildAmountIndicator('支出', expense, AppColors.expense),
                  _buildAmountIndicator('结余', balance, 
                      balance >= 0 ? AppColors.balancePositive : AppColors.balanceNegative),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: expense+income > 0 ? income / (expense+income) : 1,
                backgroundColor: AppColors.progressBackground,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.progressValue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountIndicator(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}