import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/transaction/transaction_state.dart' as transaction_state;
import '../../models/transaction/transaction.dart';
import '../../widgets/transaction/transaction_item.dart';
import '../../widgets/swipe_back_navigator.dart';
import '../../utils/keyboard_util.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  // フィルター状態
  String _periodFilter = 'all';
  String _typeFilter = 'all';
  List<String> _selectedCategories = [];
  
  @override
  void initState() {
    super.initState();
    // 初期データの読み込み
    context.read<TransactionBloc>().add(LoadTransactionsEvent());
    
    // スクロールリスナーの設定（無限スクロール用）
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_isLoading) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // スクロールが下端に近づいたら追加データをロード
    if (currentScroll >= maxScroll - 200) {
      setState(() => _isLoading = true);
      context.read<TransactionBloc>().add(LoadMoreTransactionsEvent());
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('取引履歴'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<TransactionBloc, transaction_state.TransactionState>(
        listener: (context, state) {
          // 状態変化時の処理が必要な場合はここに記述
        },
        builder: (context, state) {
          // 状態に応じて表示を切り替え
          if (state is transaction_state.TransactionsInitial || 
              (state is transaction_state.TransactionsLoading && 
               (state as transaction_state.TransactionsLoading).isInitialLoad)) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (state is transaction_state.TransactionsLoaded) {
            final transactions = (state as transaction_state.TransactionsLoaded).transactions;
            
            if (transactions.isEmpty) {
              return const Center(
                child: Text('取引履歴がありません'),
              );
            }
            
            return Column(
              children: [
                // 検索バー
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '取引を検索...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    onChanged: (value) {
                      if (value.length > 2) {
                        context.read<TransactionBloc>().add(SearchTransactionsEvent(value));
                      } else if (value.isEmpty) {
                        context.read<TransactionBloc>().add(LoadTransactionsEvent());
                      }
                    },
                  ),
                ),
                
                // 選択中のフィルターを表示（フィルターが適用されている場合）
                if (_periodFilter != 'all' || _typeFilter != 'all' || _selectedCategories.isNotEmpty)
                  _buildActiveFilters(),
                
                // 取引リスト
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: transactions.length + ((state as transaction_state.TransactionsLoaded).hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == transactions.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      final transaction = transactions[index];
                      
                      return TransactionItem(
                        transaction: transaction,
                        onTap: () {
                          if (transaction.documentId != null) {
                            Navigator.pushNamed(
                              context, 
                              '/document-detail',
                              arguments: {'documentId': transaction.documentId},
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                // 下部に余白を追加
                const SizedBox(height: 80),
              ],
            );
          } else if (state is transaction_state.TransactionsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('エラー: ${(state as transaction_state.TransactionsError).message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionBloc>().add(LoadTransactionsEvent());
                    },
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  // 適用中のフィルターを表示するウィジェット
  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '適用中のフィルター:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _periodFilter = 'all';
                    _typeFilter = 'all';
                    _selectedCategories = [];
                  });
                  // フィルターをリセットして再読み込み
                  context.read<TransactionBloc>().add(LoadTransactionsEvent());
                },
                child: const Text('リセット', style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_periodFilter != 'all')
                _buildFilterChip(_getPeriodLabel(_periodFilter), onDeleted: () {
                  setState(() {
                    _periodFilter = 'all';
                  });
                  _applyFilters();
                }),
                
              if (_typeFilter != 'all')
                _buildFilterChip(_getTypeLabel(_typeFilter), onDeleted: () {
                  setState(() {
                    _typeFilter = 'all';
                  });
                  _applyFilters();
                }),
                
              ..._selectedCategories.map((category) {
                return _buildFilterChip(category, onDeleted: () {
                  setState(() {
                    _selectedCategories.remove(category);
                  });
                  _applyFilters();
                });
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
  
  // フィルターチップウィジェット
  Widget _buildFilterChip(String label, {VoidCallback? onDeleted}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      deleteIconColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
  
  // 期間ラベルの取得
  String _getPeriodLabel(String period) {
    switch (period) {
      case 'today':
        return '今日';
      case 'yesterday':
        return '昨日';
      case 'week':
        return '今週';
      case 'month':
        return '今月';
      case 'year':
        return '今年';
      default:
        return '全期間';
    }
  }
  
  // 取引タイプラベルの取得
  String _getTypeLabel(String type) {
    switch (type) {
      case 'income':
        return '収入のみ';
      case 'expense':
        return '支出のみ';
      default:
        return '全タイプ';
    }
  }
  
  // フィルター適用
  void _applyFilters() {
    context.read<TransactionBloc>().add(
      FilterTransactionsEvent(
        period: _periodFilter,
        type: _typeFilter,
        categories: _selectedCategories.isEmpty ? null : _selectedCategories,
      ),
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    // 選択中の状態をローカル変数にコピー
    String tempPeriodFilter = _periodFilter;
    String tempTypeFilter = _typeFilter;
    List<String> tempSelectedCategories = List.from(_selectedCategories);
    
    // キーボードを隠す
    KeyboardUtil.hideKeyboard(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              // 入力フィールド以外の領域をタップしたときにフォーカスを外す
              onTap: () => KeyboardUtil.hideKeyboard(dialogContext),
              behavior: HitTestBehavior.opaque,
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '絞り込み',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 期間選択
                  Text('期間', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterOptionChip('全期間', 'all', tempPeriodFilter, (selected) {
                        setState(() {
                          tempPeriodFilter = 'all';
                        });
                      }),
                      _buildFilterOptionChip('今日', 'today', tempPeriodFilter, (selected) {
                        setState(() {
                          tempPeriodFilter = 'today';
                        });
                      }),
                      _buildFilterOptionChip('昨日', 'yesterday', tempPeriodFilter, (selected) {
                        setState(() {
                          tempPeriodFilter = 'yesterday';
                        });
                      }),
                      _buildFilterOptionChip('今週', 'week', tempPeriodFilter, (selected) {
                        setState(() {
                          tempPeriodFilter = 'week';
                        });
                      }),
                      _buildFilterOptionChip('今月', 'month', tempPeriodFilter, (selected) {
                        setState(() {
                          tempPeriodFilter = 'month';
                        });
                      }),
                      _buildFilterOptionChip('今年', 'year', tempPeriodFilter, (selected) {
                        setState(() {
                          tempPeriodFilter = 'year';
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // タイプ選択
                  Text('取引タイプ', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterOptionChip('すべて', 'all', tempTypeFilter, (selected) {
                        setState(() {
                          tempTypeFilter = 'all';
                        });
                      }),
                      _buildFilterOptionChip('収入', 'income', tempTypeFilter, (selected) {
                        setState(() {
                          tempTypeFilter = 'income';
                        });
                      }),
                      _buildFilterOptionChip('支出', 'expense', tempTypeFilter, (selected) {
                        setState(() {
                          tempTypeFilter = 'expense';
                        });
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // カテゴリ選択
                  Text('カテゴリ', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCategoryChip('売上', tempSelectedCategories, (selected) {
                        setState(() {
                          _toggleCategory('売上', tempSelectedCategories);
                        });
                      }),
                      _buildCategoryChip('交通費', tempSelectedCategories, (selected) {
                        setState(() {
                          _toggleCategory('交通費', tempSelectedCategories);
                        });
                      }),
                      _buildCategoryChip('通信費', tempSelectedCategories, (selected) {
                        setState(() {
                          _toggleCategory('通信費', tempSelectedCategories);
                        });
                      }),
                      _buildCategoryChip('消耗品費', tempSelectedCategories, (selected) {
                        setState(() {
                          _toggleCategory('消耗品費', tempSelectedCategories);
                        });
                      }),
                      _buildCategoryChip('会議費', tempSelectedCategories, (selected) {
                        setState(() {
                          _toggleCategory('会議費', tempSelectedCategories);
                        });
                      }),
                      _buildCategoryChip('食費', tempSelectedCategories, (selected) {
                        setState(() {
                          _toggleCategory('食費', tempSelectedCategories);
                        });
                      }),
                      _buildCategoryChip('家賃', tempSelectedCategories, (selected) {
                        setState(() {
                          _toggleCategory('家賃', tempSelectedCategories);
                        });
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 適用ボタン
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // フィルターを更新
                        setState(() {
                          _periodFilter = tempPeriodFilter;
                          _typeFilter = tempTypeFilter;
                          _selectedCategories = tempSelectedCategories;
                        });
                        // フィルターを適用
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('適用する'),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }
  
  // フィルターオプションチップ
  Widget _buildFilterOptionChip(String label, String value, String selectedValue, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: value == selectedValue ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
      ),
      selected: value == selectedValue,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
      side: BorderSide(color: Colors.grey.shade300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
  
  // カテゴリチップ
  Widget _buildCategoryChip(String category, List<String> selectedCategories, ValueChanged<bool> onSelected) {
    return FilterChip(
      label: Text(
        category,
        style: TextStyle(
          color: selectedCategories.contains(category) ? Theme.of(context).primaryColor : Colors.grey[600],
        ),
      ),
      selected: selectedCategories.contains(category),
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
  
  // カテゴリの切り替え
  void _toggleCategory(String category, List<String> categories) {
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
  }
}
