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
// import 'package:flutter/material.dart';
// import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
// class DatePickerUtil {
//   /// 显示日期选择器并返回选中的日期
//   static Future<DateTime?> selectDate({
//     required BuildContext context,
//     required DateTime initialDate,
//     DateTime? firstDate,
//     DateTime? lastDate,
//   }) async {
//     DatePicker.showDatePicker(
//               context,
//               pickerTheme: DateTimePickerTheme(
//                 showTitle: true,
//                 confirm: Text('确定', style: TextStyle(color: Colors.blue)),
//                 cancel: Text('取消', style: TextStyle(color: Colors.red)),
//               ),
//               minDateTime: DateTime(2000),
//               maxDateTime: DateTime(2100),
//               initialDateTime: DateTime.now(),
//               dateFormat: 'yyyy年',
//               locale: DateTimePickerLocale.zh_cn,
//               onConfirm: (dateTime, List<int> index) {
//                 print('选择的时间：$dateTime');
//                 // picked = dateTime;
//               },
//             );
//     // return picked;
//   }
// }