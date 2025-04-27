import 'package:flutter/material.dart';
import 'package:myapp/src/utils/BillListData.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/new/index.dart';
// import 'package:myapp/src/month/index.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/db.dart';
// import 'package:myapp/src/utils/DatePickerUtil.dart';
import 'package:myapp/src/utils/app_colors.dart';
// import 'package:myapp/src/categories/index.dart';
import 'package:myapp/src/state/daystate.dart';
import 'package:myapp/src/state/categories.dart';
// import 'package:myapp/src/state/monthstate.dart';
import 'package:myapp/src/state/refresh.dart';
class DayPage extends StatefulWidget {
  const DayPage({super.key});
  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void refresh() {
    String tempTableName = Provider.of<BillCategories>(context).tablename;
    // Provider.of<BillList>(context, listen: false).fetchBills(tableName: tempTableName);
    // Provider.of<MonthlyBillSummary>(context, listen: false).fetchBills(tableName: tempTableName);
    Provider.of<DayBillList>(context).fetchBills(tableName: tempTableName);
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
    final billList = Provider.of<DayBillList>(context);
    final income = billList.bills
        .where((bill) => bill.type == "income")
        .map((bill) => bill.money)
        .fold(0.0, (a, b) => a + b);
    final expense = billList.bills
        .where((bill) => bill.type == "pay")
        .map((bill) => bill.money)
        .fold(0.0, (a, b) => a + b);

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
                      '${billList.currentDate.year}年${billList.currentDate.month}月${billList.currentDate.day}日',
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
                  '${billList.bills.length}笔',
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
              _buildAmountCard('收入', income, Colors.green),
              _buildAmountCard('支出', expense, Colors.red),
              _buildAmountCard('结余', income - expense, Colors.blue),
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
          style: TextStyle(
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
    final billInfo = Provider.of<BillCategories>(context);
    final billList = Provider.of<DayBillList>(context);

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
                    final bill = billList.bills[index];
                    return BillItem(bill: bill);
                  },
                  childCount: billList.bills.length,
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
              backgroundColor: AppColors.fabBackground,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward, color: AppColors.iconSelected),
            ),
          ),
      ],
    );
  }
}

class BillItem extends StatefulWidget {
  final Bill bill;

  const BillItem({super.key, required this.bill});

  @override
  State<BillItem> createState() => _BillItemState();
}

class _BillItemState extends State<BillItem> {
  @override
  Widget build(BuildContext context) {
    final icon = useforToIcon[widget.bill.usefor] ?? Icons.monetization_on;
    final name = useforToName[widget.bill.usefor] ?? widget.bill.usefor;
    final isIncome = widget.bill.type == 'income';

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
        onTap: () {
          setState(() {
            widget.bill.isExpanded = !widget.bill.isExpanded;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? AppColors.income.withValues(alpha: 0.1)
                          : AppColors.expense.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isIncome ? AppColors.income : AppColors.expense,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.bill.remark?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.bill.remark!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}${widget.bill.money.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.bill.isExpanded) _buildExpandedContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            '来源: ${widget.bill.source}',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '时间: ${widget.bill.date.toLocal().toString().substring(0, 16)}',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.buttonDanger,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: _showDeleteDialog,
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18),
                    SizedBox(width: 4),
                    Text('删除'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.buttonPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: _navigateToEditPage,
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 4),
                    Text('编辑'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    RefreshState refresh = RefreshState();
    refresh.getState(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条账单记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
            },
            child: const Text('确认', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        deleteBill(widget.bill.id!,tableName: refresh.tableName);
        refresh.refreshBills();
      }
    });
  }

  void _navigateToEditPage() {
    RefreshState refresh = RefreshState();
    refresh.getState(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPage(initialBill: widget.bill, tableName: refresh.tableName, name: refresh.name,),
      ),
    ).then((value) {
      if (value == true) {
        refresh.refreshBills();
      }
    });
  }
}
