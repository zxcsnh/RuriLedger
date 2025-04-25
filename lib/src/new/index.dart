import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/utils/model.dart';
import 'package:myapp/src/utils/db.dart';
import 'package:myapp/src/utils/DatePickerUtil.dart';
import 'package:myapp/src/utils/BillListData.dart';

class NewPage extends StatefulWidget {
  final Bill? initialBill;

  const NewPage({super.key, this.initialBill});

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
    return ChangeNotifierProvider(
      create: (context) => BillData(initialBill: widget.initialBill),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[50],
          title: const Text('记一笔', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  _buildTabButton('支出', true),
                  const SizedBox(width: 16),
                  _buildTabButton('收入', false),
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
        floatingActionButton: _buildSaveButton(),
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
        foregroundColor: isSelect == isExpense ? Colors.blue : Colors.grey,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelect == isExpense ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTopCard() {
    return Card(
      color: Colors.green[50],
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
                color: Colors.grey[700],
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
        color: Colors.green[50],
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

  Widget _buildSaveButton() {
    return Consumer<BillData>(
      builder: (context, billData, _) => FloatingActionButton(
        onPressed: () {
          billData.setSaveTime();
          print('保存数据: ${billData.bill}');
          if (widget.initialBill != null) {
            if (billData.bill.id != null) {
              updateBill(billData.bill.id!, billData.bill);
            } else {
              print('Error: Bill ID is null');
            }
          } else {
            insertBill(billData.bill);
          }
          Navigator.pop(context, true);
        },
        backgroundColor: Colors.blue,
        elevation: 4,
        child: const Icon(Icons.save, color: Colors.white),
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
                  color: Colors.grey,
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
    BillData billData = Provider.of<BillData>(context);
    bool isSelected = billData.bill.usefor == billItem[0]['usefor'];
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
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
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
              const SizedBox(height: 8),
              Text(
                billItem[0]['name'],
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.blue : Colors.grey[700],
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
  _InputMoneyState createState() => _InputMoneyState();
}

class _InputMoneyState extends State<InputMoney> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    BillData billData = Provider.of<BillData>(context, listen: false);
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
    BillData billData = Provider.of<BillData>(context);

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
                hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
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
  _InputRemarkState createState() => _InputRemarkState();
}

class _InputRemarkState extends State<InputRemark> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    BillData billData = Provider.of<BillData>(context, listen: false);
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
    BillData billData = Provider.of<BillData>(context);

    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: '添加备注...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        hintStyle: TextStyle(color: Colors.grey),
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
    BillData billData = Provider.of<BillData>(context);
    
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
            Icon(Icons.calendar_today, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              billData.bill.date.toLocal().toString().split(' ')[0],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class BillData extends ChangeNotifier {
  late final Bill _bill;

  BillData({Bill? initialBill})
      : _bill = initialBill ??
            Bill(
              type: 'pay',
              money: 0.00,
              date: DateTime.now(),
              savetime: DateTime.now(),
              usefor: 'other',
              source: '手动记账',
            );

  Bill get bill => _bill;
  
  void selectDate(BuildContext context) async {
    DateTime? selectedDate = await DatePickerUtil.selectDate(
      context: context,
      initialDate: _bill.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != _bill.date) {
      _bill.date = selectedDate;
      notifyListeners();
    }
  }
  
  void setType(String type) {
    _bill.type = type;
    notifyListeners();
  }
  
  void setUsefor(String usefor) {
    _bill.usefor = usefor;
    notifyListeners();
  }
  
  void setMoney(double money) {
    _bill.money = money;
    notifyListeners();
  }
  
  void setRemark(String remark) {
    _bill.remark = remark;
    notifyListeners();
  }
  
  void setSaveTime() {
    _bill.savetime = DateTime.now();
    notifyListeners();
  }
}