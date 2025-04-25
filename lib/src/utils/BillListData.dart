import 'package:flutter/material.dart';

Map<String, String> useforToName = {};
Map<String, IconData> useforToIcon = {};

void generateMappings() {
  for (var category in billListData) {
    for (var item in category['items']) {
      for (var subItem in item['list']) {
        useforToName[subItem['usefor']] = subItem['name'];
        useforToIcon[subItem['usefor']] = subItem['icon'];
      }
    }
  }
}

List<Map<String, dynamic>> billListData = [
  {
    'type': 'pay',
    'items': [
      {
        'type': 'foods',
        'name': '餐饮',
        'icon': Icons.restaurant,
        'list': [
          {'usefor': 'food', 'name': '餐费', 'icon': Icons.restaurant, 'type': 'pay'},
          {'usefor': 'drinks', 'name': '酒水饮料', 'icon': Icons.local_cafe, 'type': 'pay'},
          {'usefor': 'dessert', 'name': '甜品零食', 'icon': Icons.cake, 'type': 'pay'},
        ],
      },
      {
        'type': 'taxi',
        'name': '出行交通',
        'icon': Icons.local_taxi,
        'list': [
          {'usefor': 'taxi', 'name': '打车租车', 'icon': Icons.directions_car, 'type': 'pay'},
          {'usefor': 'longdistance', 'name': '旅行票费', 'icon': Icons.airplanemode_active, 'type': 'pay'},
        ],
      },
      {
        'type': 'recreation',
        'name': '休闲娱乐',
        'icon': Icons.videogame_asset,
        'list': [
          {'usefor': 'bodybuilding', 'name': '运动健身', 'icon': Icons.directions_bike, 'type': 'pay'},
          {'usefor': 'game', 'name': '休闲玩乐', 'icon': Icons.videogame_asset, 'type': 'pay'},
          {'usefor': 'audio', 'name': '媒体影音', 'icon': Icons.music_note, 'type': 'pay'},
          {'usefor': 'travel', 'name': '旅游度假', 'icon': Icons.public, 'type': 'pay'},
        ],
      },
      {
        'type': 'daily',
        'name': '日常支出',
        'icon': Icons.shopping_cart,
        'list': [
          {'usefor': 'clothes', 'name': '衣服裤子', 'icon': Icons.checkroom, 'type': 'pay'},
          {'usefor': 'bag', 'name': '鞋帽包包', 'icon': Icons.shopping_bag, 'type': 'pay'},
          {'usefor': 'book', 'name': '知识学习', 'icon': Icons.book, 'type': 'pay'},
          {'usefor': 'promote', 'name': '能力提升', 'icon': Icons.book, 'type': 'pay'},
          {'usefor': 'home', 'name': '家装布置', 'icon': Icons.home, 'type': 'pay'},
        ],
      },
      {
        'type': 'other',
        'name': '其他支出',
        'icon': Icons.settings,
        'list': [
          {'usefor': 'community', 'name': '社区缴费', 'icon': Icons.people, 'type': 'pay'},
          {'usefor': 'otherPay', 'name': '其他支出', 'icon': Icons.help_outline, 'type': 'pay'},
        ],
      },
    ],
  },
  {
    'type': 'income',
    'items': [
      {
        'type': 'professional',
        'name': '日常收入',
        'icon': Icons.work,
        'list': [
          {'usefor': 'salary', 'name': '工资', 'icon': Icons.money, 'type': 'income'},
          {'usefor': 'overtimepay', 'name': '加班', 'icon': Icons.access_time, 'type': 'income'},
          {'usefor': 'bonus', 'name': '奖金', 'icon': Icons.card_giftcard, 'type': 'income'},
        ],
      },
      {
        'type': 'other',
        'name': '其他收入',
        'icon': Icons.credit_card,
        'list': [
          {'usefor': 'financial', 'name': '理财收入', 'icon': Icons.account_balance_wallet, 'type': 'income'},
          {'usefor': 'cashgift', 'name': '礼金收入', 'icon': Icons.card_giftcard, 'type': 'income'},
          {'usefor': 'otherIncome', 'name': '其他收入', 'icon': Icons.help_outline, 'type': 'income'},
        ],
      },
    ],
  },
];

