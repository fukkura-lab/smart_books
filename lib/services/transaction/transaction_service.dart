import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/transaction/transaction.dart';

class TransactionResult {
  final List<Transaction> transactions;
  final bool hasMore;
  
  TransactionResult({
    required this.transactions,
    required this.hasMore,
  });
}

class TransactionService {
  final Dio _dio = Dio();
  final String baseUrl;
  
  // サンプルデータ
  final List<Map<String, dynamic>> _sampleTransactions = [
    {
      'id': 'trans_1',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'description': '取引先A 打ち合わせ費',
      'amount': -5800,
      'category': '交通費',
      'documentId': '3',
      'paymentMethod': 'クレジットカード',
      'note': '新規プロジェクトの打ち合わせ',
    },
    {
      'id': 'trans_2',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'description': 'クライアントB 報酬',
      'amount': 150000,
      'category': '売上',
      'documentId': '2',
      'paymentMethod': '銀行振込',
      'note': 'ウェブサイト制作の報酬',
    },
    {
      'id': 'trans_3',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'オフィス用品',
      'amount': -12500,
      'category': '消耗品費',
      'documentId': '5',
      'paymentMethod': 'クレジットカード',
      'note': 'プリンターのインクとコピー用紙',
    },
    {
      'id': 'trans_4',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'description': '通信費',
      'amount': -8800,
      'category': '通信費',
      'documentId': '6',
      'paymentMethod': '口座引落',
      'note': 'インターネット回線と携帯電話',
    },
    {
      'id': 'trans_5',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'description': 'クライアントC 報酬',
      'amount': 220000,
      'category': '売上',
      'documentId': '2',
      'paymentMethod': '銀行振込',
      'note': 'アプリ開発の中間支払い',
    },
    {
      'id': 'trans_6',
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'description': '飲食代',
      'amount': -3500,
      'category': '食費',
      'documentId': '7',
      'paymentMethod': 'クレジットカード',
      'note': 'クライアントとの食事',
    },
    {
      'id': 'trans_7',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'description': '書籍購入',
      'amount': -2800,
      'category': '消耗品費',
      'documentId': '8',
      'paymentMethod': 'クレジットカード',
      'note': '技術書の購入',
    },
    {
      'id': 'trans_8',
      'date': DateTime.now().subtract(const Duration(days: 12)),
      'description': 'セミナー参加費',
      'amount': -15000,
      'category': '会議費',
      'documentId': '9',
      'paymentMethod': '銀行振込',
      'note': 'マーケティングセミナー',
    },
    {
      'id': 'trans_9',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'description': 'クライアントD 報酬',
      'amount': 85000,
      'category': '売上',
      'documentId': '10',
      'paymentMethod': '銀行振込',
      'note': 'コンサルティング料',
    },
    {
      'id': 'trans_10',
      'date': DateTime.now().subtract(const Duration(days: 18)),
      'description': '事務所家賃',
      'amount': -70000,
      'category': '家賃',
      'documentId': '11',
      'paymentMethod': '口座引落',
      'note': '事務所の月額家賃',
    },
  ];
  
  TransactionService()
      : baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  
  Future<TransactionResult> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? query,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // クエリパラメータの構築
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };
      
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      
      if (filters != null) {
        if (filters['period'] != null) {
          queryParams['period'] = filters['period'];
        }
        
        if (filters['type'] != null) {
          queryParams['type'] = filters['type'];
        }
        
        if (filters['categories'] != null) {
          queryParams['categories'] = filters['categories'].join(',');
        }
      }
      
      // APIがない場合はモックデータを返す
      // 将来的にAPIが実装された場合は、以下のコメントを解除して使用
      /*
      final response = await _dio.get(
        '$baseUrl/transactions',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<Transaction> transactions = (data['items'] as List)
            .map((item) => Transaction.fromJson(item))
            .toList();
        
        return TransactionResult(
          transactions: transactions,
          hasMore: data['hasMore'] ?? false,
        );
      } else {
        throw Exception('Failed to load transactions');
      }
      */
      
      // 検索とフィルターの処理
      List<Map<String, dynamic>> filteredTransactions = _sampleTransactions;
      
      // 検索クエリがある場合
      if (query != null && query.isNotEmpty) {
        filteredTransactions = filteredTransactions
            .where((t) => 
                t['description'].toString().toLowerCase().contains(query.toLowerCase()) ||
                t['category'].toString().toLowerCase().contains(query.toLowerCase()) ||
                t['note'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      
      // フィルターがある場合
      if (filters != null) {
        // 期間フィルター
        if (filters['period'] != null) {
          final now = DateTime.now();
          DateTime? startDate;
          DateTime? endDate;
          
          switch (filters['period']) {
            case 'today':
              startDate = DateTime(now.year, now.month, now.day);
              endDate = now;
              break;
            case 'yesterday':
              final yesterday = now.subtract(const Duration(days: 1));
              startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
              endDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
              break;
            case 'week':
              startDate = now.subtract(Duration(days: now.weekday - 1));
              startDate = DateTime(startDate.year, startDate.month, startDate.day);
              endDate = now;
              break;
            case 'month':
              startDate = DateTime(now.year, now.month, 1);
              endDate = now;
              break;
            case 'year':
              startDate = DateTime(now.year, 1, 1);
              endDate = now;
              break;
          }
          
          if (startDate != null && endDate != null) {
            filteredTransactions = filteredTransactions
                .where((t) => (t['date'] as DateTime).isAfter(startDate!) && 
                              (t['date'] as DateTime).isBefore(endDate!))
                .toList();
          }
        }
        
        // 取引タイプフィルター
        if (filters['type'] != null) {
          switch (filters['type']) {
            case 'income':
              filteredTransactions = filteredTransactions
                  .where((t) => (t['amount'] as int) > 0)
                  .toList();
              break;
            case 'expense':
              filteredTransactions = filteredTransactions
                  .where((t) => (t['amount'] as int) < 0)
                  .toList();
              break;
          }
        }
        
        // カテゴリフィルター
        if (filters['categories'] != null && filters['categories'].isNotEmpty) {
          final categories = filters['categories'] as List<String>;
          filteredTransactions = filteredTransactions
              .where((t) => categories.contains(t['category']))
              .toList();
        }
      }
      
      // ページネーション
      final startIndex = (page - 1) * pageSize;
      final endIndex = startIndex + pageSize;
      
      // ページのデータを取得
      final pagedTransactions = filteredTransactions.length > startIndex
          ? filteredTransactions.sublist(
              startIndex,
              endIndex > filteredTransactions.length ? filteredTransactions.length : endIndex,
            )
          : [];
      
      // Transaction オブジェクトに変換
      final transactions = pagedTransactions
          .map((item) => Transaction.fromMap(item))
          .toList();
      
      return TransactionResult(
        transactions: transactions,
        hasMore: endIndex < filteredTransactions.length,
      );
    } catch (e) {
      print('Transaction service error: $e');
      
      // エラーが発生した場合は空のリストを返す
      return TransactionResult(
        transactions: [],
        hasMore: false,
      );
    }
  }
}
