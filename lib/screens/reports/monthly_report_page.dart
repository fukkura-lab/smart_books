import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_books/blocs/reports/monthly_report_controller.dart';
import 'package:smart_books/config/theme.dart';
import 'package:smart_books/models/reports/monthly_report_models.dart';
import 'package:smart_books/widgets/reports/report_widgets.dart';
import 'package:smart_books/widgets/reports/report_dialogs.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({Key? key}) : super(key: key);

  @override
  _MonthlyReportPageState createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MonthlyReportController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // タブ変更時のリスナー
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _controller.currentTabIndex = _tabController.index;
        });
      }
    });
    
    // コントローラーの初期化
    _controller = MonthlyReportController();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    await _controller.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 月選択ダイアログを表示
  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _controller.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      locale: const Locale('ja', 'JP'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.secondaryColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      await _controller.changeMonth(DateTime(picked.year, picked.month, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<MonthlyReportController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('月別詳細レポート'),
              backgroundColor: AppTheme.primaryColor,
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.arrow_downward), text: '支出分析'),
                  Tab(icon: Icon(Icons.arrow_upward), text: '収入分析'),
                ],
                indicatorColor: AppTheme.accentColor,
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: () => _selectMonth(context),
                  tooltip: '月を選択',
                ),
              ],
            ),
            body: controller.isLoading
              ? _buildLoadingView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // 支出分析タブ
                    _buildExpenseAnalysisTab(controller),
                    
                    // 収入分析タブ
                    _buildIncomeAnalysisTab(controller),
                  ],
                ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.share),
              onPressed: () {
                // レポート共有機能
                controller.shareReport();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('レポートを共有しました'))
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ローディング中のビュー
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text('データを読み込んでいます...'),
        ],
      ),
    );
  }

  // 支出分析タブの内容
  Widget _buildExpenseAnalysisTab(MonthlyReportController controller) {
    final summary = controller.monthlySummary;
    
    if (summary == null) {
      return Center(child: Text('データがありません'));
    }
    
    return RefreshIndicator(
      onRefresh: () => controller.fetchMonthData(controller.selectedMonth),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 月選択
            MonthSelector(
              selectedDate: controller.selectedMonth,
              onMonthChanged: controller.changeMonth,
              onTap: () => _selectMonth(context),
            ),
            
            // 支出サマリー
            SummaryCard(
              title: '今月の支出合計',
              amount: summary.totalExpense,
              previousAmount: summary.previousMonthExpense,
              changePercentage: summary.expenseChangePercentage,
              budgetAmount: summary.budgetAmount,
              budgetPercentage: summary.budgetPercentage,
              isExpense: true,
            ),
            
            // 支出内訳の円グラフ
            GestureDetector(
              onTap: () {
                _showCategorySelectionDialog(summary.expenseCategories, true);
              },
              child: PieChartSection(
                categories: summary.expenseCategories,
                title: '支出内訳',
                isExpense: true,
              ),
            ),
            
            // 過去6ヶ月のトレンドチャート
            TrendChartSection(
              trendData: controller.trendData,
              title: '6ヶ月間のトレンド',
            ),
            
            // 支出取引リスト
            TransactionListSection(
              transactions: controller.expenseTransactions,
              title: '支出取引一覧',
              isExpense: true,
              onItemTap: (transaction) {
                _showTransactionDetailDialog(
                  transaction, 
                  controller.getSimilarTransactions(transaction, 3)
                );
              },
              onViewAll: () {
                // すべての取引を表示する画面へ遷移
                _showAllTransactionsDialog(controller.expenseTransactions, true);
              },
            ),
            
            SizedBox(height: 80), // フローティングボタンの下部スペース
          ],
        ),
      ),
    );
  }

  // 収入分析タブの内容
  Widget _buildIncomeAnalysisTab(MonthlyReportController controller) {
    final summary = controller.monthlySummary;
    
    if (summary == null) {
      return Center(child: Text('データがありません'));
    }
    
    return RefreshIndicator(
      onRefresh: () => controller.fetchMonthData(controller.selectedMonth),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 月選択
            MonthSelector(
              selectedDate: controller.selectedMonth,
              onMonthChanged: controller.changeMonth,
              onTap: () => _selectMonth(context),
            ),
            
            // 収入サマリー
            SummaryCard(
              title: '今月の収入合計',
              amount: summary.totalIncome,
              previousAmount: summary.previousMonthIncome,
              changePercentage: summary.incomeChangePercentage,
              // 収入には予算ではなく目標を表示
              budgetAmount: summary.totalIncome * 1.2, // 目標は現在の120%とする
              budgetPercentage: 100 / 1.2, // 現在の進捗（83.3%）
              isExpense: false,
            ),
            
            // 収入内訳の円グラフ
            GestureDetector(
              onTap: () {
                _showCategorySelectionDialog(summary.incomeCategories, false);
              },
              child: PieChartSection(
                categories: summary.incomeCategories,
                title: '収入内訳',
                isExpense: false,
              ),
            ),
            
            // 過去6ヶ月のトレンドチャート
            TrendChartSection(
              trendData: controller.trendData,
              title: '6ヶ月間のトレンド',
            ),
            
            // 収入取引リスト
            TransactionListSection(
              transactions: controller.incomeTransactions,
              title: '収入取引一覧',
              isExpense: false,
              onItemTap: (transaction) {
                _showTransactionDetailDialog(
                  transaction, 
                  controller.getSimilarTransactions(transaction, 3)
                );
              },
              onViewAll: () {
                // すべての取引を表示する画面へ遷移
                _showAllTransactionsDialog(controller.incomeTransactions, false);
              },
            ),
            
            SizedBox(height: 80), // フローティングボタンの下部スペース
          ],
        ),
      ),
    );
  }

  // カテゴリ選択ダイアログを表示
  void _showCategorySelectionDialog(List<CategorySummary> categories, bool isExpense) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'カテゴリを選択',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color,
                        child: Icon(
                          isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      title: Text(category.category),
                      subtitle: Text('¥${NumberFormat('#,###').format(category.amount)}'),
                      trailing: Text('${category.percentage.toStringAsFixed(1)}%'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _showCategoryDetailDialog(category, isExpense);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('閉じる'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 取引詳細ダイアログを表示
  void _showTransactionDetailDialog(Transaction transaction, List<Transaction> similarTransactions) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(
        transaction: transaction,
        similarTransactions: similarTransactions,
      ),
    );
  }

  // カテゴリ詳細ダイアログを表示
  void _showCategoryDetailDialog(CategorySummary category, bool isExpense) {
    final transactions = _controller.getTransactionsByCategory(category.category, isExpense);
    
    showDialog(
      context: context,
      builder: (context) => CategoryDetailDialog(
        category: category,
        transactions: transactions,
        isExpense: isExpense,
      ),
    );
  }

  // すべての取引リストを表示するダイアログ
  void _showAllTransactionsDialog(List<Transaction> transactions, bool isExpense) {
    final title = isExpense ? '支出取引一覧' : '収入取引一覧';
    final transactionsCopy = List<Transaction>.from(transactions);
    
    // 日付で並べ替え
    transactionsCopy.sort((a, b) => b.date.compareTo(a.date));
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: transactions.isEmpty
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
                      itemCount: transactionsCopy.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        final transaction = transactionsCopy[index];
                        return TransactionListItem(
                          transaction: transaction,
                          isExpense: isExpense,
                          onTap: () {
                            Navigator.of(context).pop();
                            _showTransactionDetailDialog(
                              transaction,
                              _controller.getSimilarTransactions(transaction, 3),
                            );
                          },
                        );
                      },
                    ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('閉じる'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
