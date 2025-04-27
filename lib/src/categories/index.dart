import 'package:flutter/material.dart';
// import 'package:myapp/src/utils/BillListData.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/db.dart';
// import 'package:myapp/src/utils/DatePickerUtil.dart';
import 'package:myapp/src/utils/app_colors.dart';
// import 'package:myapp/src/categories/index.dart';
import 'dart:math';
import 'package:myapp/src/state/categories.dart';
import 'package:myapp/src/state/refresh.dart';
String getRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random rand = Random.secure();  // 用 secure() 版本随机性更好
  return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
}



class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  void refresh() {
    Provider.of<BillCategories>(context).fetchBillTables();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: [
          HeaderCard(),
          Expanded(
            // child: Text("123"),
            child: CategoriesCard(),
          ),
        ],
      ),
    );
  }
}


class CategoriesCard extends StatefulWidget {
  const CategoriesCard({super.key});
  @override
  State<CategoriesCard> createState() => _CategoriesCardState();
}

class _CategoriesCardState extends State<CategoriesCard> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.offset > 100 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 100 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billInfo = Provider.of<BillCategories>(context);
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => billInfo.fetchBillTables(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // <=== 这一行！
            controller: _scrollController,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return CategoriesItem(
                      billInfoItem: billInfo.billCategoryList[index],
                      // onTap: () {
                      //   // 可以添加点击月份跳转到日详情页面的逻辑
                      // },
                    );
                  },
                  childCount: billInfo.billCategoryList.length,
                ),
              ),
            ],
          ),
        ),
        if (_showScrollToTop)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.background,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class HeaderCard extends StatefulWidget {
  const HeaderCard({super.key});
  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '测试',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: AppColors.primary),
                onPressed: () {
                  // 调用增加账单的功能
                  _showAddBillDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Widget _buildAmountCard(String title, double amount, Color color) {
void _showAddBillDialog(BuildContext context) {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('新增账单表'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '账单名称',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '备注',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // 取消
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final String name = amountController.text;
              final String remark = descriptionController.text;
              String tableName = "bill_";
              tableName += DateTime.now().millisecondsSinceEpoch.toString();
              tableName += getRandomString(8);
              print(tableName);
              createTable(tableName, name, remark);
              // 使用正确的 BuildContext 调用 Provider
              Provider.of<BillCategories>(context, listen: false).fetchBillTables();
              Navigator.of(dialogContext).pop(); // 关闭对话框
            },
            child: const Text('保存'),
          ),
        ],
      );
    },
  );
}
}


class CategoriesItem extends StatefulWidget {
  final BillCategory billInfoItem;
  const CategoriesItem({
    super.key,
    required this.billInfoItem,
  });

  @override
  State<CategoriesItem> createState() => _CategoriesItemState();
}

class _CategoriesItemState extends State<CategoriesItem> {
  late Future<List<double>> result;

  @override
  void initState() {
    super.initState();
    result = loadData(); // 延迟加载数据
  }

  Future<List<double>> loadData() async {
    return await getSumBills(tableName: widget.billInfoItem.tablename); // 获取账单数据
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: result,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 显示加载状态
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // 错误处理
          return Text('加载失败: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // 处理没有数据的情况
          return Text('没有数据');
        } else {
          final income = snapshot.data![1];
          final expense = snapshot.data![0];
          final balance = income - expense;

          return Card(
            color: AppColors.expandedCardBackground,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border, width: 1),
            ),
            child: InkWell(
              onTap: () {
                // 切换账单
                RefreshState refresh = RefreshState();
                Provider.of<BillCategories>(context, listen: false).setTable(
                  widget.billInfoItem.tablename,
                  widget.billInfoItem.name,
                );
                refresh.getState(context);
                refresh.refreshBills();
                print('切换到账单表: ${widget.billInfoItem.tablename}');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.billInfoItem.name, // 修正了这里的字段引用
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildAmountIndicator('收入', income, AppColors.income),
                        _buildAmountIndicator('支出', expense, AppColors.expense),
                        _buildAmountIndicator('结余', balance,
                            balance >= 0 ? AppColors.balancePositive : AppColors.balanceNegative),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: expense + income > 0 ? income / (expense + income) : 1,
                      backgroundColor: AppColors.progressBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.progressValue),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAmountIndicator(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
