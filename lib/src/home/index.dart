// 主入口文件 - 记账应用
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

// 应用页面导入
import 'package:myapp/src/month/index.dart';
// import 'package:myapp/src/utils/db.dart';
import 'package:myapp/src/new/index.dart';
import 'package:myapp/src/year/index.dart';
// import 'package:myapp/src/utils/BillListData.dart';
import 'package:myapp/src/utils/appColors.dart';
import 'package:myapp/src/categories/index.dart';
import 'package:myapp/src/setting/index.dart';

// 状态管理导入
// import 'package:myapp/src/state/daystate.dart';
// import 'package:myapp/src/state/monthstate.dart';
// import 'package:myapp/src/state/categories.dart';
import 'package:myapp/src/state/refresh.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0; // 当前底部导航栏索引
  late final List stateList;
  final RefreshState refresh = RefreshState(); // 刷新状态管理
  @override
  void initState() {
    super.initState();
  }

  // 处理返回按钮事件
  Future<bool> _handlePop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出？', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('您确定要退出应用吗？'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppColors.dialogBackground,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.buttonSecondary,
              side: BorderSide(
                color: AppColors.buttonTabInactive
              ),
            ),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.buttonPrimary,
              side: BorderSide(
                color: AppColors.buttonTabActive
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 禁用系统返回按钮
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final allowed = await _handlePop();
        if (allowed && mounted) {
          SystemNavigator.pop(); // 退出应用
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: const [
              MonthPage(),
              Placeholder(),  // 占位页面（实际跳转到记账页）
              YearPage(),
              CategoriesPage(),
              Setting(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.appBarBackground,
            elevation: 8,
            selectedItemColor: AppColors.iconSelected,
            unselectedItemColor: AppColors.iconUnselected,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1) {
                // 记账按钮特殊处理
                refresh.getState(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewPage(tableName: refresh.tableName, name: refresh.name,)),
                ).then((value) {
                  // 返回后刷新数据
                  if (value != null && value == true && mounted) {
                    // 优化建议：可以考虑将这部分逻辑封装到单独的方法中
                    // 例如：_refreshBills(context);
                    refresh.refreshBills();
                    // _refreshBills(tempTableName);
                  }
                });
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '月账',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                activeIcon: Icon(Icons.add_circle),
                label: '记账',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: '年账',
              ),
              BottomNavigationBarItem(
                // 优化建议：使用更符合"其他账本"含义的图标
                icon: Icon(Icons.category_outlined),
                activeIcon: Icon(Icons.category),
                label: '其他账本',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: '设置',
              ),
            ],
          ),
        ),
      ),
    );
  }
}