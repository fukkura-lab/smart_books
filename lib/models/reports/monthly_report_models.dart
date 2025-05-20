import 'package:flutter/material.dart';
import 'package:smart_books/config/theme.dart';
import 'dart:math';

// 取引データモデル
class Transaction {
  final String id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String? paymentMethod;
  final String? memo;

  Transaction({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    required this.isExpense,
    this.paymentMethod,
    this.memo,
  });

  // JSONからのファクトリコンストラクタ
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      isExpense: json['isExpense'] as bool,
      paymentMethod: json['paymentMethod'] as String?,
      memo: json['memo'] as String?,
    );
  }

  // JSONへの変換メソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
      'paymentMethod': paymentMethod,
      'memo': memo,
    };
  }
}

// カテゴリ集計データ
class CategorySummary {
  final String category;
  final double amount;
  final Color color;
  final double percentage;
  final double previousMonthAmount;
  final double changePercentage;

  CategorySummary({
    required this.category,
    required this.amount,
    required this.color,
    required this.percentage,
    required this.previousMonthAmount,
    required this.changePercentage,
  });
}

// 月次集計データ
class MonthlySummary {
  final DateTime month;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final double budgetAmount;
  final double budgetPercentage;
  final double previousMonthIncome;
  final double previousMonthExpense;
  final double incomeChangePercentage;
  final double expenseChangePercentage;
  final List<CategorySummary> expenseCategories;
  final List<CategorySummary> incomeCategories;

  MonthlySummary({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.budgetAmount,
    required this.budgetPercentage,
    required this.previousMonthIncome,
    required this.previousMonthExpense,
    required this.incomeChangePercentage,
    required this.expenseChangePercentage,
    required this.expenseCategories,
    required this.incomeCategories,
  });
}

// 月次トレンドデータ
class MonthlyTrend {
  final String month; // 表示用の月名 (例: '1月')
  final DateTime date; // 実際の日付
  final double income;
  final double expense;
  final double balance;

  MonthlyTrend({
    required this.month,
    required this.date,
    required this.income,
    required this.expense,
    required this.balance,
  });
}

// カテゴリと色の対応を提供するクラス
class CategoryColors {
  // 支出カテゴリーのカラーマップ
  static final Map<String, Color> expenseCategoryColors = {
    '食費': Colors.redAccent,
    '住居費': Colors.blueAccent,
    '光熱費': Colors.orangeAccent,
    '交通費': Colors.purpleAccent,
    '娯楽費': Colors.greenAccent,
    '教育費': Colors.amberAccent,
    '医療費': Colors.pinkAccent,
    '保険料': Colors.cyanAccent,
    '通信費': Colors.deepPurpleAccent,
    '衣服費': Colors.tealAccent,
    'その他': Colors.grey,
  };
  
  // 収入カテゴリーのカラーマップ
  static final Map<String, Color> incomeCategoryColors = {
    '給与': Colors.greenAccent,
    '副業': Colors.blueAccent,
    '投資': Colors.purpleAccent,
    '年金': Colors.amberAccent,
    '贈与': Colors.pinkAccent,
    'その他': Colors.grey,
  };
  
  // カテゴリーに対応する色を取得
  static Color getColorForCategory(String category, bool isExpense) {
    if (isExpense) {
      return expenseCategoryColors[category] ?? Colors.grey;
    } else {
      return incomeCategoryColors[category] ?? Colors.grey;
    }
  }
}

// モックデータを生成するサービスクラス
class MonthlyReportService {
  // 指定された月の集計データを取得
  static Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    // 実際にはデータベースやAPIから取得
    // ここではモックデータを返す
    await Future.delayed(Duration(milliseconds: 500));
    
    // 支出カテゴリ
    final expenseCategories = [
      CategorySummary(
        category: '食費',
        amount: 45000,
        color: CategoryColors.getColorForCategory('食費', true),
        percentage: 24.7,
        previousMonthAmount: 42000,
        changePercentage: 7.1,
      ),
      CategorySummary(
        category: '住居費',
        amount: 85000,
        color: CategoryColors.getColorForCategory('住居費', true),
        percentage: 46.6,
        previousMonthAmount: 85000,
        changePercentage: 0,
      ),
      CategorySummary(
        category: '光熱費',
        amount: 15000,
        color: CategoryColors.getColorForCategory('光熱費', true),
        percentage: 8.2,
        previousMonthAmount: 14000,
        changePercentage: 7.1,
      ),
      CategorySummary(
        category: '交通費',
        amount: 12000,
        color: CategoryColors.getColorForCategory('交通費', true),
        percentage: 6.6,
        previousMonthAmount: 13000,
        changePercentage: -7.7,
      ),
      CategorySummary(
        category: '娯楽費',
        amount: 25000,
        color: CategoryColors.getColorForCategory('娯楽費', true),
        percentage: 13.7,
        previousMonthAmount: 23000,
        changePercentage: 8.7,
      ),
    ];
    
    // 収入カテゴリ
    final incomeCategories = [
      CategorySummary(
        category: '給与',
        amount: 280000,
        color: CategoryColors.getColorForCategory('給与', false),
        percentage: 80.0,
        previousMonthAmount: 280000,
        changePercentage: 0,
      ),
      CategorySummary(
        category: '副業',
        amount: 50000,
        color: CategoryColors.getColorForCategory('副業', false),
        percentage: 14.3,
        previousMonthAmount: 40000,
        changePercentage: 25.0,
      ),
      CategorySummary(
        category: '投資',
        amount: 15000,
        color: CategoryColors.getColorForCategory('投資', false),
        percentage: 4.3,
        previousMonthAmount: 12000,
        changePercentage: 25.0,
      ),
      CategorySummary(
        category: 'その他',
        amount: 5000,
        color: CategoryColors.getColorForCategory('その他', false),
        percentage: 1.4,
        previousMonthAmount: 3000,
        changePercentage: 66.7,
      ),
    ];
    
    return MonthlySummary(
      month: month,
      totalIncome: 350000,
      totalExpense: 182000,
      balance: 168000,
      budgetAmount: 200000,
      budgetPercentage: 91.0,
      previousMonthIncome: 335000,
      previousMonthExpense: 177000,
      incomeChangePercentage: 4.5,
      expenseChangePercentage: 2.8,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
    );
  }
  
  // 最近6ヶ月間のトレンドデータを取得
  static Future<List<MonthlyTrend>> getMonthlyTrends(DateTime currentMonth) async {
    // 実際にはデータベースやAPIから取得
    await Future.delayed(Duration(milliseconds: 500));
    
    final List<MonthlyTrend> trends = [];
    
    // 6ヶ月分のデータを作成
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(currentMonth.year, currentMonth.month - i, 1);
      final month = '${date.month}月';
      
      // 収入と支出にランダム性を持たせる
      final baseIncome = 320000.0;
      final baseExpense = 180000.0;
      final randomIncomeVariation = (10000 * (i % 3)) + 30000 * (i % 2);
      final randomExpenseVariation = (5000 * (i % 3)) + 15000 * (i % 2);
      
      final income = baseIncome + randomIncomeVariation;
      final expense = baseExpense + randomExpenseVariation;
      
      trends.add(MonthlyTrend(
        month: month,
        date: date,
        income: income,
        expense: expense,
        balance: income - expense,
      ));
    }
    
    return trends;
  }
  
  // 指定月の取引リストを取得
  static Future<List<Transaction>> getMonthlyTransactions(DateTime month, bool isExpense) async {
    // 実際にはデータベースやAPIから取得
    await Future.delayed(Duration(milliseconds: 500));
    
    final List<Transaction> transactions = [];
    final Random random = Random();
    
    // テスト用のカテゴリ
    final List<String> expenseCategories = ['食費', '住居費', '光熱費', '交通費', '娯楽費'];
    final List<String> incomeCategories = ['給与', '副業', '投資', 'その他'];
    
    // 選択するカテゴリーリスト
    final categories = isExpense ? expenseCategories : incomeCategories;
    
    // カテゴリーごとにいくつかの取引を生成
    for (var category in categories) {
      final transactionCount = random.nextInt(3) + 1; // 1~3件の取引
      
      for (var i = 0; i < transactionCount; i++) {
        final day = random.nextInt(28) + 1; // 1~28日
        final amount = isExpense
            ? (random.nextInt(10) + 1) * 1000.0 // 1,000円〜10,000円
            : (random.nextInt(100) + 10) * 1000.0; // 10,000円〜100,000円
            
        final description = isExpense
            ? '${category}支出 ${i + 1}'
            : '${category}収入 ${i + 1}';
            
        transactions.add(Transaction(
          id: 'txn_${DateTime.now().millisecondsSinceEpoch}_$i',
          category: category,
          description: description,
          amount: amount,
          date: DateTime(month.year, month.month, day),
          isExpense: isExpense,
          paymentMethod: isExpense ? '現金' : '振込',
          memo: '備考: 取引 $i',
        ));
      }
    }
    
    // 日付で並べ替え
    transactions.sort((a, b) => b.date.compareTo(a.date));
    
    return transactions;
  }
}
