import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const Color primary = Colors.blue; // 主色
  static const Color primaryDark = Color(0xFF1976D2); // 深蓝
  static const Color primaryLight = Color(0xFFBBDEFB); // 浅蓝

  // 背景色
  static const Color background = Colors.white; // 全局背景色
  static const Color appBarBackground = Color(0xFFE3F2FD); // AppBar 背景
  static const Color pageBackground = Color(0xFFF5F5F5); // 页面背景
  static const Color cardBackground = Color(0xFFE3F2FD); // 卡片背景
  static const Color expandedCardBackground = Color(0xFFE8F5E9); // 展开卡片背景

  // 文本颜色
  static const Color textPrimary = Colors.black87; // 主文本
  static const Color textSecondary = Colors.grey; // 次文本
  static const Color textHint = Color(0xFF9E9E9E); // 提示文本
  
  // 输入框颜色
  static const Color inputCardBackground = Color(0xFFE8F5E9); // 输入框背景
  
  // 按钮颜色
  static const Color buttonPrimary = Colors.blue; // 主按钮
  static const Color buttonSecondary = Colors.grey; // 次按钮
  static const Color buttonThirdary = Colors.orange; // 第三按钮
  static const Color buttonDanger = Colors.red; // 危险按钮
  static const Color buttonTabActive = Colors.blue; // 激活的标签按钮
  static const Color buttonTabInactive = Colors.grey; // 未激活的标签按钮

  // 图标颜色
  static const Color iconSelected = Colors.blue; // 选中图标
  static const Color iconUnselected = Colors.grey; // 未选中图标
  static const Color iconIncome = Colors.green; // 收入图标
  static const Color iconExpense = Colors.red; // 支出图标

  // 阴影颜色
  static const Color shadow = Colors.grey; // 默认阴影
  static const Color lightShadow = Color(0x1A000000); // 浅阴影（10% 不透明度）

  // 边框颜色
  static const Color border = Color(0xFF90CAF9); // 蓝色边框
  static const Color borderLight = Color(0xFFE0E0E0); // 浅灰边框
  static const Color borderSelected = Colors.orange; // 选中边框
  static const Color borderUnselected = Color(0xFFE0E0E0); // 未选中边框

  // 分割线颜色
  static const Color divider = Color(0xFFE0E0E0); // 分割线

  // 浮动按钮颜色
  static const Color fabBackground = Colors.white; // 浮动按钮背景
  static const Color fabIcon = Colors.blue; // 浮动按钮图标

  // 交易类型颜色
  static const Color income = Colors.green; // 收入
  static const Color expense = Colors.red; // 支出
  static const Color balancePositive = Colors.blue; // 正结余
  static const Color balanceNegative = Colors.orange; // 负结余

  // 进度指示器颜色
  static const Color progressBackground = Color(0xFFFFCDD2); // 红色背景
  static const Color progressValue = Color(0xFFA5D6A7); // 绿色进度值

  // 对话框颜色
  static const Color dialogBackground = Colors.white; // 对话框背景
}