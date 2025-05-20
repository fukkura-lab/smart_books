import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_books/config/theme.dart';
import 'package:smart_books/models/reports/monthly_report_models.dart';
import 'dart:math' as math;

/// 月選択ウィジェット
class MonthSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onMonthChanged;
  final Function() onTap;

  const MonthSelector({
    Key? key,
    required this.selectedDate,
    required this.onMonthChanged,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppTheme.secondaryColor),
              onPressed: () {
                final previousMonth = DateTime(
                  selectedDate.year,
                  selectedDate.month - 1,
                  1,
                );
                onMonthChanged(previousMonth);
              },
            ),
            InkWell(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 16.0, color: AppTheme.secondaryColor),
                    SizedBox(width: 8.0),
                    Text(
                      DateFormat('yyyy年MM月').format(selectedDate),
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryColor),
              onPressed: () {
                final nextMonth = DateTime(
                  selectedDate.year,
                  selectedDate.month + 1,
                  1,
                );
                onMonthChanged(nextMonth);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 集計カードウィジェット
class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final double previousAmount;
  final double changePercentage;
  final double? budgetAmount;
  final double? budgetPercentage;
  final bool isExpense;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.previousAmount,
    required this.changePercentage,
    this.budgetAmount,
    this.budgetPercentage,
    required this.isExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? Colors.redAccent : Colors.greenAccent;
    final percentageColor = changePercentage >= 0 
      ? (isExpense ? Colors.redAccent : Colors.greenAccent)
      : (isExpense ? Colors.greenAccent : Colors.redAccent);
    final icon = changePercentage >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(fontSize: 14, color: Colors.grey[600])
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '¥${NumberFormat('#,###').format(amount)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      icon,
                      color: percentageColor,
                      size: 16,
                    ),
                    Text(
                      '${changePercentage.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: percentageColor,
                      ),
                    ),
                    Text(' 先月比', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            if (budgetAmount != null && budgetPercentage != null) ...[
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: budgetPercentage! / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              SizedBox(height: 8),
              isExpense
                ? Text('予算の${budgetPercentage!.toStringAsFixed(1)}%を使用しました', 
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]))
                : Text('目標の${budgetPercentage!.toStringAsFixed(1)}%を達成しました', 
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ],
        ),
      ),
    );
  }
}

/// 円グラフセクションウィジェット
class PieChartSection extends StatelessWidget {
  final List<CategorySummary> categories;
  final String title;
  final bool isExpense;

  const PieChartSection({
    Key? key,
    required this.categories,
    required this.title,
    required this.isExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              )
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: PieChart(
                      PieChartData(
                        sections: categories.map((item) {
                          return PieChartSectionData(
                            color: item.color,
                            value: item.amount,
                            title: '${item.percentage.toStringAsFixed(1)}%',
                            radius: 80,
                            titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _buildLegend(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            _buildInteractiveHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.category}: ¥${NumberFormat('#,###').format(item.amount)}',
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInteractiveHint() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8),
      child: Text(
        'グラフをタップするとカテゴリ詳細が表示されます',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

/// トレンドチャートウィジェット
class TrendChartSection extends StatelessWidget {
  final List<MonthlyTrend> trendData;
  final String title;

  const TrendChartSection({
    Key? key,
    required this.trendData,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 最大値を計算して、グラフの上限を設定
    final maxIncome = trendData.map((e) => e.income).reduce((a, b) => a > b ? a : b);
    final maxExpense = trendData.map((e) => e.expense).reduce((a, b) => a > b ? a : b);
    final maxValue = (maxIncome > maxExpense ? maxIncome : maxExpense) * 1.1;
    
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              )
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 100000,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final int index = value.toInt();
                          if (index >= 0 && index < trendData.length) {
                            return Text(
                              trendData[index].month,
                              style: TextStyle(
                                color: Color(0xff68737d),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 100000 == 0) {
                            return Text(
                              '${(value / 10000).toStringAsFixed(0)}万',
                              style: TextStyle(
                                color: Color(0xff67727d),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            );
                          }
                          return Text('');
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: 0,
                  maxX: trendData.length.toDouble() - 1,
                  minY: 0,
                  maxY: maxValue,
                  lineBarsData: [
                    // 収入の線
                    LineChartBarData(
                      spots: List.generate(trendData.length, (index) {
                        return FlSpot(index.toDouble(), trendData[index].income);
                      }),
                      isCurved: true,
                      color: Colors.greenAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.greenAccent.withOpacity(0.3),
                      ),
                    ),
                    // 支出の線
                    LineChartBarData(
                      spots: List.generate(trendData.length, (index) {
                        return FlSpot(index.toDouble(), trendData[index].expense);
                      }),
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.redAccent.withOpacity(0.3),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.white,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          final isIncome = touchedSpot.barIndex == 0;
                          final value = isIncome 
                              ? trendData[index].income 
                              : trendData[index].expense;
                          
                          return LineTooltipItem(
                            '${isIncome ? "収入" : "支出"}: ¥${NumberFormat('#,###').format(value)}',
                            TextStyle(
                              color: isIncome ? Colors.greenAccent : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('収入', Colors.greenAccent),
                SizedBox(width: 16),
                _buildLegendItem('支出', Colors.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// 取引リストウィジェット
class TransactionListSection extends StatelessWidget {
  final List<Transaction> transactions;
  final String title;
  final bool isExpense;
  final Function(Transaction) onItemTap;
  final VoidCallback onViewAll;

  const TransactionListSection({
    Key? key,
    required this.transactions,
    required this.title,
    required this.isExpense,
    required this.onItemTap,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  )
                ),
                TextButton.icon(
                  onPressed: onViewAll,
                  icon: Icon(Icons.list, size: 16),
                  label: Text('すべて見る'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            transactions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'この月のデータはありません',
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
                    return TransactionListItem(
                      transaction: transaction,
                      isExpense: isExpense,
                      onTap: () => onItemTap(transaction),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}

/// 個別の取引リストアイテム
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final bool isExpense;
  final VoidCallback onTap;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    required this.isExpense,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = CategoryColors.getColorForCategory(transaction.category, isExpense);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.8),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${DateFormat('yyyy/MM/dd').format(transaction.date)} · ${transaction.category}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '¥${NumberFormat('#,###').format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
