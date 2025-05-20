import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_books/config/theme.dart';
import 'package:smart_books/models/account_category.dart';
import 'package:smart_books/screens/account_management/account_category_detail_screen.dart';
import 'package:smart_books/screens/account_management/account_category_edit_screen.dart';

class AccountCategoriesScreen extends StatefulWidget {
  const AccountCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<AccountCategoriesScreen> createState() => _AccountCategoriesScreenState();
}

class _AccountCategoriesScreenState extends State<AccountCategoriesScreen> with TickerProviderStateMixin {
  // タブコントローラー
  late TabController _tabController;
  
  // 検索クエリ
  String _searchQuery = '';
  
  // 検索欄のフォーカス管理用
  final FocusNode _searchFocusNode = FocusNode();
  
  // サンプルデータ - 実際のアプリではデータベースから取得
  List<AccountCategory> _assets = [
    AccountCategory(
      id: '101',
      code: '101',
      name: '現金',
      type: AccountType.asset,
      description: '手元の現金',
      isActive: true,
    ),
    AccountCategory(
      id: '102',
      code: '102',
      name: '普通預金',
      type: AccountType.asset,
      description: '銀行の普通預金口座',
      isActive: true,
    ),
    AccountCategory(
      id: '103',
      code: '103',
      name: '売掛金',
      type: AccountType.asset,
      description: '商品・サービスの掛売りによる債権',
      isActive: true,
    ),
    AccountCategory(
      id: '104',
      code: '104',
      name: '貯蔵品',
      type: AccountType.asset,
      description: '消耗品などの貯蔵品',
      isActive: true,
    ),
  ];
  
  List<AccountCategory> _liabilities = [
    AccountCategory(
      id: '201',
      code: '201',
      name: '買掛金',
      type: AccountType.liability,
      description: '商品・サービスの掛買いによる債務',
      isActive: true,
    ),
    AccountCategory(
      id: '202',
      code: '202',
      name: '短期借入金',
      type: AccountType.liability,
      description: '返済期限が1年以内の借入金',
      isActive: true,
    ),
    AccountCategory(
      id: '203',
      code: '203',
      name: '未払金',
      type: AccountType.liability,
      description: '商品・サービス以外の掛買いによる債務',
      isActive: true,
    ),
  ];
  
  List<AccountCategory> _income = [
    AccountCategory(
      id: '401',
      code: '401',
      name: '売上高',
      type: AccountType.income,
      description: '商品・サービスの販売による収益',
      isActive: true,
    ),
    AccountCategory(
      id: '402',
      code: '402',
      name: '受取利息',
      type: AccountType.income,
      description: '預金などの利息による収益',
      isActive: true,
    ),
    AccountCategory(
      id: '403',
      code: '403',
      name: '雑収入',
      type: AccountType.income,
      description: 'その他の収益',
      isActive: true,
    ),
  ];
  
  List<AccountCategory> _expenses = [
    AccountCategory(
      id: '501',
      code: '501',
      name: '仕入高',
      type: AccountType.expense,
      description: '商品の仕入れにかかる費用',
      isActive: true,
    ),
    AccountCategory(
      id: '502',
      code: '502',
      name: '給料手当',
      type: AccountType.expense,
      description: '従業員への給料・手当',
      isActive: true,
    ),
    AccountCategory(
      id: '503',
      code: '503',
      name: '旅費交通費',
      type: AccountType.expense,
      description: '出張や交通にかかる費用',
      isActive: true,
    ),
    AccountCategory(
      id: '504',
      code: '504',
      name: '通信費',
      type: AccountType.expense,
      description: '電話やインターネットなどの通信にかかる費用',
      isActive: true,
    ),
    AccountCategory(
      id: '505',
      code: '505',
      name: '水道光熱費',
      type: AccountType.expense,
      description: '水道・電気・ガスなどの費用',
      isActive: true,
    ),
  ];

  // 選択中のインデックス（長押し時などに使用）
  int _selectedIndex = -1;

  // アニメーションコントローラー
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    // タブコントローラの初期化
    _tabController = TabController(length: 4, vsync: this);
    
    // アニメーションコントローラの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // タブ変更時の処理
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // タブが変更された時の処理
        _animationController.reset();
        _animationController.forward();
      }
    });
    
    // 初期アニメーション
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // 現在選択されているタブの勘定科目リストを取得
  List<AccountCategory> get _currentCategories {
    switch (_tabController.index) {
      case 0:
        return _assets.where(_filterCategory).toList();
      case 1:
        return _liabilities.where(_filterCategory).toList();
      case 2:
        return _income.where(_filterCategory).toList();
      case 3:
        return _expenses.where(_filterCategory).toList();
      default:
        return [];
    }
  }

  // 検索フィルタリング用の関数
  bool _filterCategory(AccountCategory category) {
    if (_searchQuery.isEmpty) {
      return true;
    }
    
    final query = _searchQuery.toLowerCase();
    return category.name.toLowerCase().contains(query) ||
           category.code.contains(query) ||
           category.description.toLowerCase().contains(query);
  }

  // 勘定科目の追加処理
  void _addCategory() async {
    // 追加画面へ遷移
    final result = await Navigator.push<AccountCategory>(
      context,
      MaterialPageRoute(
        builder: (context) => AccountCategoryEditScreen(
          categoryType: _getCurrentAccountType(),
        ),
      ),
    );
    
    // 結果がnullでない場合（追加が完了した場合）、リストに追加
    if (result != null) {
      setState(() {
        switch (result.type) {
          case AccountType.asset:
            _assets.add(result);
            break;
          case AccountType.liability:
            _liabilities.add(result);
            break;
          case AccountType.income:
            _income.add(result);
            break;
          case AccountType.expense:
            _expenses.add(result);
            break;
        }
      });
      
      // 追加完了メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.name}を追加しました'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // 勘定科目の編集処理
  void _editCategory(AccountCategory category) async {
    // 編集画面へ遷移
    final result = await Navigator.push<AccountCategory>(
      context,
      MaterialPageRoute(
        builder: (context) => AccountCategoryEditScreen(
          category: category,
          categoryType: category.type,
        ),
      ),
    );
    
    // 結果がnullでない場合（編集が完了した場合）、リストを更新
    if (result != null) {
      setState(() {
        switch (result.type) {
          case AccountType.asset:
            _assets = _assets.map((item) => item.id == result.id ? result : item).toList();
            break;
          case AccountType.liability:
            _liabilities = _liabilities.map((item) => item.id == result.id ? result : item).toList();
            break;
          case AccountType.income:
            _income = _income.map((item) => item.id == result.id ? result : item).toList();
            break;
          case AccountType.expense:
            _expenses = _expenses.map((item) => item.id == result.id ? result : item).toList();
            break;
        }
      });
      
      // 編集完了メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.name}を更新しました'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  // 勘定科目の削除処理
  void _deleteCategory(AccountCategory category) async {
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
      setState(() {
        switch (category.type) {
          case AccountType.asset:
            _assets.removeWhere((item) => item.id == category.id);
            break;
          case AccountType.liability:
            _liabilities.removeWhere((item) => item.id == category.id);
            break;
          case AccountType.income:
            _income.removeWhere((item) => item.id == category.id);
            break;
          case AccountType.expense:
            _expenses.removeWhere((item) => item.id == category.id);
            break;
        }
      });
      
      // 削除完了メッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.name}を削除しました'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 勘定科目をタップしたときの処理
  void _onCategoryTap(AccountCategory category) {
    // 勘定科目詳細画面へ遷移
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountCategoryDetailScreen(category: category),
      ),
    );
  }

  // 現在のタブに基づく勘定科目の種類を取得
  AccountType _getCurrentAccountType() {
    switch (_tabController.index) {
      case 0:
        return AccountType.asset;
      case 1:
        return AccountType.liability;
      case 2:
        return AccountType.income;
      case 3:
        return AccountType.expense;
      default:
        return AccountType.asset;
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
          title: const Text('勘定科目管理'),
          backgroundColor: primaryColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: '資産'),
              Tab(text: '負債'),
              Tab(text: '収益'),
              Tab(text: '費用'),
            ],
          ),
        ),
        body: Column(
          children: [
            // 検索バー
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: '勘定科目を検索...',
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
              ),
            ),
            
            // カウント表示
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${_currentCategories.length}個の勘定科目',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 勘定科目リスト
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentCategories.isEmpty
                    ? _buildEmptyState()
                    : _buildCategoryList(),
              ),
            ),
          ],
        ),
        // 新規追加ボタン
        floatingActionButton: FloatingActionButton(
          onPressed: _addCategory,
          backgroundColor: primaryColor,
          child: const Icon(Icons.add),
          tooltip: '勘定科目を追加',
        ),
      ),
    );
  }

  // 勘定科目リストを構築
  Widget _buildCategoryList() {
    return FadeTransition(
      opacity: _animationController,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _currentCategories.length,
        itemBuilder: (context, index) {
          final category = _currentCategories[index];
          return _buildCategoryItem(category, index);
        },
      ),
    );
  }

  // 勘定科目アイテムを構築
  Widget _buildCategoryItem(AccountCategory category, int index) {
    final isSelected = index == _selectedIndex;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Card(
      elevation: isSelected ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isSelected
              ? primaryColor
              : Colors.transparent,
          width: isSelected ? 2.0 : 0.0,
        ),
      ),
      child: InkWell(
        onTap: () => _onCategoryTap(category),
        onLongPress: () {
          // 長押しで選択状態を切り替え
          setState(() {
            _selectedIndex = isSelected ? -1 : index;
          });
          
          // 触覚フィードバック
          HapticFeedback.mediumImpact();
          
          // アクションメニューを表示
          _showCategoryActions(category);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // アイコン
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(category.type),
                    color: _getCategoryColor(category.type),
                    size: 28,
                  ),
                ),
              ),
              
              const SizedBox(width: 16.0),
              
              // 情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            category.code,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4.0),
                    
                    // 説明
                    Text(
                      category.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // アクションボタン
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showCategoryActions(category),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 勘定科目のアクションメニューを表示
  void _showCategoryActions(AccountCategory category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(category.type),
                              color: _getCategoryColor(category.type),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'コード: ${category.code}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1.0),
              
              // アクションリスト
              ListTile(
                leading: Icon(Icons.visibility, color: Theme.of(context).primaryColor),
                title: const Text('詳細を表示'),
                onTap: () {
                  Navigator.pop(context);
                  _onCategoryTap(category);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.orange[700]),
                title: const Text('編集'),
                onTap: () {
                  Navigator.pop(context);
                  _editCategory(category);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('削除'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCategory(category);
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  // 空の状態のウィジェットを構築
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16.0),
          Text(
            '勘定科目がありません',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _searchQuery.isNotEmpty
                ? '検索条件に一致する勘定科目がありません'
                : '右下の「+」ボタンから勘定科目を追加できます',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('検索をクリア'),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
              ),
            ),
        ],
      ),
    );
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
