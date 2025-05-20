import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_books/models/account_category.dart';
import 'package:smart_books/screens/account_management/account_category_edit_screen.dart';

class AccountCategoryDetailScreen extends StatelessWidget {
  final AccountCategory category;

  const AccountCategoryDetailScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('勘定科目詳細'),
        backgroundColor: primaryColor,
        actions: [
          // 編集ボタン
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCategory(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                // アイコン
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(category.type),
                      color: _getCategoryColor(category.type),
                      size: 32,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16.0),
                
                // 名前とコード
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.tag,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'コード: ${category.code}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24.0),
            
            // タイプ
            _buildInfoSection(
              context: context,
              title: '種類',
              content: _getCategoryTypeText(category.type),
              icon: Icons.category,
              color: _getCategoryColor(category.type),
            ),
            
            // 説明
            _buildInfoSection(
              context: context,
              title: '説明',
              content: category.description.isEmpty
                  ? '(説明はありません)'
                  : category.description,
              icon: Icons.description,
              color: Colors.blueGrey,
            ),
            
            // ステータス
            _buildInfoSection(
              context: context,
              title: 'ステータス',
              content: category.isActive ? '有効' : '無効',
              icon: Icons.toggle_on,
              color: category.isActive ? Colors.green : Colors.grey,
            ),
            
            const SizedBox(height: 32.0),
            
            // 取引履歴セクション（サンプル - 実際はデータベースから取得）
            _buildTransactionHistory(context),
            
            const SizedBox(height: 32.0),
          ],
        ),
      ),
      // 削除ボタン
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton.icon(
            onPressed: () => _deleteCategory(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('勘定科目を削除'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 情報セクションを構築
  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションタイトル
          Row(
            children: [
              Icon(
                icon,
                size: 18.0,
                color: color,
              ),
              const SizedBox(width: 8.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8.0),
          
          // コンテンツ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 取引履歴セクションを構築（サンプル）
  Widget _buildTransactionHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '取引履歴',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16.0),
        
        // サンプルデータ - 実際はデータベースから取得
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '取引履歴はありません',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 勘定科目の編集
  void _editCategory(BuildContext context) async {
    final result = await Navigator.push<AccountCategory>(
      context,
      MaterialPageRoute(
        builder: (context) => AccountCategoryEditScreen(
          category: category,
          categoryType: category.type,
        ),
      ),
    );
    
    if (result != null) {
      // 更新が完了したら前の画面に戻る
      Navigator.pop(context, result);
    }
  }

  // 勘定科目の削除
  void _deleteCategory(BuildContext context) async {
    // 削除確認ダイアログ
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('勘定科目を削除'),
        content: Text('${category.name}を削除してもよろしいですか？\nこの操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    ) ?? false;
    
    if (shouldDelete) {
      // 確認したら前の画面に戻って削除
      Navigator.pop(context, 'delete');
      
      // 削除完了後の触覚フィードバック
      HapticFeedback.mediumImpact();
    }
  }

  // 勘定科目タイプに応じたテキストを取得
  String _getCategoryTypeText(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return '資産';
      case AccountType.liability:
        return '負債';
      case AccountType.income:
        return '収益';
      case AccountType.expense:
        return '費用';
    }
  }

  // 勘定科目タイプに応じた色を取得
  Color _getCategoryColor(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return Colors.blue;
      case AccountType.liability:
        return Colors.purple;
      case AccountType.income:
        return Colors.green;
      case AccountType.expense:
        return Colors.orange;
    }
  }

  // 勘定科目タイプに応じたアイコンを取得
  IconData _getCategoryIcon(AccountType type) {
    switch (type) {
      case AccountType.asset:
        return Icons.account_balance_wallet;
      case AccountType.liability:
        return Icons.money_off;
      case AccountType.income:
        return Icons.trending_up;
      case AccountType.expense:
        return Icons.trending_down;
    }
  }
}
