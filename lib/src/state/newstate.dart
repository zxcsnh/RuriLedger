import 'package:flutter/material.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/DatePickerUtil.dart';
class NewBillData extends ChangeNotifier {
  late final Bill _bill;

  NewBillData({Bill? initialBill})
      : _bill = initialBill ??
            Bill(
              type: 'pay',
              money: 0.00,
              date: DateTime.now(),
              savetime: DateTime.now(),
              usefor: 'other',
              source: '手动记账',
            );

  Bill get bill => _bill;
  
  void selectDate(BuildContext context) async {
    DateTime? selectedDate = await DatePickerUtil.selectDate(
      context: context,
      initialDate: _bill.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != _bill.date) {
      _bill.date = selectedDate;
      notifyListeners();
    }
  }
  
  void setType(String type) {
    _bill.type = type;
    notifyListeners();
  }
  
  void setUsefor(String usefor) {
    _bill.usefor = usefor;
    notifyListeners();
  }
  
  void setMoney(double money) {
    _bill.money = money;
    notifyListeners();
  }
  
  void setRemark(String remark) {
    _bill.remark = remark;
    notifyListeners();
  }
  
  void setSaveTime() {
    _bill.savetime = DateTime.now();
    notifyListeners();
  }
}