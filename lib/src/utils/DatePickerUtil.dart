import 'package:flutter/material.dart';

class DatePickerUtil {
  /// 显示日期选择器并返回选中的日期
  static Future<DateTime?> selectDate({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
    );
    return picked;
  }
}