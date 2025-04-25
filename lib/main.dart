import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/day/index.dart';
import 'package:myapp/src/utils/db.dart';
import 'package:myapp/src/new/index.dart';
import 'package:myapp/src/month/index.dart';
import 'package:myapp/src/utils/BillListData.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化数据库
  DatabaseHelper().database.then((db) {
    print('Database initialized: $db');
  }).catchError((error) {
    print('Error initializing database: $error');
  });
  generateMappings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 8,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BillList()..fetchBills()),
          ChangeNotifierProvider(create: (_) => MonthlyBillSummary()..fetchBills()),
        ],
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  Future<bool> _handlePop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出？', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('您确定要退出应用吗？'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
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
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final allowed = await _handlePop();
        if (allowed && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // backgroundColor: Colors.blue,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            DayPage(),
            Placeholder(), // 这个不会被显示，因为点击会导航到NewPage
            MonthPage(),
          ],
        ),
        bottomNavigationBar: Container(
          // color: Colors.red,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.blue[50],
            // fixedColor: Colors.red,
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewPage()),
                ).then((value) {
                  if (value != null && value == true) {
                    Provider.of<BillList>(context, listen: false).fetchBills();
                    Provider.of<MonthlyBillSummary>(context, listen: false).fetchBills();
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
                label: '日账',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                activeIcon: Icon(Icons.add_circle),
                label: '记账',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: '月账',
              ),
            ],
          ),
        ),
      ),
    );
  }
}