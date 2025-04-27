import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/state/daystate.dart';
import 'package:myapp/src/state/monthstate.dart';
import 'package:myapp/src/state/categories.dart';
import 'package:myapp/src/home/index.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh')],
      theme: AppTheme.lightTheme,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BillCategories()..fetchBillTables()),
          ChangeNotifierProvider(create: (_) => DayBillList()..fetchBills(tableName: 'bills')),
          ChangeNotifierProvider(create: (_) => MonthBillList()..fetchBills(tableName: 'bills')),
        ],
        child: const MyHomePage(), // 使用拆分后的HomePage
      ),
    );
  }
}