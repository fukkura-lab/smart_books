import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String documentId;
  
  const DocumentDetailScreen({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  // ドキュメントの初期状態（編集可能）
  Map<String, dynamic>? _document;
  bool _isEditing = false;
  bool _isLoading = true;
  
  // 編集用コントローラー
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  String? _selectedType;
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _loadDocument();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  // ドキュメントを読み込む（APIの代わりにモックデータ）
  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // APIコールをシミュレート
      await Future.delayed(const Duration(milliseconds: 800));
      
      // モックデータ
      final Map<String, dynamic> document = {
        'id': widget.documentId,
        'type': '領収書',
        'title': '飲食代（取引先接待）',
        'amount': 15800,
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'imagePath': 'assets/images/receipt1.jpg',
        'status': '処理済み',
        'vendor': '株式会社〇〇レストラン',
        'location': '東京都渋谷区〇〇町1-2-3',
        'category': '交際費',
        'paymentMethod': 'クレジットカード',
        'memo': '取引先との商談時の食事代',
        'taxAmount': 1436,
        'taxRate': 10,
        'items': [
          {'name': 'コース料理', 'price': 12000, 'quantity': 1},
          {'name': 'ドリンク', 'price': 3800, 'quantity': 1},
        ],
      };
      
      setState(() {
        _document = document;
        _isLoading = false;
        
        // 編集用コントローラーに初期値をセット
        _titleController.text = document['title'];
        _amountController.text = document['amount'].toString();
        _selectedType = document['type'];
        _selectedDate = document['date'];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('書類の読み込みに失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('書類詳細'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // 編集/完了ボタン
          if (!_isLoading && _document != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                setState(() {
                  if (_isEditing) {
                    // 編集モードを終了し、変更を保存
                    _saveChanges();
                  } else {
                    // 編集モードを開始
                    _isEditing = true;
                  }
                });
              },
            ),
          
          // メニューボタン
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _confirmDelete();
                  break;
                case 'share':
                  _shareDocument();
                  break;
                case 'download':
                  _downloadDocument();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('共有'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'download',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('ダウンロード'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('削除', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _document == null
              ? const Center(child: Text('書類が見つかりませんでした'))
              : _buildDocumentDetails(),
    );
  }
  
  // 書類詳細の表示
  Widget _buildDocumentDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 画像表示
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 基本情報カード
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '基本情報',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 名前
                  _buildEditableField(
                    'タイトル',
                    _document!['title'],
                    controller: _titleController,
                    icon: Icons.title,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // タイプ
                  _buildTypeSelector(),
                  
                  const SizedBox(height: 12),
                  
                  // 日付
                  _buildDateSelector(),
                  
                  const SizedBox(height: 12),
                  
                  // 金額
                  _buildEditableField(
                    '金額',
                    '¥${NumberFormat('#,###').format(_document!['amount'])}',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    icon: Icons.attach_money,
                    prefix: '¥',
                  ),
                  
                  if (!_isEditing) ...[
                    const SizedBox(height: 12),
                    
                    // ステータス
                    _buildInfoRow(
                      'ステータス',
                      _document!['status'],
                      icon: Icons.info_outline,
                      valueColor: _getStatusColor(_document!['status']),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 詳細情報カード
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '詳細情報',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 店舗/ベンダー名
                  _buildInfoRow(
                    '支払先',
                    _document!['vendor'],
                    icon: Icons.store,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // カテゴリー
                  _buildInfoRow(
                    'カテゴリー',
                    _document!['category'],
                    icon: Icons.category,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 支払い方法
                  _buildInfoRow(
                    '支払い方法',
                    _document!['paymentMethod'],
                    icon: Icons.payment,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 税額
                  _buildInfoRow(
                    '税額',
                    '¥${NumberFormat('#,###').format(_document!['taxAmount'])} (${_document!['taxRate']}%)',
                    icon: Icons.receipt,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // メモ
                  _buildInfoRow(
                    'メモ',
                    _document!['memo'],
                    icon: Icons.note,
                    valueMaxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 明細カード（領収書の場合）
          if (_document!['items'] != null && (_document!['items'] as List).isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '明細',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 明細テーブル
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(2),
                      },
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      children: [
                        // ヘッダー行
                        TableRow(
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[800] 
                                : Colors.grey[100],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Text(
                                '品目',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Text(
                                '数量',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Text(
                                '金額',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white 
                                      : Colors.grey[700],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        
                        // データ行
                        ...(_document!['items'] as List).map((item) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  item['name'],
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  item['quantity'].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 4.0,
                                ),
                                child: Text(
                                  '¥${NumberFormat('#,###').format(item['price'])}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        
                        // 合計行
                        TableRow(
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[900] 
                                : Colors.grey[50],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Text(
                                '合計',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : null,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: SizedBox(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Text(
                                '¥${NumberFormat('#,###').format(_document!['amount'])}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : null,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  // 情報行
  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
    int valueMaxLines = 1,
  }) {
    return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (icon != null) ...[  
    Icon(
      icon, 
        size: 20, 
        color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[400] 
          : Colors.grey[600]
    ),
    const SizedBox(width: 8),
    ],
    Expanded(
    flex: 2,
      child: Text(
        label,
        style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[400] 
          : Colors.grey[600],
    ),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    flex: 3,
    child: Text(
        value,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? (Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black87),
            ),
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  // 編集可能なフィールド
  Widget _buildEditableField(
    String label,
    String value, {
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: _isEditing
              ? TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: prefix,
                    filled: Theme.of(context).brightness == Brightness.dark,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : null,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }
  
  // 書類タイプセレクター
  Widget _buildTypeSelector() {
    final List<String> documentTypes = ['領収書', '請求書', '通帳', 'その他'];
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.folder, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            'タイプ',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: _isEditing
              ? DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // ダークモード用のスタイル調整
                    filled: Theme.of(context).brightness == Brightness.dark,
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : null,
                  ),
                  dropdownColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[800] 
                      : Colors.white,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                  items: documentTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                )
              : Text(
                  _document!['type'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
  
  // 日付セレクター
  Widget _buildDateSelector() {
    final formatter = DateFormat('yyyy/MM/dd');
    final formattedDate = formatter.format(_document!['date']);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            '日付',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: _isEditing
              ? InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700]! 
                          : Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[800] 
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? formatter.format(_selectedDate!)
                              : formattedDate,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white 
                                : Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down, 
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ],
                    ),
                  ),
                )
              : Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }
  
  // 変更を保存
  void _saveChanges() {
    // 数値バリデーション
    int? amount;
    try {
      amount = int.parse(_amountController.text.replaceAll(',', '').replaceAll('¥', ''));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('金額は数値を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // ドキュメントを更新
    setState(() {
      _document!['title'] = _titleController.text;
      _document!['amount'] = amount;
      _document!['type'] = _selectedType;
      if (_selectedDate != null) {
        _document!['date'] = _selectedDate;
      }
      _isEditing = false;
    });
    
    // 成功メッセージ
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('変更を保存しました'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // 削除確認ダイアログ
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('書類の削除'),
        content: const Text('この書類を削除してもよろしいですか？この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 削除処理
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('書類を削除しました'),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  // 共有機能
  void _shareDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('共有機能は実装予定です'),
      ),
    );
  }
  
  // ダウンロード機能
  void _downloadDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ダウンロード機能は実装予定です'),
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
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
