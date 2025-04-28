import 'package:flutter/material.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/datePickerUtil.dart';
import 'package:myapp/src/utils/db.dart';
class DayBillList extends ChangeNotifier {
  List<Bill> _bills = [];
  DateTime _currentDate = DateTime.now();

  List<Bill> get bills => _bills;
  DateTime get currentDate => _currentDate;

  Future<void> fetchBills({String tableName = "bills"}) async {
    _bills = await getDayBills(_currentDate, tableName: tableName);
    notifyListeners();
  }

  void selectDate(BuildContext context) async {
    DateTime? selectedDate = await DatePickerUtil.selectDate(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != _currentDate) {
      changeDate(selectedDate);
    }
  }

  void changeDate(DateTime newDate) {
    _currentDate = newDate;
    fetchBills();
  }
}
