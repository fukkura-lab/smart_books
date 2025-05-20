import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:smart_books/screens/reports/monthly_report_screen.dart';
import 'package:smart_books/utils/keyboard_util.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // 選択中の期間
  String _selectedPeriod = '今月';

  // 期間リストを詳細にする
  final List<String> _periods = [
    '今日',
    '昨日',
    '今週',
    '先週',
    '今月',
    '先月',
    '3ヶ月',
    '半年',
    '今年',
    '去年',
    'すべて'
  ];

  // カレンダーで選択した期間
  DateTimeRange? _customDateRange;
  
  // 日付選択用
  DateTime selectedDate = DateTime.now();
  
  // 補助カラー
  final Color secondaryColor = const Color(0xFF1A237E); // 濃紺
  final Color accentColor = const Color(0xFFF8BBD0); // 薄ピンク

  // アニメーションコントローラー
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // サンプルデータ
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'description': '取引先A 打ち合わせ費',
      'amount': -5800,
      'category': '交通費',
      'documentId': '3',
      'paymentMethod': 'クレジットカード',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'description': 'クライアントB 報酬',
      'amount': 150000,
      'category': '売上',
      'documentId': '2',
      'paymentMethod': '銀行振込',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'オフィス用品',
      'amount': -12500,
      'category': '消耗品費',
      'documentId': '5',
      'paymentMethod': 'クレジットカード',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'description': '通信費',
      'amount': -8800,
      'category': '通信費',
      'documentId': '6',
      'paymentMethod': '口座引落',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'description': 'クライアントC 報酬',
      'amount': 220000,
      'category': '売上',
      'documentId': '2',
      'paymentMethod': '銀行振込',
    },
  ];

  // カテゴリー別データ
  final List<Map<String, dynamic>> _categoryData = [
    {'name': '売上', 'amount': 370000, 'color': Colors.green},
    {'name': '交通費', 'amount': -12600, 'color': Colors.redAccent},
    {'name': '通信費', 'amount': -8800, 'color': Colors.orangeAccent},
    {'name': '消耗品費', 'amount': -15200, 'color': Colors.purpleAccent},
    {'name': '会議費', 'amount': -7500, 'color': Colors.blueAccent},
  ];

  // 月次データ生成
  List<Map<String, dynamic>> _generateMonthlyData() {
    final random = math.Random();
    final List<Map<String, dynamic>> data = [];

    final months = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月'
    ];

    for (int i = 0; i < months.length; i++) {
      final income = 200000 + random.nextInt(300000);
      final expense = 100000 + random.nextInt(150000);
      data.add({
        'month': months[i],
        'income': income,
        'expense': expense,
        'profit': income - expense,
      });
    }

    return data;
  }

  @override
  void initState() {
    super.initState();

    // アニメーションコントローラーの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // 画面表示時にアニメーションを開始
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面全体をGestureDetectorで囲んだフォーカス管理はメインアプリで行うように変更
    // 月間サマリーデータを生成
    final monthlyData = _generateMonthlyData();

    // 合計値の計算
    final incomeTotal = _recentTransactions
        .where((t) => t['amount'] > 0)
        .fold<int>(0, (sum, t) => sum + (t['amount'] as int));

    final expenseTotal = _recentTransactions
        .where((t) => t['amount'] < 0)
        .fold<int>(0, (sum, t) => sum + (t['amount'] as int).abs());

    final profit = incomeTotal - expenseTotal;

    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('収支'),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          // 期間選択ボタン
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              if (value == 'カスタム') {
                _selectCustomDateRange(context);
              } else {
                setState(() {
                  _selectedPeriod = value;
                  _customDateRange = null; // カスタム期間をリセット
                });

                // 変更時に触覚フィードバック
                HapticFeedback.lightImpact();

                // アニメーションをリセットして再生
                _animationController.reset();
                _animationController.forward();
              }
            },
            itemBuilder: (context) {
              return [
                ..._periods.map((period) {
                  return PopupMenuItem<String>(
                    value: period,
                    child: Row(
                      children: [
                        Icon(
                          _getPeriodIcon(period),
                          size: 18,
                          color: period == _selectedPeriod
                              ? primaryColor
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          period,
                          style: TextStyle(
                            fontWeight: period == _selectedPeriod
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color:
                                period == _selectedPeriod ? primaryColor : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                // カスタム期間選択オプションを追加
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'カスタム',
                  child: Row(
                    children: [
                      Icon(Icons.date_range, size: 18),
                      SizedBox(width: 8),
                      Text('カスタム期間を選択'),
                    ],
                  ),
                ),
              ];
            },
          ),

          // 設定ボタン
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // フィルターや表示オプションの設定
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('表示オプションは準備中です'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 期間表示
              _buildPeriodIndicator(),

              const SizedBox(height: 16),

              // サマリーカード
              _buildSummaryCard(context, incomeTotal, expenseTotal, profit),

              const SizedBox(height: 24),

              // 月別収支グラフ（上部に移動）
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '月別収支',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // 月別詳細レポート画面へ遷移
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MonthlyReportScreen(
                            month: _selectedPeriod == '今月' 
                              ? DateTime.now() 
                              : (_selectedPeriod == '先月'
                                ? DateTime(DateTime.now().year, DateTime.now().month - 1, 1)
                                : DateTime.now()),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics, size: 16),
                    label: const Text('詳細を表示'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 改善した月別収支グラフ
              _buildEnhancedMonthlyChart(context, monthlyData),

              const SizedBox(height: 24),

              // カテゴリー別支出
              Text(
                'カテゴリー別',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 8),

              // カテゴリーリスト
              _buildCategoryList(),

              const SizedBox(height: 24),

              // 最近の取引タイトル
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最近の取引',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // 取引一覧画面へ遷移
                      Navigator.pushNamed(context, '/transaction-list');
                    },
                    icon: const Icon(Icons.list_alt, size: 16),
                    label: const Text('すべて表示'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 最近の取引リスト
              _buildRecentTransactionsList(),

              // ボトムナビゲーションとフローティングアクションボタンの間に余白を追加
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // 新規取引登録ボタン（位置調整済み）
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 取引追加ボタン（右寄せに配置）
            FloatingActionButton.extended(
              heroTag: 'addTransaction',
              onPressed: () {
                _showAddTransactionDialog();
                // 触覚フィードバック
                HapticFeedback.mediumImpact();
              },
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add),
              label: const Text('取引を追加'),
              elevation: 4,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 日付フォーマット(ダイアログ用)
  String formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

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

  // 取引追加ダイアログ
  void _showAddTransactionDialog() {
    // ダイアログ表示前にフォーカスを外す
    KeyboardUtil.hideKeyboard(context);
    
    // 状態変数
    bool isIncome = true; // 初期値を収入にする
    String? selectedCategory;
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // ダークモードの場合の背景色とテキスト色
    final bgColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.grey.shade800;
    final fieldBgColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade50;
    final fieldBorderColor = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300;
    
    // 収入用カテゴリー
    final incomeCategories = [
      '売上',
      '給与',
      '副業',
      '配当',
      '賞与',
      'その他収入',
    ];
    
    // 支出用カテゴリー
    final expenseCategories = [
      '交通費',
      '通信費',
      '消耗品費',
      '会議費',
      '広告宣伝費',
      '接待交際費',
      '水道光熱費',
      '家賃',
      '保険料',
      '人件費',
      'その他経費',
    ];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 透明にして中身で色を設定
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              // 入力フィールド以外の領域をタップしたときにフォーカスを外す
              onTap: () => KeyboardUtil.hideKeyboard(dialogContext),
              behavior: HitTestBehavior.opaque, // 透明な領域もタップイベントを捕捉
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ヘッダー
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '新規取引を登録',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // タブ選択（収入/支出）
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 収入ボタン
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isIncome = true;
                                  selectedCategory = null; // カテゴリーをリセット
                                });
                                // 触覚フィードバック
                                HapticFeedback.lightImpact();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isIncome ? primaryColor : Colors.transparent,
                                foregroundColor: isIncome ? Colors.white : (isDarkMode ? Colors.white70 : Colors.grey.shade700),
                                elevation: isIncome ? 0 : 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_circle_up,
                                    size: 16,
                                    color: isIncome ? Colors.white : (isDarkMode ? Colors.white70 : Colors.grey.shade700),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('収入'),
                                ],
                              ),
                            ),
                          ),
                          
                          // 支出ボタン
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isIncome = false;
                                  selectedCategory = null; // カテゴリーをリセット
                                });
                                // 触覚フィードバック
                                HapticFeedback.lightImpact();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !isIncome ? accentColor : Colors.transparent,
                                foregroundColor: !isIncome ? Colors.white : (isDarkMode ? Colors.white70 : Colors.grey.shade700),
                                elevation: !isIncome ? 0 : 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_circle_down,
                                    size: 16,
                                    color: !isIncome ? Colors.white : (isDarkMode ? Colors.white70 : Colors.grey.shade700),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('支出'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // フォーム内容
                    TextField(
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: '取引名',
                        labelStyle: TextStyle(color: primaryColor),
                        prefixIcon: Icon(Icons.description, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: fieldBorderColor),
                        ),
                        filled: true,
                        fillColor: fieldBgColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: '金額',
                        labelStyle: TextStyle(color: primaryColor),
                        prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                        prefixText: '¥',
                        prefixStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: fieldBorderColor),
                        ),
                        filled: true,
                        fillColor: fieldBgColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // カテゴリー選択（収入/支出で内容が変わる）
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: bgColor, // ドロップダウンメニューの背景色
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: bgColor,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'カテゴリ',
                          labelStyle: TextStyle(color: primaryColor),
                          prefixIcon: Icon(Icons.category, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorderColor),
                          ),
                          filled: true,
                          fillColor: fieldBgColor,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        items: (isIncome ? incomeCategories : expenseCategories).map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        icon: Icon(Icons.arrow_drop_down, color: secondaryColor),
                        hint: Text('カテゴリを選択', style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade400)),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 日付選択（タップでカレンダー表示）
                    InkWell(
                      onTap: () async {
                        // 日付選択ダイアログを表示
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: isDarkMode
                                  ? ThemeData.dark().copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: secondaryColor,
                                        onPrimary: Colors.white,
                                        surface: Colors.grey.shade800,
                                        onSurface: Colors.white,
                                      ),
                                      dialogBackgroundColor: Colors.grey.shade800,
                                    )
                                  : ThemeData.light().copyWith(
                                      primaryColor: secondaryColor,
                                      colorScheme: ColorScheme.light(
                                        primary: secondaryColor,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: secondaryColor,
                                      ),
                                      dialogBackgroundColor: Colors.white,
                                    ),
                              child: child!,
                            );
                          },
                        );
                        
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                          // 触覚フィードバック
                          HapticFeedback.lightImpact();
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '日付',
                          labelStyle: TextStyle(color: secondaryColor),
                          prefixIcon: Icon(Icons.calendar_today, color: secondaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: secondaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: fieldBorderColor),
                          ),
                          filled: true,
                          fillColor: fieldBgColor,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          suffixIcon: Icon(Icons.arrow_drop_down, color: secondaryColor),
                        ),
                        child: Text(
                          formatDate(selectedDate),
                          style: TextStyle(color: isDarkMode ? Colors.white : secondaryColor),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 送信ボタン
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isIncome ? '収入を登録しました' : '支出を登録しました'),
                              backgroundColor: isIncome ? Colors.green : accentColor,
                            ),
                          );
                          // 触覚フィードバック
                          HapticFeedback.mediumImpact();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isIncome ? secondaryColor : accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 3,
                          shadowColor: isIncome 
                              ? secondaryColor.withOpacity(0.5) 
                              : accentColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isIncome ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isIncome ? '収入を登録' : '支出を登録',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 円グラフ用データモデル
class PieChartCategory {
  final String name;
  final double value;
  final Color color;

  PieChartCategory({
    required this.name,
    required this.value,
    required this.color,
  });
}

// 円グラフの描画クラス
class PieChartPainter extends CustomPainter {
  final List<PieChartCategory> categories;
  final double total;

  PieChartPainter({required this.categories, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    var startAngle = -math.pi / 2; // -90度から開始

    for (var category in categories) {
      final sweepAngle = (category.value / total) * 2 * math.pi;

      // 円弧を描画
      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // 白い境界線を描画
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      startAngle += sweepAngle;
    }

    // 中央の円を描画（ドーナツ状にするため）
    final centerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}