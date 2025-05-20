import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction/transaction.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  
  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 金額フォーマッター
    final formatCurrency = NumberFormat.currency(
      locale: 'ja_JP',
      symbol: '¥',
      decimalDigits: 0,
    );
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // カテゴリーアイコン
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getCategoryColor(transaction.category).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category),
                  color: _getCategoryColor(transaction.category),
                ),
              ),
              const SizedBox(width: 16),
              
              // 取引情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          transaction.category,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(transaction.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (transaction.paymentMethod != null)
                      Row(
                        children: [
                          Icon(
                            _getPaymentMethodIcon(transaction.paymentMethod!),
                            size: 12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            transaction.paymentMethod!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // 金額
              Text(
                formatCurrency.format(transaction.amount.abs()),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transaction.isExpense ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
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
  
  // カテゴリーに基づいたアイコンを取得
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
      case '食費':
        return Icons.restaurant;
      case '住居費':
        return Icons.home;
      case '光熱費':
        return Icons.lightbulb;
      case '娯楽':
        return Icons.movie;
      case '医療費':
        return Icons.local_hospital;
      case '給与':
        return Icons.work;
      default:
        return Icons.category;
    }
  }
  
  // カテゴリーに基づいた色を取得
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case '売上':
        return Colors.green;
      case '交通費':
        return Colors.blue;
      case '通信費':
        return Colors.purple;
      case '消耗品費':
        return Colors.orange;
      case '会議費':
        return Colors.teal;
      case '食費':
        return Colors.orange;
      case '住居費':
        return Colors.brown;
      case '光熱費':
        return Colors.amber;
      case '娯楽':
        return Colors.pink;
      case '医療費':
        return Colors.red;
      case '給与':
        return Colors.green;
      default:
        return Colors.grey;
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
}
