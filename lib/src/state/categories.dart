import 'package:flutter/material.dart';
import 'package:myapp/src/utils/model.dart';
// import 'package:myapp/src/utils/DatePickerUtil.dart';
import 'package:myapp/src/utils/db.dart';
class BillCategories extends ChangeNotifier {
  String _tablename = 'bills';
  String _name = '主账单';
  List<BillCategory> _billCategoryList = [];
  List<BillCategory> get billCategoryList => _billCategoryList;
  String get tablename => _tablename;
  String get name => _name;

  Future<void> fetchBillTables() async {
    _billCategoryList = await getTableInfo();
    for(var bill in _billCategoryList){
      List<double> item = await getSumBills(tableName: bill.tablename);
      bill.pay = item[0];
      bill.income = item[1];
    }
    
    notifyListeners();
  }
  void setTable(tableName,name){
    _name = name;
    _tablename = tableName;
    print(_tablename);
    print(tablename);
    notifyListeners();
  }
}
