  // カスタム期間選択ダイアログ
  Future<void> _selectCustomDateRange(BuildContext context) async {
    final initialDateRange = _customDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _customDateRange = newDateRange;
        _selectedPeriod = 'カスタム';
      });

      // アニメーションをリセットして再生
      _animationController.reset();
      _animationController.forward();
    }
  }

  // 期間インジケーター（カスタム期間に対応）
  Widget _buildPeriodIndicator() {
    String periodText;
    IconData periodIcon;

    if (_customDateRange != null) {
      // カスタム期間が選択されている場合
      final start = _customDateRange!.start;
      final end = _customDateRange!.end;
      periodText =
          '${start.year}/${start.month}/${start.day} - ${end.year}/${end.month}/${end.day}';
      periodIcon = Icons.date_range;
    } else {
      // プリセット期間が選択されている場合
      final now = DateTime.now();
      switch (_selectedPeriod) {
        case '今日':
          periodText = '${now.month}月${now.day}日';
          periodIcon = Icons.today;
          break;
        case '昨日':
          final yesterday = now.subtract(const Duration(days: 1));
          periodText = '${yesterday.month}月${yesterday.day}日';
          periodIcon = Icons.history;
          break;
        case '今週':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          periodText =
              '${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}';
          periodIcon = Icons.view_week;
          break;
        case '先週':
          final lastWeekStart = now.subtract(Duration(days: now.weekday + 6));
          final lastWeekEnd = lastWeekStart.add(const Duration(days: 6));
          periodText =
              '${lastWeekStart.month}/${lastWeekStart.day} - ${lastWeekEnd.month}/${lastWeekEnd.day}';
          periodIcon = Icons.history;
          break;
        case '今月':
          periodText = '${now.year}年${now.month}月';
          periodIcon = Icons.calendar_month;
          break;
        case '先月':
          final lastMonth = DateTime(now.year, now.month - 1, 1);
          periodText = '${lastMonth.year}年${lastMonth.month}月';
          periodIcon = Icons.history;
          break;
        case '3ヶ月':
          final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
          periodText =
              '${threeMonthsAgo.year}年${threeMonthsAgo.month}月 - ${now.year}年${now.month}月';
          periodIcon = Icons.calendar_view_month;
          break;
        case '半年':
          final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
          periodText =
              '${sixMonthsAgo.year}年${sixMonthsAgo.month}月 - ${now.year}年${now.month}月';
          periodIcon = Icons.calendar_view_month;
          break;
        case '今年':
          periodText = '${now.year}年';
          periodIcon = Icons.calendar_today;
          break;
        case '去年':
          periodText = '${now.year - 1}年';
          periodIcon = Icons.history;
          break;
        default:
          periodText = 'すべての期間';
          periodIcon = Icons.all_inclusive;
      }
    }

    return Center(
      child: InkWell(
        onTap: () => _selectCustomDateRange(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                spreadRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                periodIcon,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                periodText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // サマリーカード
  Widget _buildSummaryCard(
      BuildContext context, int income, int expense, int profit) {
    // フォーマッタ
    final currencyFormat = NumberFormat("#,##0", "ja_JP");

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              profit >= 0 ? Colors.green[50]! : Colors.red[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 利益ヘッダー
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: profit >= 0 ? Colors.green[100] : Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      profit >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: profit >= 0 ? Colors.green[700] : Colors.red[700],
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '収支サマリー',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: profit >= 0 ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            profit >= 0 ? Colors.green[300]! : Colors.red[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      profit >= 0 ? '黒字' : '赤字',
                      style: TextStyle(
                        color:
                            profit >= 0 ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 利益表示
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    profit >= 0 ? '+' : '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: profit >= 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                  Text(
                    '¥${currencyFormat.format(profit)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: profit >= 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 収入・支出
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 収入
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_circle_up,
                                color: Colors.green[400],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '収入',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¥${currencyFormat.format(income)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 区切り線
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey[300],
                    ),

                    // 支出
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_circle_down,
                                color: Colors.red[400],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '支出',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '¥${currencyFormat.format(expense)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
