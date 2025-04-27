import 'package:flutter/widgets.dart';
import 'package:myapp/src/state/daystate.dart';
import 'package:myapp/src/state/monthstate.dart';
import 'package:myapp/src/state/categories.dart';
import 'package:provider/provider.dart';

class RefreshState{
  List stateList = [];
  String tableName = 'bills';
  String name = '主账单';
  RefreshState();
  // 初始化状态列表
  void getState(BuildContext context) {
    tableName = Provider.of<BillCategories>(context, listen: false).tablename;
    name = Provider.of<BillCategories>(context, listen: false).name;
    stateList = [
      Provider.of<DayBillList>(context, listen: false),
      Provider.of<MonthBillList>(context, listen: false),
    ];
  }

  void refreshBills() {
    // 刷新账单数据
    for (var state in stateList) {
      state.fetchBills(tableName: tableName);
    }
  }
}