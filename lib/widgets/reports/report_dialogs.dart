import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_books/config/theme.dart';
import 'package:smart_books/models/reports/monthly_report_models.dart';

/// 取引詳細ダイアログ
class TransactionDetailDialog extends StatelessWidget {
  final Transaction transaction;
  final List<Transaction> similarTransactions;

  const TransactionDetailDialog({
    Key? key,
    required this.transaction,
    required this.similarTransactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final color = CategoryColors.getColorForCategory(transaction.category, isExpense);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.8),
                  radius: 24,
                  child: Icon(
                    isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction.category,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow(
              '金額', 
              '¥${NumberFormat('#,###').format(transaction.amount)}',
              isExpense ? Colors.redAccent : Colors.greenAccent
            ),
            _buildInfoRow('日付', DateFormat('yyyy年MM月dd日').format(transaction.date)),
            if (transaction.paymentMethod != null)
              _buildInfoRow('支払方法', transaction.paymentMethod!),
            if (transaction.memo != null && transaction.memo!.isNotEmpty)
              _buildInfoRow('メモ', transaction.memo!),
            SizedBox(height: 16),
            if (similarTransactions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '同じカテゴリの取引',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(maxHeight: 150),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: similarTransactions.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final similar = similarTransactions[index];
                    return ListTile(
                      title: Text(similar.description),
                      subtitle: Text(DateFormat('yyyy/MM/dd').format(similar.date)),
                      trailing: Text(
                        '¥${NumberFormat('#,###').format(similar.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      dense: true,
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('閉じる'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 編集画面へ移動
                  },
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('編集'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// カテゴリ詳細ダイアログ
class CategoryDetailDialog extends StatelessWidget {
  final CategorySummary category;
  final List<Transaction> transactions;
  final bool isExpense;

  const CategoryDetailDialog({
    Key? key,
    required this.category,
    required this.transactions,
    required this.isExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    final totalAmount = category.amount;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.8),
                    radius: 24,
                    child: Icon(
                      isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${category.category}の詳細',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isExpense ? '支出カテゴリ' : '収入カテゴリ',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoRow(
                '合計', 
                '¥${NumberFormat('#,###').format(totalAmount)}',
                isExpense ? Colors.redAccent : Colors.greenAccent
              ),
              _buildInfoRow(
                '前月比', 
                '${category.changePercentage >= 0 ? '+' : ''}${category.changePercentage.toStringAsFixed(1)}%',
                category.changePercentage >= 0 
                  ? (isExpense ? Colors.redAccent : Colors.greenAccent) 
                  : (isExpense ? Colors.greenAccent : Colors.redAccent)
              ),
              _buildInfoRow('構成比', '${category.percentage.toStringAsFixed(1)}%'),
              SizedBox(height: 16),
              _buildTrendChart(),
              SizedBox(height: 16),
              Text(
                '${category.category}の取引一覧',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              transactions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'データがありません',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: transactions.length > 5 ? 5 : transactions.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return ListTile(
                        title: Text(transaction.description),
                        subtitle: Text(DateFormat('yyyy/MM/dd').format(transaction.date)),
                        trailing: Text(
                          '¥${NumberFormat('#,###').format(transaction.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isExpense ? Colors.redAccent : Colors.greenAccent,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => TransactionDetailDialog(
                              transaction: transaction,
                              similarTransactions: transactions.where((t) => t.id != transaction.id).take(3).toList(),
                            ),
                          );
                        },
                      );
                    },
                  ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('閉じる'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // カテゴリ管理画面へ移動
                    },
                    icon: Icon(Icons.list_alt, size: 16),
                    label: Text('すべて見る'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    // ここでは簡易的なサンプルデータを使用
    // 実際のアプリでは過去数ヶ月のデータを取得して表示
    final List<double> monthlySeries = [
      category.amount * 0.7,
      category.amount * 0.8,
      category.amount * 0.9,
      category.amount * 0.85,
      category.amount * 0.95,
      category.amount,
    ];
    
    return Container(
      height: 150,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '過去6ヶ月の推移',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: monthlySeries.reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '¥${NumberFormat('#,###').format(monthlySeries[groupIndex])}',
                        TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final List<String> titles = ['-5', '-4', '-3', '-2', '-1', '今月'];
                        return Text(
                          titles[value.toInt()],
                          style: TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                      reservedSize: 18,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(monthlySeries.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monthlySeries[index],
                        color: category.color,
                        width: 15,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
