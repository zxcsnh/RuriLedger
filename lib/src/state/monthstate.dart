import 'package:flutter/material.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/DatePickerUtil.dart';
import 'package:myapp/src/utils/db.dart';
class MonthBillList extends ChangeNotifier {
  List<BillSummary> _bills = [];
  DateTime _currentDate = DateTime.now();

  List<BillSummary> get bills => _bills;
  DateTime get currentDate => _currentDate;

  List<MapEntry<String, List<BillSummary>>> _billsByMonth = [];
  List<MapEntry<String, List<BillSummary>>> get billsByMonth => _billsByMonth;

  double totalPay = 0.0;
  double totalIncome = 0.0;

  Future<void> fetchBills({String tableName = "bills"}) async {
    print('获取数据');
    _bills = await getMonthBills(_currentDate, tableName: tableName);
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