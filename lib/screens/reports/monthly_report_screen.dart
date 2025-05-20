import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class MonthlyReportScreen extends StatefulWidget {
  final DateTime month;

  const MonthlyReportScreen({
    Key? key,
    required this.month,
  }) : super(key: key);

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedMonth;
  bool _isLoading = false;

  // アニメーションコントローラー
  late AnimationController _animationController;
  late Animation<double> _animation;

  // チャート表示タイプ
  String _chartDisplayType = 'bar'; // 'bar' または 'line'

  // カテゴリータブコントローラー
  late TabController _tabController;

  // ズーム/パンのための状態管理
  double _zoomLevel = 1.0;
  double _maxZoomLevel = 2.5;
  double _minZoomLevel = 0.5;

  // 簡易データモデル
  late Map<String, dynamic> _reportData;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.month;

    // アニメーションコントローラーの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );

    // タブコントローラー初期化
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    // データロード
    _loadReportData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // タブ変更ハンドラー
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // ハプティックフィードバック
      HapticFeedback.selectionClick();

      // アニメーション再生
      _animationController.reset();
      _animationController.forward();
    }
  }

  // レポートデータを読み込む
  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // APIからのデータ取得をシミュレート
      await Future.delayed(const Duration(milliseconds: 800));

      // モックデータを生成
      _reportData = _generateMockData(_selectedMonth);

      setState(() {
        _isLoading = false;
      });

      // データロード後にアニメーション開始
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // エラーハンドリング
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('データの読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 簡易モックデータ生成
  Map<String, dynamic> _generateMockData(DateTime month) {
    final random = math.Random();

    // 日別データを生成
    final dailyData = <Map<String, dynamic>>[];
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // データがある日の数を決定
    final transactionDays = math.max((daysInMonth * 0.7).round(), 10);

    // 日をランダムに選ぶ（データなしの日を作らないため）
    final List<int> days = List.generate(daysInMonth, (i) => i + 1);
    days.shuffle(random);
    final selectedDays = days.sublist(0, transactionDays);
    selectedDays.sort(); // 日付順に戻す

    // 収入日をランダムに決定（全体の30%程度）
    final incomeDaysCount = (transactionDays * 0.3).round();
    final incomeDays = Set<int>.from(selectedDays.sublist(0, incomeDaysCount));

    // 各日の取引を生成
    for (final day in selectedDays) {
      final date = DateTime(month.year, month.month, day);

      // 収入日
      if (incomeDays.contains(day)) {
        final amount = 15000 + random.nextInt(40000);
        dailyData.add({
          'date': date,
          'income': amount,
          'expense': 0,
          'balance': amount,
        });
      }
      // 支出日
      else {
        final amount = 2000 + random.nextInt(15000);
        dailyData.add({
          'date': date,
          'income': 0,
          'expense': amount,
          'balance': -amount,
        });
      }
    }

    // 日付でソート
    dailyData.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // 月間の合計を計算
    final totalIncome =
        dailyData.fold<int>(0, (sum, item) => sum + (item['income'] as int));
    final totalExpense =
        dailyData.fold<int>(0, (sum, item) => sum + (item['expense'] as int));
    final profit = totalIncome - totalExpense;

    // 支出カテゴリー
    final expenseCategories = [
      {'name': '交通費', 'amount': 35000, 'color': Colors.blue},
      {'name': '通信費', 'amount': 25000, 'color': Colors.orange},
      {'name': '消耗品費', 'amount': 40000, 'color': Colors.purple},
      {'name': '会議費', 'amount': 30000, 'color': Colors.red},
      {'name': '広告宣伝費', 'amount': 90000, 'color': Colors.teal},
    ];

    // 収入カテゴリー
    final incomeCategories = [
      {'name': '売上', 'amount': 350000, 'color': Colors.green},
      {'name': '雑収入', 'amount': 25000, 'color': Colors.green[300]!},
    ];

    return {
      'month': month,
      'income': totalIncome > 0 ? totalIncome : 350000 + random.nextInt(50000),
      'expense':
          totalExpense > 0 ? totalExpense : 220000 + random.nextInt(30000),
      'profit': profit != 0 ? profit : 130000 + random.nextInt(20000),
      'dailyData': dailyData,
      'expenseCategories': expenseCategories,
      'incomeCategories': incomeCategories,
    };
  }

  // 月を変更
  void _changeMonth(int monthDelta) {
    // ハプティックフィードバック
    HapticFeedback.mediumImpact();

    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + monthDelta,
      );
    });

    // アニメーションをリセット
    _animationController.reset();

    // データ再読み込み
    _loadReportData();
  }

  // チャート表示タイプを切り替え
  void _toggleChartType() {
    // ハプティックフィードバック
    HapticFeedback.selectionClick();

    setState(() {
      _chartDisplayType = _chartDisplayType == 'bar' ? 'line' : 'bar';

      // アニメーションをリセットして再開
      _animationController.reset();
      _animationController.forward();
    });
  }

  // ズームレベル調整
  void _adjustZoom(double delta) {
    setState(() {
      _zoomLevel = (_zoomLevel + delta).clamp(_minZoomLevel, _maxZoomLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('月別詳細レポート'),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          // チャート表示切替ボタン
          IconButton(
            icon: Icon(_chartDisplayType == 'bar'
                ? Icons.show_chart
                : Icons.bar_chart),
            tooltip: 'チャート表示切替',
            onPressed: _toggleChartType,
          ),
          // PDFエクスポートボタン
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'PDFエクスポート',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDFエクスポートは準備中です'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReportData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 月選択ヘッダー
                    _buildMonthSelector(context),

                    const SizedBox(height: 16),

                    // サマリーカード
                    _buildSummaryCard(context),

                    const SizedBox(height: 24),

                    // 日別推移チャート
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '日別推移',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),

                        // ズームコントロール
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.zoom_out),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              iconSize: 20,
                              onPressed: _zoomLevel <= _minZoomLevel
                                  ? null
                                  : () => _adjustZoom(-0.2),
                            ),
                            Text(
                              '${(_zoomLevel * 100).round()}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.zoom_in),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              iconSize: 20,
                              onPressed: _zoomLevel >= _maxZoomLevel
                                  ? null
                                  : () => _adjustZoom(0.2),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 日別推移チャート
                    _buildDailyChart(context),

                    const SizedBox(height: 24),

                    // カテゴリー分析ヘッダー
                    Text(
                      'カテゴリー分析',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // カテゴリー分析タブ
                    _buildCategoryTabs(context),
                  ],
                ),
              ),
            ),
    );
  }

  // 月選択ヘッダー
  Widget _buildMonthSelector(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final monthFormat = DateFormat('yyyy年M月', 'ja_JP');

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // スワイプで月変更
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            // 右スワイプで前月
            _changeMonth(-1);
          } else if (details.primaryVelocity! < 0) {
            // 左スワイプで翌月
            _changeMonth(1);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 前月ボタン
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeMonth(-1),
            ),
            // 月表示
            InkWell(
              onTap: () => _showMonthPicker(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      monthFormat.format(_selectedMonth),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            // 翌月ボタン
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
      ),
    );
  }

  // 月ピッカーダイアログを表示
  void _showMonthPicker(BuildContext context) {
    final currentYear = DateTime.now().year;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '月を選択',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 年月選択グリッド
              Expanded(
                child: ListView.builder(
                  itemCount: 3, // 過去3年分
                  itemBuilder: (context, yearIndex) {
                    final year = currentYear - yearIndex;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '$year年',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: 12,
                          itemBuilder: (context, monthIndex) {
                            final month = monthIndex + 1;
                            final date = DateTime(year, month);
                            final isSelected = _selectedMonth.year == year &&
                                _selectedMonth.month == month;

                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _selectedMonth = date;
                                });
                                _loadReportData();
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$month月',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // サマリーカード
  Widget _buildSummaryCard(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0", "ja_JP");
    final income = _reportData['income'] as int;
    final expense = _reportData['expense'] as int;
    final profit = _reportData['profit'] as int;
    final isProfit = profit >= 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isProfit ? Colors.green[50]! : Colors.red[50]!,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              children: [
                // 月間収支ヘッダー
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isProfit ? Colors.green[100] : Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isProfit ? Icons.trending_up : Icons.trending_down,
                        color: isProfit ? Colors.green[700] : Colors.red[700],
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '月間収支',
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
                        color: isProfit ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isProfit ? Colors.green[300]! : Colors.red[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isProfit ? '黒字' : '赤字',
                        style: TextStyle(
                          color: isProfit ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 利益表示（アニメーション付き）
                Transform.scale(
                  scale: 0.8 + (_animation.value * 0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isProfit ? '+' : '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isProfit ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      Text(
                        '¥${currencyFormat.format(profit)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isProfit ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 収入・支出
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 収入
                    Column(
                      children: [
                        Row(
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

                    // 区切り線
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey[300],
                    ),

                    // 支出
                    Column(
                      children: [
                        Row(
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
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 日別推移チャート
  Widget _buildDailyChart(BuildContext context) {
    final dailyData = _reportData['dailyData'] as List<Map<String, dynamic>>;

    if (dailyData.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Center(
            child: Text(
              'この月の取引データはありません',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // グラフの凡例とタイプ切替
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 凡例
                Row(
                  children: [
                    _buildLegendItem('収入', Colors.green),
                    const SizedBox(width: 16),
                    _buildLegendItem('支出', Colors.red),
                    const SizedBox(width: 16),
                    _buildLegendItem('残高', Colors.blue),
                  ],
                ),

                // チャート表示タイプ切替ボタン
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      // 棒グラフボタン
                      _buildChartTypeButton(
                        icon: Icons.bar_chart,
                        label: '棒',
                        isSelected: _chartDisplayType == 'bar',
                        onTap: () {
                          if (_chartDisplayType != 'bar') {
                            setState(() {
                              _chartDisplayType = 'bar';
                              // アニメーション再生
                              _animationController.reset();
                              _animationController.forward();
                            });
                            // ハプティックフィードバック
                            HapticFeedback.selectionClick();
                          }
                        },
                      ),
                      
                      // 折れ線グラフボタン
                      _buildChartTypeButton(
                        icon: Icons.show_chart,
                        label: '線',
                        isSelected: _chartDisplayType == 'line',
                        onTap: () {
                          if (_chartDisplayType != 'line') {
                            setState(() {
                              _chartDisplayType = 'line';
                              // アニメーション再生
                              _animationController.reset();
                              _animationController.forward();
                            });
                            // ハプティックフィードバック
                            HapticFeedback.selectionClick();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 日別チャート（タイプによって表示切替）
            Container(
              height: 200,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  // アニメーション値
                  final animValue = _animation.value;

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _chartDisplayType == 'bar'
                        ? _buildDailyBarChart(context, dailyData, animValue)
                        : _buildDailyLineChart(context, dailyData, animValue),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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

  // グラフタイプ切替ボタン
  Widget _buildChartTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 日別棒グラフ
  Widget _buildDailyBarChart(
      BuildContext context, List<Map<String, dynamic>> data, double animValue) {
    // ズームレベルに応じたアイテム幅を計算
    final itemWidth = 50.0 * _zoomLevel;

    return Container(
      key: const ValueKey('bar_chart'),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final date = item['date'] as DateTime;
          final income = item['income'] as int;
          final expense = item['expense'] as int;
          final balance = item['balance'] as int;

          // 最大値を計算（グラフの高さ調整用）
          final maxValue = math.max(income, expense);
          const maxHeight = 140.0;

          // 高さを計算（アニメーション付き）
          final incomeHeight = maxValue > 0
              ? (income / maxValue) * maxHeight * 0.8 * animValue
              : 0.0;
          final expenseHeight = maxValue > 0
              ? (expense / maxValue) * maxHeight * 0.8 * animValue
              : 0.0;

          return GestureDetector(
            onTap: () {
              // 日付の取引詳細を表示
              _showDailyTransactions(context, date, income, expense, balance);
            },
            child: Container(
              width: itemWidth,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  // 日付
                  Text(
                    '${date.day}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),

                  // バーグラフ
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // バー表示
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 収入バー
                            if (income > 0)
                              Container(
                                width: 12,
                                height: incomeHeight,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(3),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 4),

                            // 支出バー
                            if (expense > 0)
                              Container(
                                width: 12,
                                height: expenseHeight,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(3),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // 基準線
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),

                  // 残高マーカー（収支差額）
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: balance >= 0 ? Colors.blue[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      balance >= 0
                          ? '+${NumberFormat('#,##0').format(balance)}'
                          : '${NumberFormat('#,##0').format(balance)}',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color:
                            balance >= 0 ? Colors.blue[800] : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 日別線グラフ
  Widget _buildDailyLineChart(
      BuildContext context, List<Map<String, dynamic>> data, double animValue) {
    // 最大値を計算（スケーリング用）
    int maxIncome = 0;
    int maxExpense = 0;

    for (var item in data) {
      maxIncome = math.max(maxIncome, item['income'] as int);
      maxExpense = math.max(maxExpense, item['expense'] as int);
    }

    final maxValue = math.max(maxIncome, maxExpense).toDouble();
    const chartHeight = 160.0;

    // 収入データポイントを準備
    final incomeSpots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final income = data[i]['income'] as int;
      if (income > 0) {
        incomeSpots.add(FlSpot(
          i.toDouble(),
          (income / maxValue) * 10 * animValue, // 0-10のスケールに正規化
        ));
      }
    }

    // 支出データポイントを準備
    final expenseSpots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final expense = data[i]['expense'] as int;
      if (expense > 0) {
        expenseSpots.add(FlSpot(
          i.toDouble(),
          (expense / maxValue) * 10 * animValue, // 0-10のスケールに正規化
        ));
      }
    }

    // 横スクロール可能なコンテナで包む
    return Container(
      key: const ValueKey('line_chart'),
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          // ズーム率に基づいて幅を設定
          width: math.max(
              MediaQuery.of(context).size.width, data.length * 20 * _zoomLevel),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 2,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      // インデックスが整数かどうかをチェック
                      if (value.toInt() == value &&
                          value.toInt() >= 0 &&
                          value.toInt() < data.length) {
                        final date = data[value.toInt()]['date'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  left: BorderSide(color: Colors.grey[300]!, width: 1),
                  right: BorderSide(color: Colors.transparent),
                  top: BorderSide(color: Colors.transparent),
                ),
              ),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              maxY: 10,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                ),
                touchCallback:
                    (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent &&
                      touchResponse?.lineBarSpots != null &&
                      touchResponse!.lineBarSpots!.isNotEmpty) {
                    // タップされたデータポイントのインデックスを取得
                    final index = touchResponse.lineBarSpots!.first.x.toInt();
                    if (index >= 0 && index < data.length) {
                      final item = data[index];
                      _showDailyTransactions(
                        context,
                        item['date'] as DateTime,
                        item['income'] as int,
                        item['expense'] as int,
                        item['balance'] as int,
                      );
                    }
                  }
                },
              ),
              lineBarsData: [
                // 収入ライン
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: Colors.green,
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withOpacity(0.1),
                  ),
                ),
                // 支出ライン
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: Colors.red,
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 日付別取引詳細を表示
  void _showDailyTransactions(BuildContext context, DateTime date, int income,
      int expense, int balance) {
    final currencyFormat = NumberFormat("#,##0", "ja_JP");
    final dateFormat = DateFormat('yyyy年M月d日', 'ja_JP');

    // モック取引リストを生成
    final random = math.Random();
    final transactions = <Map<String, dynamic>>[];

    // 収入取引があれば生成
    if (income > 0) {
      final transactionAmount = income;
      transactions.add({
        'id': 'income_0',
        'date': date,
        'description': '売上取引',
        'amount': transactionAmount,
        'category': '売上',
        'paymentMethod': _getRandomPaymentMethod(random),
      });
    }

    // 支出取引があれば生成
    if (expense > 0) {
      final expenseCategories = [
        '交通費',
        '通信費',
        '消耗品費',
        '会議費',
      ];

      final category =
          expenseCategories[random.nextInt(expenseCategories.length)];
      transactions.add({
        'id': 'expense_0',
        'date': date,
        'description': '$category 支出',
        'amount': -expense,
        'category': category,
        'paymentMethod': _getRandomPaymentMethod(random),
      });
    }

    // ダイアログを表示
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 収支サマリー
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: balance >= 0 ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // 収入
                      Column(
                        children: [
                          const Text(
                            '収入',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '¥${currencyFormat.format(income)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // 支出
                      Column(
                        children: [
                          const Text(
                            '支出',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '¥${currencyFormat.format(expense)}',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // 残高
                      Column(
                        children: [
                          const Text(
                            '収支',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '${balance >= 0 ? '+' : ''}¥${currencyFormat.format(balance)}',
                            style: TextStyle(
                              color: balance >= 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 取引リストタイトル
                const Text(
                  '取引リスト',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // 取引リスト
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
                          child: Text(
                            '取引はありません',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : ListView.separated(
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            final amount = transaction['amount'] as int;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: amount > 0
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                child: Icon(
                                  amount > 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: amount > 0 ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                              ),
                              title: Text(
                                transaction['description'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                transaction['paymentMethod'] as String,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              trailing: Text(
                                '${amount > 0 ? '+' : ''}¥${currencyFormat.format(amount.abs())}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: amount > 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // カテゴリー分析タブを構築
  Widget _buildCategoryTabs(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // タブバー
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_tabController.index == 0 
                            ? Icons.pie_chart 
                            : Icons.pie_chart_outline,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text('支出分析'),
                        ],
                      ),
                      height: 44,
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_tabController.index == 1 
                            ? Icons.trending_up 
                            : Icons.trending_up_outlined,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text('収入分析'),
                        ],
                      ),
                      height: 44,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // タブコンテンツ
            SizedBox(
              height: 350,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 支出分析タブ
                  _buildExpenseAnalysisTab(context),

                  // 収入分析タブ
                  _buildIncomeAnalysisTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 支出分析タブ
  Widget _buildExpenseAnalysisTab(BuildContext context) {
    // 支出カテゴリーを取得
    final categories = _reportData['expenseCategories'] as List<dynamic>;

    // 支出合計
    final totalExpense =
        categories.fold<int>(0, (sum, item) => sum + (item['amount'] as int));

    // 各カテゴリーにパーセント値を追加
    for (var category in categories) {
      category['percentage'] = (category['amount'] as int) / totalExpense * 100;
    }

    // 金額降順にソート
    categories
        .sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));

    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 円グラフ
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 円グラフ
                      CustomPaint(
                        painter: PieChartPainter(
                          categories: categories,
                          animation: _animation.value,
                        ),
                        size: const Size(180, 180),
                      ),

                      // 中央のテキスト
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '支出合計',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '¥${NumberFormat('#,###').format(totalExpense)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // カテゴリーリスト
                ...categories
                    .map((category) => _buildCategoryListItem(
                        context, category, totalExpense, _animation.value))
                    .toList(),
              ],
            ),
          );
        });
  }

  // 収入分析タブ
  Widget _buildIncomeAnalysisTab(BuildContext context) {
    // 収入カテゴリーを取得
    final categories = _reportData['incomeCategories'] as List<dynamic>;

    // 収入合計
    final totalIncome =
        categories.fold<int>(0, (sum, item) => sum + (item['amount'] as int));

    // 各カテゴリーにパーセント値を追加
    for (var category in categories) {
      category['percentage'] = (category['amount'] as int) / totalIncome * 100;
    }

    // 金額降順にソート
    categories
        .sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));

    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 円グラフ
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 円グラフ
                      CustomPaint(
                        painter: PieChartPainter(
                          categories: categories,
                          animation: _animation.value,
                        ),
                        size: const Size(180, 180),
                      ),

                      // 中央のテキスト
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '収入合計',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '¥${NumberFormat('#,###').format(totalIncome)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // カテゴリーリスト
                ...categories
                    .map((category) => _buildCategoryListItem(
                        context, category, totalIncome, _animation.value))
                    .toList(),
              ],
            ),
          );
        });
  }

  // カテゴリーリストアイテム
  Widget _buildCategoryListItem(BuildContext context,
      Map<String, dynamic> category, int total, double animValue) {
    final currencyFormat = NumberFormat("#,##0", "ja_JP");
    final percentage = category['percentage'] as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          // カテゴリー行
          InkWell(
            onTap: () {
              // カテゴリー詳細を表示
              _showCategoryDetails(context, category);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
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
                    '¥${currencyFormat.format(category['amount'])}',
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
            ),
          ),
          const SizedBox(height: 4),
          // プログレスバー（アニメーション付き）
          LinearProgressIndicator(
            value: (percentage / 100) * animValue,
            backgroundColor: Colors.grey[200],
            valueColor:
                AlwaysStoppedAnimation<Color>(category['color'] as Color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  // カテゴリー詳細ダイアログ
  void _showCategoryDetails(
      BuildContext context, Map<String, dynamic> category) {
    final currencyFormat = NumberFormat("#,##0", "ja_JP");

    // モック取引リスト
    final random = math.Random();
    final transactions = List.generate(
      3 + random.nextInt(5), // 3～7個の取引
      (index) {
        final day = 1 +
            random.nextInt(
                DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day);
        return {
          'id': 'tx_$index',
          'date': DateTime(_selectedMonth.year, _selectedMonth.month, day),
          'description': '${category['name']} ${index + 1}',
          'amount': category['name'] == '売上' || category['name'] == '雑収入'
              ? (category['amount'] as int) ~/ (3 + random.nextInt(5))
              : -((category['amount'] as int) ~/ (3 + random.nextInt(5))),
          'paymentMethod': _getRandomPaymentMethod(random),
        };
      },
    );

    // 取引日順にソート
    transactions.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ヘッダー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: category['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category['name'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  // 金額情報
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '合計金額',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '¥${currencyFormat.format(category['amount'])}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                '全体比率',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(category['percentage'] as double).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: category['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 取引リストタイトル
                  const Text(
                    '取引履歴',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 取引リスト
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final amount = transaction['amount'] as int;

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: amount > 0
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            child: Icon(
                              amount > 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: amount > 0 ? Colors.green : Colors.red,
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
                                DateFormat('M/d', 'ja_JP')
                                    .format(transaction['date'] as DateTime),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                transaction['paymentMethod'] as String,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${amount > 0 ? '+' : ''}¥${currencyFormat.format(amount.abs())}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: amount > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ランダムな支払方法を取得
  String _getRandomPaymentMethod(math.Random random) {
    final methods = [
      'クレジットカード',
      '銀行振込',
      '現金',
      'QR決済',
      '口座引落',
    ];
    return methods[random.nextInt(methods.length)];
  }
}

// グラフ用のグリッド描画
class ChartGridPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final double animation;
  final double zoomLevel;

  ChartGridPainter({
    required this.data,
    required this.maxValue,
    required this.animation,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // 横線を描画（Y軸の目盛り線）
    final numHorizontalLines = 4;
    for (int i = 0; i <= numHorizontalLines; i++) {
      final y = size.height - (size.height / numHorizontalLines * i);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 縦線を描画（各日のマーカー）
    final itemWidth = 20 * zoomLevel;
    for (int i = 0; i < data.length; i++) {
      final x = i * itemWidth + (itemWidth / 2);
      // 薄い縦線
      final linePaint = Paint()
        ..color = Colors.grey[200]!
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);

      // 日付ラベル
      final date = data[i]['date'] as DateTime;
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${date.day}',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, size.height + 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// 線グラフ描画
class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final String valueKey;
  final Color color;
  final double animation;
  final double zoomLevel;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.valueKey,
    required this.color,
    required this.animation,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = color;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final itemWidth = 20 * zoomLevel;
    final path = Path();
    final fillPath = Path();

    // 最初の点を設定
    var startX = 0.0;
    var startY = size.height;
    var firstPointWithValue = -1;

    for (var i = 0; i < data.length; i++) {
      final value = data[i][valueKey] as int;
      if (value > 0) {
        firstPointWithValue = i;
        startX = i * itemWidth + (itemWidth / 2);
        startY = size.height - (value / maxValue * size.height * animation);
        break;
      }
    }

    if (firstPointWithValue == -1) {
      // データがない場合は何も描画しない
      return;
    }

    // 最初の点を設定
    path.moveTo(startX, startY);
    fillPath.moveTo(startX, size.height);
    fillPath.lineTo(startX, startY);

    // 折れ線を描画
    for (var i = firstPointWithValue + 1; i < data.length; i++) {
      final value = data[i][valueKey] as int;
      final x = i * itemWidth + (itemWidth / 2);

      if (value > 0) {
        final y = size.height - (value / maxValue * size.height * animation);
        path.lineTo(x, y);
        fillPath.lineTo(x, y);

        // ポイントを描画
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }

    // 塗りつぶしパスを閉じる
    fillPath.lineTo(
        (data.length - 1) * itemWidth + (itemWidth / 2), size.height);
    fillPath.close();

    // 塗りつぶしを先に描画
    canvas.drawPath(fillPath, fillPaint);

    // 線を描画
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// 円グラフの描画
class PieChartPainter extends CustomPainter {
  final List<dynamic> categories;
  final double animation;

  PieChartPainter({
    required this.categories,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 合計を計算
    double total = 0;
    for (var category in categories) {
      total += (category['amount'] as int).toDouble();
    }

    // スタート角度
    double startAngle = -math.pi / 2;

    // 円グラフを描画
    for (var category in categories) {
      final value = (category['amount'] as int).toDouble();
      final sweepAngle = (value / total) * 2 * math.pi * animation;

      final paint = Paint()
        ..color = category['color'] as Color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // 境界線
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(rect, startAngle, sweepAngle, true, borderPaint);

      // カテゴリー名のラベルを表示（大きなセグメントのみ）
      if (value / total > 0.1) {
        // 10%以上のセグメントにのみラベルを表示
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = radius * 0.7; // 中心からの距離調整
        final labelPos = Offset(
          center.dx + labelRadius * math.cos(midAngle),
          center.dy + labelRadius * math.sin(midAngle),
        );

        // ラベルテキスト
        final percentage = (value / total * 100).toStringAsFixed(0);
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();

        // ラベル位置を調整（テキストが中央に来るように）
        final textPos = Offset(
          labelPos.dx - textPainter.width / 2,
          labelPos.dy - textPainter.height / 2,
        );

        textPainter.paint(canvas, textPos);
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
