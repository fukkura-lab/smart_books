import 'package:equatable/equatable.dart';

/// 勘定科目タイプの列挙型
enum AccountType {
  /// 資産
  asset,
  
  /// 負債
  liability,
  
  /// 収益（収入）
  income,
  
  /// 費用（支出）
  expense,
}

/// 勘定科目モデルクラス
class AccountCategory extends Equatable {
  /// 一意のID
  final String id;
  
  /// 勘定科目コード（例: 101, 501など）
  final String code;
  
  /// 勘定科目名（例: 現金、売掛金、給料手当など）
  final String name;
  
  /// 勘定科目タイプ（資産、負債、収益、費用）
  final AccountType type;
  
  /// 勘定科目の説明
  final String description;
  
  /// 有効/無効フラグ
  final bool isActive;
  
  /// デフォルトのコンストラクタ
  const AccountCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.description = '',
    this.isActive = true,
  });
  
  /// JSONからオブジェクトを生成
  factory AccountCategory.fromJson(Map<String, dynamic> json) {
    return AccountCategory(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      type: _accountTypeFromString(json['type'] as String),
      description: json['description'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
  
  /// オブジェクトからJSONを生成
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type.toString().split('.').last,
      'description': description,
      'is_active': isActive,
    };
  }
  
  /// 文字列からAccountTypeを生成するヘルパーメソッド
  static AccountType _accountTypeFromString(String typeStr) {
    switch (typeStr) {
      case 'asset':
        return AccountType.asset;
      case 'liability':
        return AccountType.liability;
      case 'income':
        return AccountType.income;
      case 'expense':
        return AccountType.expense;
      default:
        throw ArgumentError('Invalid account type: $typeStr');
    }
  }
  
  /// コピーコンストラクタ - 一部のプロパティだけ更新した新しいインスタンスを作成
  AccountCategory copyWith({
    String? id,
    String? code,
    String? name,
    AccountType? type,
    String? description,
    bool? isActive,
  }) {
    return AccountCategory(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
  
  /// 等価性の比較のためのプロパティリスト
  @override
  List<Object?> get props => [id, code, name, type, description, isActive];
}
