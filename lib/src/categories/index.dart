import 'package:flutter/material.dart';
// import 'package:myapp/src/utils/BillListData.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/db.dart';
// import 'package:myapp/src/utils/DatePickerUtil.dart';
import 'package:myapp/src/utils/appColors.dart';
// import 'package:myapp/src/categories/index.dart';
import 'dart:math';
import 'package:myapp/src/state/categories.dart';
import 'package:myapp/src/state/refresh.dart';
// import 'package:myapp/src/utils/marqueeWidget.dart';
import 'package:marquee/marquee.dart';
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
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pageBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '当前账单',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Selector<BillCategories, String>(
                    selector: (context, model) => model.name,
                    builder: (context, name, child) {
                      return Card(
                        color: AppColors.cardBackground,
                        elevation: 4, // 提升卡片的阴影效果
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // 增加圆角半径
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 添加内边距
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.book, // 添加图标
                                color: AppColors.iconSelected,
                                size: 16,
                              ),
                              const SizedBox(width: 8), // 图标与文字之间的间距
                              SizedBox(
                                width: 80,
                                height: 20,
                                child: Marquee(
                                  text: name,
                                  style: const TextStyle(
                                    fontSize: 16, // 调整字体大小
                                    fontWeight: FontWeight.w600, // 使用半粗体
                                    color: AppColors.textPrimary,
                                  ),
                                  blankSpace: 50.0,
                                  velocity: 50.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary.withAlpha(50), // 背景颜色
                  shape: RoundedRectangleBorder( // 圆角
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: AppColors.primary),
                    const Text(
                      '新增账单',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
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
          backgroundColor: AppColors.dialogBackground,
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
              style: TextButton.styleFrom(
                side: BorderSide(color: AppColors.buttonTabInactive),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 取消
              },
              child: const Text(
                '取消',
                style: TextStyle(color: AppColors.buttonTabInactive)
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(color: AppColors.buttonTabActive),
              ),
              onPressed: () {
                final String name = amountController.text;
                final String remark = descriptionController.text;
                if(name == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("账单名称不能为空")),
                  );
                  return;
                }
                String tableName = "bill_";
                tableName += DateTime.now().millisecondsSinceEpoch.toString();
                tableName += getRandomString(8);
                print(tableName);
                createTable(tableName, name, remark);
                // 使用正确的 BuildContext 调用 Provider
                Provider.of<BillCategories>(context, listen: false).fetchBillTables();
                Navigator.of(dialogContext).pop(); // 关闭对话框
              },
              child: const Text(
                '保存'
                ,style: TextStyle(color: AppColors.buttonTabActive)
              ),
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

  bool isExpanded = false; // 是否展开

  @override
  Widget build(BuildContext context) {
    final income = widget.billInfoItem.income;
    final expense = widget.billInfoItem.pay;
    final balance = income - expense;

    return Card(
      color: AppColors.expandedCardBackground,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.billInfoItem.name == Provider.of<BillCategories>(context, listen: false).name ? AppColors.borderSelected : AppColors.border, 
          width: 1
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded; // 切换展开状态
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: SingleChildScrollView( // 滚动视图
                          scrollDirection: Axis.horizontal, 
                          child: Text(
                            widget.billInfoItem.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if(widget.billInfoItem.remark != null && widget.billInfoItem.remark != "")
                        SizedBox(
                          width: 150,
                          child: SingleChildScrollView( // 滚动视图
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              '${widget.billInfoItem.remark}',
                              // "111777777777777777777777777777777777777777777",
                              style: TextStyle(color: AppColors.textHint, fontSize: 13),
                            ),
                          ),
                        )
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
            if (isExpanded) // 根据状态决定是否显示内容
              _buildExpandedContent(),
          ],
        ),
      ),
    );
  }
  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Text(
            '备注: ${widget.billInfoItem.remark}',
            maxLines: null,         // 不限制行数（可以无限换行）
            softWrap: true,         // 自动换行
            overflow: TextOverflow.visible,  // 内容超出时如何处理（比如 visible、ellipsis、fade）
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '创建时间: ${widget.billInfoItem.savetime.toLocal().toString().substring(0, 16)}',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if(widget.billInfoItem.tablename != "bills")
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.buttonDanger,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: _showDeleteDialog,
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18),
                      SizedBox(width: 4),
                      Text('删除'),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.buttonPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: (){
                  _updateBillDialog(context);
                },
                child: const Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 4),
                    Text('编辑'),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.buttonThirdary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () {
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
                child: const Row(
                  children: [
                    Icon(Icons.arrow_forward_ios, size: 18),
                    SizedBox(width: 4),
                    Text('切换账单'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() async {
    if (!mounted) return; // 前置检查

    final refresh = Provider.of<BillCategories>(context, listen: false);

    // 第一次确认
    final firstConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text('确认删除'),
        content: const Text('确定要删除这个账单吗？'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              side: BorderSide(color: AppColors.buttonTabActive),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消', style: TextStyle(color: AppColors.buttonTabActive)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              side: BorderSide(color: AppColors.buttonDanger),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认', style: TextStyle(color: AppColors.buttonDanger)),
          ),
        ],
      ),
    );

    if (firstConfirmed != true || !mounted) return;

    // 第二次确认
    final secondConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: const Text('再次确认'),
        content: const Text('删除后将无法恢复，请再次确认！'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              side: BorderSide(color: AppColors.buttonTabActive),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消', style: TextStyle(color: AppColors.buttonTabActive)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              side: BorderSide(color: AppColors.buttonDanger),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认删除', style: TextStyle(color: AppColors.buttonDanger)),
          ),
        ],
      ),
    );

    if (secondConfirmed == true && mounted) {
      // print('删除账单: ${widget.billInfoItem.tablename}');
      // 实际删除操作
      await deleteTable(widget.billInfoItem.tablename);
      // await deleteBill(widget.billInfoItem.id!, tableName: widget.billInfoItem.tablename);
      refresh.fetchBillTables();
    }

  }

  void _updateBillDialog(BuildContext context) {
    final TextEditingController amountController = TextEditingController(text: widget.billInfoItem.name);
    final TextEditingController descriptionController = TextEditingController(text: widget.billInfoItem.remark);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.dialogBackground,
          title: const Text('编辑账单表'),
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
              style: TextButton.styleFrom(
                side: BorderSide(
                  color: AppColors.buttonTabActive
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 取消
              },
              child: const Text(
                '取消',
                style: TextStyle(color: AppColors.buttonTabActive)
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                side: BorderSide(
                  color: AppColors.buttonTabActive
                ),
              ),
              onPressed: () {
                print(widget.billInfoItem.tablename);
                final String name = amountController.text;
                if(name == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("账单名称不能为空")),
                  );
                  return;
                }
                final String remark = descriptionController.text;
                updateTable(widget.billInfoItem.tablename, name, remark);
                Provider.of<BillCategories>(context, listen: false).fetchBillTables();
                Navigator.of(dialogContext).pop(); // 关闭对话框
              },
              child: const Text(
                '保存',
                style: TextStyle(color: AppColors.buttonTabActive)
              ),
            ),
          ],
        );
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
