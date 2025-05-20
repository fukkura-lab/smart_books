import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DocumentLibraryScreen extends StatefulWidget {
  const DocumentLibraryScreen({Key? key}) : super(key: key);

  @override
  State<DocumentLibraryScreen> createState() => _DocumentLibraryScreenState();
}

class _DocumentLibraryScreenState extends State<DocumentLibraryScreen>
    with SingleTickerProviderStateMixin {
  // フィルター状態
  String _selectedFilter = 'すべて';
  final List<String> _filters = ['すべて', '領収書', '請求書', '通帳', 'その他'];

  // 並び替え状態
  String _sortBy = '日付（新しい順）';
  final List<String> _sortOptions = [
    '日付（新しい順）',
    '日付（古い順）',
    '金額（高い順）',
    '金額（低い順）'
  ];

  // 表示モード
  bool _isGridMode = false;

  // 検索クエリ
  String _searchQuery = '';
  
  // 検索欄のフォーカス管理用
  final FocusNode _searchFocusNode = FocusNode();

  // アニメーション関連
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // サンプルデータ
  final List<Map<String, dynamic>> _documents = [
    {
      'id': '1',
      'type': '領収書',
      'title': 'コンビニ購入',
      'amount': 780,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'imagePath': 'assets/images/receipt1.jpg',
      'status': '処理済み',
      'vendor': 'セブンイレブン',
    },
    {
      'id': '2',
      'type': '請求書',
      'title': 'インターネット料金',
      'amount': 5280,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'imagePath': 'assets/images/bill1.jpg',
      'status': '未払い',
      'vendor': '楽天モバイル',
    },
    {
      'id': '3',
      'type': '領収書',
      'title': 'タクシー代',
      'amount': 3200,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'imagePath': 'assets/images/receipt2.jpg',
      'status': '処理済み',
      'vendor': '日本交通',
    },
    {
      'id': '4',
      'type': '通帳',
      'title': '普通預金',
      'amount': null, // 金額なし
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'imagePath': 'assets/images/bankbook1.jpg',
      'status': '記録済み',
      'vendor': '三菱UFJ銀行',
    },
    {
      'id': '5',
      'type': '領収書',
      'title': 'オフィス用品',
      'amount': 12800,
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'imagePath': 'assets/images/receipt3.jpg',
      'status': '処理済み',
      'vendor': 'アスクル',
    },
    {
      'id': '6',
      'type': '請求書',
      'title': '水道料金',
      'amount': 4320,
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'imagePath': 'assets/images/bill2.jpg',
      'status': '支払済み',
      'vendor': '東京都水道局',
    },
    {
      'id': '7',
      'type': 'その他',
      'title': '名刺',
      'amount': null, // 金額なし
      'date': DateTime.now().subtract(const Duration(days: 20)),
      'imagePath': 'assets/images/other1.jpg',
      'status': '保存済み',
      'vendor': 'プリントパック',
    },
    {
      'id': '8',
      'type': '領収書',
      'title': '接待費',
      'amount': 18500,
      'date': DateTime.now().subtract(const Duration(days: 8)),
      'imagePath': 'assets/images/receipt4.jpg',
      'status': '処理済み',
      'vendor': '鮨かねさか',
    },
    {
      'id': '9',
      'type': '領収書',
      'title': '交通費',
      'amount': 1280,
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'imagePath': 'assets/images/receipt5.jpg',
      'status': '未処理',
      'vendor': 'JR東日本',
    },
  ];

  @override
  void initState() {
    super.initState();

    // アニメーションコントローラの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // アニメーションを最初から実行
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchFocusNode.dispose(); // 検索欄のフォーカスノードを破棄
    super.dispose();
  }

  // フィルタリングされた書類のリスト
  List<Map<String, dynamic>> get _filteredDocuments {
    return _documents.where((doc) {
      // タイプフィルター
      if (_selectedFilter != 'すべて' && doc['type'] != _selectedFilter) {
        return false;
      }

      // 検索クエリ
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = doc['title'].toString().toLowerCase();
        final type = doc['type'].toString().toLowerCase();
        final status = doc['status'].toString().toLowerCase();
        final vendor = doc['vendor'].toString().toLowerCase();

        return title.contains(query) ||
            type.contains(query) ||
            status.contains(query) ||
            vendor.contains(query) ||
            (doc['amount'] != null && doc['amount'].toString().contains(query));
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // 並び替え
        switch (_sortBy) {
          case '日付（新しい順）':
            return b['date'].compareTo(a['date']);
          case '日付（古い順）':
            return a['date'].compareTo(b['date']);
          case '金額（高い順）':
            final aAmount = a['amount'] ?? 0;
            final bAmount = b['amount'] ?? 0;
            return bAmount.compareTo(aAmount);
          case '金額（低い順）':
            final aAmount = a['amount'] ?? 0;
            final bAmount = b['amount'] ?? 0;
            return aAmount.compareTo(bAmount);
          default:
            return 0;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      // 画面の任意の場所をタップしたときにフォーカスを外す
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('書類ライブラリ'),
          backgroundColor: primaryColor,
          elevation: 0,
          actions: [
            // グリッド/リスト表示切替
            IconButton(
              icon: Icon(_isGridMode ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridMode = !_isGridMode;
                });
                // 触覚フィードバック
                HapticFeedback.lightImpact();
              },
            ),
            // 並び替えボタン
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _showSortOptions,
            ),
          ],
        ),
        body: Column(
          children: [
            // 検索バー
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: '書類を検索...',
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: primaryColor),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onSubmitted: (_) {
                  // 検索実行時にフォーカスを外す
                  FocusScope.of(context).unfocus();
                },
              ),
            ),

            // フィルターチップ
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Row(
                        children: [
                          if (isSelected)
                            Icon(
                              _getFilterIcon(filter),
                              size: 16,
                              color: primaryColor,
                            ),
                          if (isSelected) const SizedBox(width: 4),
                          Text(filter),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });

                        // アニメーションをリセットして再生
                        _animationController.reset();
                        _animationController.forward();

                        // 触覚フィードバック
                        HapticFeedback.selectionClick();
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: primaryColor.withOpacity(0.2),
                      checkmarkColor: primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? primaryColor : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      elevation: isSelected ? 2 : 0,
                      pressElevation: 4,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            // 書類カウントと並び替え表示
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    '${_filteredDocuments.length}件の書類',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy,
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

            // 書類リスト
            Expanded(
              child: _filteredDocuments.isEmpty
                  ? _buildEmptyState()
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: _isGridMode
                          ? _buildDocumentsGrid()
                          : _buildDocumentsList(),
                    ),
            ),
        ],
        ),
        // 新規スキャンボタン
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/document-scan');
          },
          backgroundColor: primaryColor,
          icon: const Icon(Icons.document_scanner),
          label: const Text('スキャン'),
        ),
      ),
    );
  }

  // 書類リスト表示
  Widget _buildDocumentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return _buildDocumentCard(document);
      },
    );
  }

  // 書類グリッド表示
  Widget _buildDocumentsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = _filteredDocuments[index];
        return _buildDocumentGridItem(document);
      },
    );
  }

  // 書類カード（リスト表示用）
  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final date = DateFormat('yyyy/MM/dd').format(document['date']);
    final amount = document['amount'] != null
        ? '¥${NumberFormat('#,###').format(document['amount'])}'
        : '金額なし';

    // 書類タイプに応じたアイコン
    IconData typeIcon;
    Color typeColor;
    final primaryColor = Theme.of(context).primaryColor;

    switch (document['type']) {
      case '領収書':
        typeIcon = Icons.receipt_long;
        typeColor = Colors.green;
        break;
      case '請求書':
        typeIcon = Icons.description;
        typeColor = Colors.orange;
        break;
      case '通帳':
        typeIcon = Icons.account_balance;
        typeColor = primaryColor;
        break;
      default:
        typeIcon = Icons.insert_drive_file;
        typeColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // 書類詳細画面に遷移
          Navigator.pushNamed(
            context,
            '/document-detail',
            arguments: {'documentId': document['id']},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // サムネイル
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    typeIcon,
                    size: 42,
                    color: Colors.grey[400],
                  ),
                ),
                // タイプバッジ
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          typeIcon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          document['type'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 日付バッジ
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatDocumentDate(document['date']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 書類情報
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // タイトルと取引先
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          document['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // 取引先
                  Text(
                    document['vendor'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // 金額
                  Text(
                    amount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: document['amount'] != null
                          ? document['amount'] > 0
                              ? Colors.blue
                              : Colors.red
                          : Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ステータス
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(document['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(document['status']),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      document['status'],
                      style: TextStyle(
                        fontSize: 11,
                        color: _getStatusColor(document['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 書類カード（グリッド表示用）
  Widget _buildDocumentGridItem(Map<String, dynamic> document) {
    final amount = document['amount'] != null
        ? '¥${NumberFormat('#,###').format(document['amount'])}'
        : '';

    // 書類タイプに応じたアイコンと色
    IconData typeIcon;
    Color typeColor;
    final primaryColor = Theme.of(context).primaryColor;

    switch (document['type']) {
      case '領収書':
        typeIcon = Icons.receipt_long;
        typeColor = Colors.green;
        break;
      case '請求書':
        typeIcon = Icons.description;
        typeColor = Colors.orange;
        break;
      case '通帳':
        typeIcon = Icons.account_balance;
        typeColor = primaryColor;
        break;
      default:
        typeIcon = Icons.insert_drive_file;
        typeColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 書類詳細画面に遷移
          Navigator.pushNamed(
            context,
            '/document-detail',
            arguments: {'documentId': document['id']},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // サムネイル
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        typeIcon,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),

                  // タイプオーバーレイ（左上）
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        typeIcon,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // ステータス（右上）
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        document['status'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 情報部分
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // タイトル
                  Text(
                    document['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // 取引先と日付
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          document['vendor'] ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDocumentDate(document['date']),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),

                  if (document['amount'] != null) ...[
                    const SizedBox(height: 4),

                    // 金額
                    Text(
                      amount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color:
                            document['amount'] > 0 ? Colors.blue : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ステータスに応じた色を取得
  Color _getStatusColor(String status) {
    switch (status) {
      case '処理済み':
        return Colors.green;
      case '未払い':
        return Colors.orange;
      case '支払済み':
        return Colors.blue;
      case '記録済み':
        return Theme.of(context).primaryColor;
      case '未処理':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // フィルターに応じたアイコンを取得
  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case '領収書':
        return Icons.receipt_long;
      case '請求書':
        return Icons.description;
      case '通帳':
        return Icons.account_balance;
      case 'その他':
        return Icons.insert_drive_file;
      default:
        return Icons.filter_list;
    }
  }

  // 日付の簡易フォーマット
  String _formatDocumentDate(DateTime date) {
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

  // 空の状態（書類がない場合）
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 60,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '書類が見つかりません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 240,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'すべて'
                  ? '検索条件を変更してみてください'
                  : '右下のボタンをタップして書類をスキャンしましょう',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'すべて')
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('検索条件をリセット'),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'すべて';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 並び替えオプションを表示
  void _showSortOptions() {
    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.sort, color: primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    '並び替え',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sortOptions.length,
              itemBuilder: (context, index) {
                final option = _sortOptions[index];
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    Navigator.pop(context);

                    // アニメーションをリセットして再生
                    _animationController.reset();
                    _animationController.forward();

                    // 触覚フィードバック
                    HapticFeedback.selectionClick();
                  },
                  activeColor: primaryColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: Icon(
                    _getSortIcon(option),
                    color: option == _sortBy ? primaryColor : Colors.grey,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // 並び替えオプションに応じたアイコンを取得
  IconData _getSortIcon(String option) {
    switch (option) {
      case '日付（新しい順）':
        return Icons.arrow_downward;
      case '日付（古い順）':
        return Icons.arrow_upward;
      case '金額（高い順）':
        return Icons.attach_money;
      case '金額（低い順）':
        return Icons.money_off;
      default:
        return Icons.sort;
    }
  }
}
