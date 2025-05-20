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
    final secondaryColor = const Color(0xFF1A237E); // 濃紺（セカンダリーカラー）

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
