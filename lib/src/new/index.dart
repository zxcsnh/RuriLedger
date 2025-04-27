import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/db.dart';
// import 'package:myapp/src/utils/DatePickerUtil.dart';
import 'package:myapp/src/utils/BillListData.dart';
import 'package:myapp/src/utils/app_colors.dart';  // 添加这行导入
// import 'package:myapp/src/categories/index.dart';
import 'package:myapp/src/state/newstate.dart';
// import 'package:myapp/src/state/categories.dart';
class NewPage extends StatefulWidget {
  final Bill? initialBill;
  final String? tableName;
  final String? name;
  const NewPage({super.key, this.initialBill, this.tableName = 'bills', this.name = '主账单'});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  bool isSelect = true;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: isSelect ? 0 : 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => BillCategories()),
        ChangeNotifierProvider(create: (context) => NewBillData(initialBill: widget.initialBill),),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          // title: const Text('记一笔', style: TextStyle(fontWeight: FontWeight.bold)),
          // centerTitle: true,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabButton('支出', true),
                  const SizedBox(width: 16),
                  _buildTabButton('收入', false),
                  const SizedBox(width: 16),
                  Card(
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
                          Text(
                            widget.name ?? '主账单',
                            style: TextStyle(
                              fontSize: 16, // 调整字体大小
                              fontWeight: FontWeight.w600, // 使用半粗体
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildTopCard(),
            _buildRemarkInput(),
            Expanded(
              child: _buildCategoryPages(),
            ),
          ],
        ),
        floatingActionButton: _buildSaveButton(widget.tableName ?? 'bills'),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isExpense) {
    return TextButton(
      onPressed: () {
        setState(() {
          isSelect = isExpense;
          _pageController.jumpToPage(isExpense ? 0 : 1);
        });
      },
    style: TextButton.styleFrom(
      foregroundColor: isSelect == isExpense
          ? AppColors.buttonTabActive
          : AppColors.buttonTabInactive,
      side: BorderSide(
        color: isSelect == isExpense
            ? AppColors.buttonTabActive
            : AppColors.buttonTabInactive, // 边框颜色
        width: 1.5, // 边框宽度
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // 圆角
      ),
    ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelect == isExpense ? FontWeight.bold : FontWeight.normal,
          color: isSelect == isExpense ? AppColors.buttonTabActive : AppColors.buttonTabInactive,
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Card(
      color: AppColors.inputCardBackground,
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const DateSelect(),
            const VerticalDivider(thickness: 1, width: 24),
            const Expanded(child: InputMoney()),
            Text(
              '￥',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarkInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: AppColors.inputCardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: InputRemark(),
        ),
      ),
    );
  }

  Widget _buildCategoryPages() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            isSelect = index == 0;
          });
        },
        children: [
          PrimaryScrollController(
            controller: _scrollController1,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _scrollController1,
              child: BillListItem(
                billData: billListData[0]['items'],
              ),
            ),
          ),
          PrimaryScrollController(
            controller: _scrollController2,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _scrollController2,
              child: BillListItem(
                billData: billListData[1]['items'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(String tableName) {
    return Consumer<NewBillData>(
      builder: (context, billData, _) => FloatingActionButton(
        onPressed: () {
          billData.setSaveTime();
          if(billData.bill.usefor == "") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("用途不能为空")),
            );
            return;
          }
          billData.bill.money = billData.bill.money.abs();
          if(billData.bill.money == 0.00) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("请输入有效数字")),
            );
            return;
          }
          print('保存数据: ${billData.bill}');
          String tempTableName = tableName;
          print('当前表: $tempTableName');
          if (widget.initialBill != null) {
            if (billData.bill.id != null) {
              updateBill(billData.bill.id!, billData.bill, tableName: tempTableName);
            } else {
              print('Error: Bill ID is null');
            }
          } else {
            insertBill(billData.bill, tableName: tempTableName);
          }
          Navigator.pop(context, true);
        },
        backgroundColor: AppColors.fabBackground,
        elevation: 4,
        child: Icon(Icons.save, color: AppColors.fabIcon),
      ),
    );
  }

}

class BillListItem extends StatelessWidget {
  const BillListItem({super.key, required this.billData});
  final List<Map<String, dynamic>> billData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: billData.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                billData[index]['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(
                  billData[index]['list'].length,
                  (subIndex) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 60) / 4,
                      child: BillItem(
                        billItem: [billData[index]['list'][subIndex]],
                      ),
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 24, thickness: 1),
          ],
        );
      },
    );
  }
}

class BillItem extends StatelessWidget {
  final List<Map<String, dynamic>> billItem;
  const BillItem({super.key, required this.billItem});

  @override
  Widget build(BuildContext context) {
    NewBillData billData = Provider.of<NewBillData>(context);
    bool isSelected = billData.bill.usefor == billItem[0]['usefor'];
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: AppColors.pageBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.borderSelected : AppColors.borderUnselected,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          billData.setUsefor(billItem[0]['usefor']);
          billData.setType(billItem[0]['type']);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                billItem[0]['icon'],
                size: 28,
                color: isSelected ? AppColors.iconSelected : AppColors.iconUnselected,
              ),
              const SizedBox(height: 8),
              Text(
                billItem[0]['name'],
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.iconSelected : AppColors.iconUnselected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputMoney extends StatefulWidget {
  const InputMoney({super.key});

  @override
  State<InputMoney> createState() => _InputMoneyState();
}

class _InputMoneyState extends State<InputMoney> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    NewBillData billData = Provider.of<NewBillData>(context, listen: false);
    _controller = TextEditingController(
      text: billData.bill.money != 0.00
          ? billData.bill.money.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NewBillData billData = Provider.of<NewBillData>(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                hintStyle: TextStyle(fontSize: 18, color: AppColors.textHint),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              onChanged: (value) {
                billData.setMoney(double.tryParse(value) ?? 0.0);
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
class InputRemark extends StatefulWidget {
  const InputRemark({super.key});

  @override
  State<InputRemark> createState() => _InputRemarkState();
}

class _InputRemarkState extends State<InputRemark> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    NewBillData billData = Provider.of<NewBillData>(context, listen: false);
    _controller = TextEditingController(
      text: billData.bill.remark != null && billData.bill.remark != ''
          ? billData.bill.remark
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NewBillData billData = Provider.of<NewBillData>(context);

    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: '添加备注...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        hintStyle: TextStyle(fontSize: 18, color: AppColors.textHint),
      ),
      style: const TextStyle(fontSize: 14),
      onChanged: (value) {
        billData.setRemark(value);
      },
    );
  }
}

class DateSelect extends StatelessWidget {
  const DateSelect({super.key});

  @override
  Widget build(BuildContext context) {
    NewBillData billData = Provider.of<NewBillData>(context);
    
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        billData.selectDate(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 20, color: AppColors.buttonPrimary),
            const SizedBox(width: 8),
            Text(
              billData.bill.date.toLocal().toString().split(' ')[0],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: AppColors.iconUnselected),
          ],
        ),
      ),
    );
  }
}

