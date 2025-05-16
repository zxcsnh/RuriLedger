import 'package:flutter/material.dart';
import 'package:myapp/src/utils/appColors.dart';
import 'package:myapp/src/utils/db.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text('设置'),
        backgroundColor: AppColors.appBarBackground,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 导出备份
                  exportDatabaseToCustomPath();
                  // exportDatabaseToExternalDir();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // 控制圆角
                  ),
                ),
                child: Text(
                  '导出备份',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // 按钮之间的竖向间距
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 导入备份
                  pickAndImportDatabase();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '导入备份',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}