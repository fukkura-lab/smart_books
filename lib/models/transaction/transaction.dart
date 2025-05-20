import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String category;
  final bool isExpense;
  final String? paymentMethod;
  final String? documentId;
  final String? note;
  
  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    required this.isExpense,
    this.paymentMethod,
    this.documentId,
    this.note,
  });
  
  // ダッシュボード画面のサンプルデータからTransactionを作成するファクトリメソッド
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? 'trans_${DateTime.now().millisecondsSinceEpoch}',
      amount: (map['amount'] as int).toDouble(),
      description: map['description'] as String,
      date: map['date'] as DateTime,
      category: map['category'] as String,
      isExpense: (map['amount'] as int) < 0,
      paymentMethod: map['paymentMethod'] as String?,
      documentId: map['documentId'] as String?,
      note: map['note'] as String?,
    );
  }
  
  // JSON変換メソッド
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      isExpense: json['isExpense'],
      paymentMethod: json['paymentMethod'],
      documentId: json['documentId'],
      note: json['note'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'category': category,
      'isExpense': isExpense,
      'paymentMethod': paymentMethod,
      'documentId': documentId,
      'note': note,
    };
  }
}
