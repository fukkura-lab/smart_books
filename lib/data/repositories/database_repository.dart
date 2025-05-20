import 'package:smart_books/utils/database_helper.dart';

/// データベースとのやり取りを抽象化するリポジトリクラス
/// 現時点では実装されていないが、将来的な実装に備えて準備
abstract class Repository<T> {
  final DatabaseHelper _db = DatabaseHelper();
  
  /// テーブル名を取得
  String get tableName;
  
  /// モデルをMap形式に変換
  Map<String, dynamic> toMap(T item);
  
  /// Map形式からモデルを作成
  T fromMap(Map<String, dynamic> map);
  
  /// アイテムを取得
  Future<T?> getById(int id) async {
    try {
      final results = await _db.query(
        'SELECT * FROM $tableName WHERE id = @id',
        {'id': id},
      );
      
      if (results.isNotEmpty) {
        return fromMap(results.first);
      }
      
      return null;
    } catch (e) {
      print('$tableName - getById エラー: $e');
      return null;
    }
  }
  
  /// すべてのアイテムを取得
  Future<List<T>> getAll() async {
    try {
      final results = await _db.query('SELECT * FROM $tableName');
      return results.map((map) => fromMap(map)).toList();
    } catch (e) {
      print('$tableName - getAll エラー: $e');
      return [];
    }
  }
  
  /// アイテムを保存（挿入または更新）
  Future<int> save(T item) async {
    try {
      final map = toMap(item);
      final id = map['id'];
      
      if (id == null) {
        // ID がなければ新規作成
        return await _db.insert(tableName, map);
      } else {
        // ID があれば更新
        return await _db.update(
          tableName,
          map,
          'id = @id',
          {'id': id},
        );
      }
    } catch (e) {
      print('$tableName - save エラー: $e');
      return -1;
    }
  }
  
  /// アイテムを削除
  Future<bool> delete(int id) async {
    try {
      final rowsAffected = await _db.delete(
        tableName,
        'id = @id',
        {'id': id},
      );
      return rowsAffected > 0;
    } catch (e) {
      print('$tableName - delete エラー: $e');
      return false;
    }
  }
  
  /// カスタムクエリを実行
  Future<List<T>> query(String sql, [Map<String, dynamic>? parameters]) async {
    try {
      final results = await _db.query(sql, parameters);
      return results.map((map) => fromMap(map)).toList();
    } catch (e) {
      print('$tableName - query エラー: $e');
      return [];
    }
  }
}

/// 取引リポジトリの実装例（将来的な実装に備えて）
class TransactionRepository extends Repository<Transaction> {
  @override
  String get tableName => 'transactions';
  
  @override
  Map<String, dynamic> toMap(Transaction item) {
    return {
      'id': item.id,
      'amount': item.amount,
      'description': item.description,
      'date': item.date.toIso8601String(),
      'category': item.category,
    };
  }
  
  @override
  Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      category: map['category'],
    );
  }
  
  /// 日付範囲によるトランザクションの取得
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    return await query(
      'SELECT * FROM $tableName WHERE date BETWEEN @start AND @end ORDER BY date DESC',
      {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      },
    );
  }
  
  /// カテゴリーによるトランザクションの取得
  Future<List<Transaction>> getByCategory(String category) async {
    return await query(
      'SELECT * FROM $tableName WHERE category = @category ORDER BY date DESC',
      {'category': category},
    );
  }
}

/// Transaction モデルクラス
class Transaction {
  final int? id;
  final double amount;
  final String description;
  final DateTime date;
  final String category;
  
  Transaction({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });
}
