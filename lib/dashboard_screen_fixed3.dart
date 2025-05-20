  // 改善した月別グラフ
  Widget _buildEnhancedMonthlyChart(
      BuildContext context, List<Map<String, dynamic>> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // グラフの凡例
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('収入', Colors.green[400]!),
                const SizedBox(width: 16),
                _buildLegendItem('支出', Colors.red[400]!),
                const SizedBox(width: 16),
                _buildLegendItem('利益', Colors.blue[400]!),
              ],
            ),

            const SizedBox(height: 16),

            // グラフ本体
            SizedBox(
              height: 220,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight;
                  final width = constraints.maxWidth;

                  // データ内の最大値を取得
                  final maxValue = data.fold<int>(
                    0,
                    (int max, item) => math.max(
                      max,
                      math.max(item['income'] as int, item['expense'] as int),
                    ),
                  );

                  // 金額の目盛りを作成
                  final markers = [
                    0,
                    maxValue ~/ 4,
                    maxValue ~/ 2,
                    maxValue * 3 ~/ 4,
                    maxValue
                  ];

                  return Stack(
                    children: [
                      // Y軸の目盛りと線
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: markers
                            .map((value) {
                              return Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      value >= 10000
                                          ? '${(value / 10000).toStringAsFixed(0)}万'
                                          : value.toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                ],
                              );
                            })
                            .toList()
                            .reversed
                            .toList(),
                      ),

                      // バーチャート
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: data.map((item) {
                            // 列幅を計算
                            final barWidth = (width - 60) / (data.length * 4);

                            // 各値の高さを計算
                            final incomeHeight =
                                ((item['income'] as int) / maxValue) *
                                    maxHeight *
                                    0.85;
                            final expenseHeight =
                                ((item['expense'] as int) / maxValue) *
                                    maxHeight *
                                    0.85;
                            final profitHeight =
                                ((item['profit'] as int).abs() / maxValue) *
                                    maxHeight *
                                    0.85;
                            final profitColor = (item['profit'] as int) >= 0
                                ? Colors.blue[400]!
                                : Colors.orange;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // バーグループ
                                SizedBox(
                                  height: maxHeight - 22, // 底部のラベル用のスペースを確保
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          // 収入バー
                                          _buildBarWithLabel(
                                            barWidth,
                                            incomeHeight,
                                            Colors.green[400]!,
                                            '¥${NumberFormat('#,###').format(item['income'])}',
                                          ),
                                          const SizedBox(width: 1),
                                          // 支出バー
                                          _buildBarWithLabel(
                                            barWidth,
                                            expenseHeight,
                                            Colors.red[400]!,
                                            '¥${NumberFormat('#,###').format(item['expense'])}',
                                          ),
                                          const SizedBox(width: 1),
                                          // 利益バー
                                          _buildBarWithLabel(
                                            barWidth,
                                            profitHeight,
                                            profitColor,
                                            '¥${NumberFormat('#,###').format(item['profit'].abs())}',
                                            isProfit: item['profit'] >= 0,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // 月表示ラベル
                                const SizedBox(height: 4),
                                Text(
                                  item['month'] as String,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // バーチャートの列を作成（ホバー時に値を表示）
  Widget _buildBarWithLabel(
      double width, double height, Color color, String label,
      {bool isProfit = true}) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        // バーの上に小さなラベル表示は省略（スペースの関係で）
      ],
    );
  }

  // 凡例アイテム
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // カテゴリー別リスト
  Widget _buildCategoryList() {
    // 合計金額を計算
    final totalExpense = _categoryData
        .where((c) => c['amount'] < 0)
        .fold<double>(0.0, (sum, c) => sum + (c['amount'] as int).abs());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // カテゴリーグラフ（円グラフ）
            SizedBox(
              height: 180,
              child: _buildCategoryPieChart(),
            ),

            const SizedBox(height: 16),

            // カテゴリーリスト
            ..._categoryData.where((c) => c['amount'] < 0).map((category) {
              // 割合を計算
              final percentage =
                  ((category['amount'] as int).abs() / totalExpense) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: category['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '¥${NumberFormat('#,###').format((category['amount'] as int).abs())}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // プログレスバー
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          category['color'] as Color),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // カテゴリー円グラフ
  Widget _buildCategoryPieChart() {
    // 合計金額を計算
    final totalExpense = _categoryData
        .where((c) => c['amount'] < 0)
        .fold<double>(0.0, (sum, c) => sum + (c['amount'] as int).abs());

    return CustomPaint(
      painter: PieChartPainter(
        categories: _categoryData.where((c) => c['amount'] < 0).map((category) {
          return PieChartCategory(
            name: category['name'] as String,
            // int から double に変換
            value: (category['amount'] as int).abs().toDouble(),
            color: category['color'] as Color,
          );
        }).toList(),
        total: totalExpense,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '総支出',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '¥${NumberFormat('#,###').format(totalExpense.toInt())}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 最近の取引リスト
  Widget _buildRecentTransactionsList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentTransactions.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, indent: 70),
        itemBuilder: (context, index) {
          final transaction = _recentTransactions[index];
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: (transaction['amount'] as int) > 0
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              child: Icon(
                _getCategoryIcon(transaction['category'] as String),
                color: (transaction['amount'] as int) > 0
                    ? Colors.green
                    : Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              transaction['description'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  '${_formatDate(transaction['date'] as DateTime)} • ${transaction['category'] as String}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 4),
                Icon(
                  _getPaymentMethodIcon(transaction['paymentMethod'] as String),
                  size: 12,
                  color: Colors.grey[400],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(transaction['amount'] as int) > 0 ? '+' : ''}¥${NumberFormat('#,###').format((transaction['amount'] as int).abs())}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (transaction['amount'] as int) > 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                Text(
                  transaction['paymentMethod'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            onTap: () {
              // 関連書類があれば詳細画面へナビゲーション
              if (transaction['documentId'] != null) {
                Navigator.pushNamed(
                  context,
                  '/document-detail',
                  arguments: {'documentId': transaction['documentId']},
                );
              }
            },
          );
        },
      ),
    );
  }

  // 日付フォーマット
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return '今日';
    } else if (difference == 1) {
      return '昨日';
    } else if (difference < 7) {
      return '$difference日前';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  // 期間に応じたアイコンを取得
  IconData _getPeriodIcon(String period) {
    switch (period) {
      case '今日':
        return Icons.today;
      case '昨日':
        return Icons.history;
      case '今週':
        return Icons.view_week;
      case '先週':
        return Icons.history;
      case '今月':
        return Icons.calendar_month;
      case '先月':
        return Icons.history;
      case '3ヶ月':
        return Icons.calendar_view_month;
      case '半年':
        return Icons.calendar_view_month;
      case '今年':
        return Icons.calendar_today;
      case '去年':
        return Icons.history;
      case 'すべて':
        return Icons.all_inclusive;
      default:
        return Icons.calendar_today;
    }
  }

  // カテゴリに応じたアイコンを取得
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '売上':
        return Icons.payments;
      case '交通費':
        return Icons.directions_car;
      case '通信費':
        return Icons.wifi;
      case '消耗品費':
        return Icons.shopping_bag;
      case '会議費':
        return Icons.people;
      default:
        return Icons.category;
    }
  }

  // 支払方法に応じたアイコンを取得
  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'クレジットカード':
        return Icons.credit_card;
      case '銀行振込':
        return Icons.account_balance;
      case '現金':
        return Icons.money;
      case 'QR決済':
        return Icons.qr_code;
      case '口座引落':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
