class Bill {
  int? id;
  String type; // 'income' or 'pay'
  double money;
  DateTime date;
  DateTime savetime;
  String usefor;
  String source;
  String? remark;
  bool isExpanded; // 添加展开状态

  @override
  String toString() {
    return 'Bill(id: $id, type: $type, money: $money, date: $date, usefor: $usefor, source: $source, remark: $remark)';
  }

  Bill({
    required this.type,
    required this.money,
    required this.date,
    required this.savetime,
    required this.usefor,
    required this.source,
    this.id,
    this.remark,
    this.isExpanded = false, // 默认不展开
  });

  // 将 Bill 对象转换为 Map<String, Object?>
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type,
      'money': money,
      'date': date.toIso8601String(), // 转换为 ISO 8601 格式的字符串
      'savetime': savetime.toIso8601String(),
      'usefor': usefor,
      'source': source,
      'remark': remark,
    };
  }
  Map<String, Object?> toInsertMap() {
    return {
      'type': type,
      'money': money,
      'date': date.toIso8601String(), // 转换为 ISO 8601 格式的字符串
      'savetime': savetime.toIso8601String(),
      'usefor': usefor,
      'source': source,
      'remark': remark,
    };
  }
  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as int, // 确保 id 是 String 类型，提供默认值
      type: map['type'] as String,
      money: map['money'] as double,
      date: DateTime.parse(map['date'] as String),
      savetime: DateTime.parse(map['savetime'] as String),
      usefor: map['usefor'] as String,
      source: map['source'] as String,
      remark: map['remark'] != null ? map['remark'] as String : null, // 检查 remark 是否为 null
    );
  }
}
class BillSummary{
  String month;
  String type; // 'income' or 'pay'
  double money;
  String usefor;
  // String source;

  BillSummary({
    required this.month,
    required this.type,
    required this.money,
    required this.usefor,
    // required this.source,
  });
  factory BillSummary.fromMap(Map<String, dynamic> map) {
    return BillSummary(
      month: map['month'] as String,
      type: map['type'] as String,
      money: map['money'] as double,
      usefor: map['usefor'] as String,
      // source: map['source'] as String,
    );
  }
}