import 'package:flutter/material.dart';
// import 'package:myapp/src/utils/BillListData.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/db.dart';
import 'package:myapp/src/utils/DatePickerUtil.dart';

class MonthlyBillSummary extends ChangeNotifier {
  List<BillSummary> _bills = [];
  DateTime _currentDate = DateTime.now();

  List<BillSummary> get bills => _bills;
  DateTime get currentDate => _currentDate;

  List<MapEntry<String, List<BillSummary>>> _billsByMonth = [];
  List<MapEntry<String, List<BillSummary>>> get billsByMonth => _billsByMonth;

  double totalPay = 0.0;
  double totalIncome = 0.0;

  Future<void> fetchBills() async {
    print('获取数据');
    _bills = await getMonthBills(_currentDate);
    // 创建月份分组 Map：1~12 => List
    Map<String, List<BillSummary>> groupedBills = {};
    totalIncome = 0.0;
    totalPay = 0.0;
    for (var bill in _bills) {
      // 添加到对应月份的 list
      groupedBills.putIfAbsent(bill.month, () => []);
      groupedBills[bill.month]!.add(bill);
      if(bill.type == 'pay') {
        totalPay += bill.money;
      } else if (bill.type == 'income') {
        totalIncome += bill.money;
      }
    }
    // 保存到类变量，比如 _billsByMonth
    _billsByMonth = groupedBills.entries.toList();;

    notifyListeners();
  }
  void selectDate(BuildContext context) async {
    DateTime? selectedDate = await DatePickerUtil.selectDate(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate.year != _currentDate.year) {
      changeDate(selectedDate);
    }
  }

  @override
  String toString() {
    return 'MonthlyBillSummary(currentMonth: $_currentDate, bills: $_bills)';
  }
  void changeDate(DateTime newDate) {
    _currentDate = newDate;
    fetchBills();
  }

}

class MonthPage extends StatefulWidget {
  const MonthPage({super.key});
  @override
  _MonthPageState createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  void refresh() {
    Provider.of<MonthlyBillSummary>(context).fetchBills();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
  @override
  Widget build(BuildContext context) {
    final billList = Provider.of<MonthlyBillSummary>(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  Icon(Icons.calendar_today, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => billList.selectDate(context),
                    child: Text(
                      '${billList.currentDate.year}年',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${billList.billsByMonth.length}个月',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAmountCard('总收入', billList.totalIncome, Colors.green),
              _buildAmountCard('总支出', billList.totalPay, Colors.red),
              _buildAmountCard('结余', billList.totalIncome - billList.totalPay, 
                  (billList.totalIncome - billList.totalPay) >= 0 ? Colors.blue : Colors.orange),
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
            color: Colors.grey[600],
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
  _BillCardState createState() => _BillCardState();
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
    final billList = Provider.of<MonthlyBillSummary>(context);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => billList.fetchBills(),
          child: CustomScrollView(
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
              backgroundColor: Colors.white,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward, color: Colors.blue[600]),
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
      color: Colors.green[50],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[200]!, width: 1),
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
                  Text(
                    '${bills.length}笔',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountIndicator('收入', income, Colors.green),
                  _buildAmountIndicator('支出', expense, Colors.red),
                  _buildAmountIndicator('结余', balance, 
                      balance >= 0 ? Colors.blue : Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: expense+income > 0 ? income / (expense+income) : 1,
                backgroundColor: Colors.red[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
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
            color: Colors.grey[600],
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
// 优化页面样式