import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_books/models/account_category.dart';
import 'package:uuid/uuid.dart';

class AccountCategoryEditScreen extends StatefulWidget {
  final AccountCategory? category;
  final AccountType categoryType;

  const AccountCategoryEditScreen({
    Key? key,
    this.category,
    required this.categoryType,
  }) : super(key: key);

  @override
  State<AccountCategoryEditScreen> createState() => _AccountCategoryEditScreenState();
}

class _AccountCategoryEditScreenState extends State<AccountCategoryEditScreen> {
  // フォームキー
  final _formKey = GlobalKey<FormState>();
  
  // テキスト編集コントローラー
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  // フォーカス管理
  late FocusNode _codeFocusNode;
  late FocusNode _nameFocusNode;
  late FocusNode _descriptionFocusNode;
  
  // 勘定科目タイプ
  late AccountType _categoryType;
  
  // 有効/無効フラグ
  late bool _isActive;
  
  // 初期の状態
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    
    // 編集モードかどうか
    _isEditing = widget.category != null;
    
    // 初期値の設定
    _categoryType = widget.categoryType;
    _isActive = widget.category?.isActive ?? true;
    
    // コントローラーの初期化
    _codeController = TextEditingController(text: widget.category?.code ?? '');
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
    
    // フォーカスノードの初期化
    _codeFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }
  
  @override
  void dispose() {
    // コントローラーの破棄
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    
    // フォーカスノードの破棄
    _codeFocusNode.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    
    super.dispose();
  }
  
  // 保存処理
  void _saveCategory() {
    // フォームのバリデーション
    if (_formKey.currentState?.validate() ?? false) {
      // フォームの状態を保存
      _formKey.currentState?.save();
      
      // 勘定科目オブジェクトの作成
      final category = AccountCategory(
        id: widget.category?.id ?? const Uuid().v4(),
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        type: _categoryType,
        description: _descriptionController.text.trim(),
        isActive: _isActive,
      );
      
      // 編集完了を通知して前の画面に戻る
      Navigator.pop(context, category);
      
      // 触覚フィードバック
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
          title: Text(_isEditing ? '勘定科目を編集' : '勘定科目を追加'),
          backgroundColor: primaryColor,
          actions: [
            // 保存ボタン
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveCategory,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイプ表示（編集時は変更不可）
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_categoryType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(_categoryType),
                        color: _getCategoryColor(_categoryType),
                        size: 24.0,
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        '${_getCategoryTypeText(_categoryType)}科目',
                        style: TextStyle(
                          color: _getCategoryColor(_categoryType),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24.0),
                
                // コード入力
                TextFormField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  decoration: InputDecoration(
                    labelText: 'コード',
                    hintText: '例: 101',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700]! 
                          : Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700]! 
                          : Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    prefixIcon: Icon(Icons.tag, color: primaryColor.withOpacity(0.6)),
                    labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[300] 
                        : Colors.grey[700]),
                    hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[500]),
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : Colors.grey[100],
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_nameFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'コードを入力してください';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16.0),
                
                // 名前入力
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: InputDecoration(
                    labelText: '名前',
                    hintText: '例: 現金',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700]! 
                          : Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700]! 
                          : Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    prefixIcon: Icon(Icons.title, color: primaryColor.withOpacity(0.6)),
                    labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[300] 
                        : Colors.grey[700]),
                    hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[500]),
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : Colors.grey[100],
                    filled: true,
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '名前を入力してください';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16.0),
                
                // 説明入力
                TextFormField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocusNode,
                  decoration: InputDecoration(
                    labelText: '説明',
                    hintText: '例: 手元の現金',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700]! 
                          : Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[700]! 
                          : Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    prefixIcon: Icon(Icons.description, color: primaryColor.withOpacity(0.6)),
                    labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[300] 
                        : Colors.grey[700]),
                    hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[500]),
                    fillColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[800] 
                        : Colors.grey[100],
                    filled: true,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                
                const SizedBox(height: 24.0),
                
                // 有効/無効切り替え
                SwitchListTile(
                  title: Text(
                    '勘定科目を有効にする',
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[300] 
                        : Colors.grey[700]),
                  ),
                  subtitle: Text(
                    _isActive ? '現在有効です' : '現在無効です',
                    style: TextStyle(
                      color: _isActive ? Colors.green : Theme.of(context).brightness == Brightness.dark 
                          ? Colors.grey[400] 
                          : Colors.grey[500],
                    ),
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                    
                    // 触覚フィードバック
                    HapticFeedback.selectionClick();
                  },
                  activeColor: primaryColor,
                  activeTrackColor: primaryColor.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                  contentPadding: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[700]! 
                        : Colors.grey[300]!),
                  ),
                  tileColor: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[850] 
                      : Colors.grey[50],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
