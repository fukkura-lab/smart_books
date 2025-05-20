import 'package:flutter/material.dart';
import 'package:smart_books/models/reports/monthly_report_models.dart';

class MonthlyReportController with ChangeNotifier {
  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 収入と支出のデータ
  MonthlySummary? _monthlySummary;
  MonthlySummary? get monthlySummary => _monthlySummary;
  
  List<MonthlyTrend> _trendData = [];
  List<MonthlyTrend> get trendData => _trendData;
  
  List<Transaction> _expenseTransactions = [];
  List<Transaction> get expenseTransactions => _expenseTransactions;
  
  List<Transaction> _incomeTransactions = [];
  List<Transaction> get incomeTransactions => _incomeTransactions;
  
  // タブインデックス
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;
  set currentTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // 初期化
  Future<void> initialize() async {
    await fetchMonthData(_selectedMonth);
  }
  
  // 月を変更
  Future<void> changeMonth(DateTime newMonth) async {
    if (_selectedMonth.year == newMonth.year && _selectedMonth.month == newMonth.month) {
      return; // 同じ月ならば何もしない
    }
    
    _selectedMonth = newMonth;
    notifyListeners();
    
    await fetchMonthData(newMonth);
  }
  
  // 指定された月のデータを取得
  Future<void> fetchMonthData(DateTime month) async {
    _setLoading(true);
    
    try {
      // 月次集計データを取得
      _monthlySummary = await MonthlyReportService.getMonthlySummary(month);
      
      // トレンドデータを取得
      _trendData = await MonthlyReportService.getMonthlyTrends(month);
      
      // 取引データを取得
      _expenseTransactions = await MonthlyReportService.getMonthlyTransactions(month, true);
      _incomeTransactions = await MonthlyReportService.getMonthlyTransactions(month, false);
      
      notifyListeners();
    } catch (e) {
      debugPrint('データ取得エラー: $e');
      // エラーハンドリング（トースト表示など）
    } finally {
      _setLoading(false);
    }
  }
  
  // カテゴリに属する取引を取得
  List<Transaction> getTransactionsByCategory(String category, bool isExpense) {
    final transactions = isExpense ? _expenseTransactions : _incomeTransactions;
    return transactions.where((t) => t.category == category).toList();
  }
  
  // カテゴリの詳細情報を取得
  CategorySummary? getCategorySummary(String category, bool isExpense) {
    if (_monthlySummary == null) return null;
    
    final categories = isExpense 
        ? _monthlySummary!.expenseCategories 
        : _monthlySummary!.incomeCategories;
    
    return categories.firstWhere(
      (c) => c.category == category,
      orElse: () => CategorySummary(
        category: category,
        amount: 0,
        color: CategoryColors.getColorForCategory(category, isExpense),
        percentage: 0,
        previousMonthAmount: 0,
        changePercentage: 0,
      ),
    );
  }
  
  // ローディング状態を設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // 前の月へ
  Future<void> previousMonth() async {
    final newMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
      1,
    );
    await changeMonth(newMonth);
  }
  
  // 次の月へ
  Future<void> nextMonth() async {
    final newMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      1,
    );
    await changeMonth(newMonth);
  }

  // レポート情報を共有（PDFや画像、テキスト形式など）
  Future<void> shareReport() async {
    // 実装については、シェア機能に関するパッケージを使用
    debugPrint('レポート共有機能を呼び出しました');
  }
  
  // 取引詳細ダイアログを表示するための類似取引を取得
  List<Transaction> getSimilarTransactions(Transaction transaction, int limit) {
    final transactions = transaction.isExpense ? _expenseTransactions : _incomeTransactions;
    return transactions
        .where((t) => t.category == transaction.category && t.id != transaction.id)
        .take(limit)
        .toList();
  }
}