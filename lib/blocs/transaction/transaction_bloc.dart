import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transaction/transaction.dart';
import '../../services/transaction/transaction_service.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService;
  int _page = 1;
  String? _searchQuery;
  Map<String, dynamic>? _filters;
  
  TransactionBloc(this._transactionService) : super(TransactionsInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
    on<SearchTransactionsEvent>(_onSearchTransactions);
    on<FilterTransactionsEvent>(_onFilterTransactions);
  }
  
  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionsLoading());
    
    try {
      _page = 1;
      _searchQuery = null;
      _filters = null;
      
      final result = await _transactionService.getTransactions(page: _page);
      
      emit(TransactionsLoaded(
        transactions: result.transactions,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }
  
  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      
      if (!currentState.hasMore) return;
      
      emit(TransactionsLoading(isInitialLoad: false));
      
      try {
        _page++;
        
        final result = await _transactionService.getTransactions(
          page: _page,
          query: _searchQuery,
          filters: _filters,
        );
        
        emit(TransactionsLoaded(
          transactions: [...currentState.transactions, ...result.transactions],
          hasMore: result.hasMore,
        ));
      } catch (e) {
        emit(TransactionsError(e.toString()));
      }
    }
  }
  
  Future<void> _onSearchTransactions(
    SearchTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionsLoading());
    
    try {
      _page = 1;
      _searchQuery = event.query;
      
      final result = await _transactionService.getTransactions(
        page: _page,
        query: _searchQuery,
        filters: _filters,
      );
      
      emit(TransactionsLoaded(
        transactions: result.transactions,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }
  
  Future<void> _onFilterTransactions(
    FilterTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionsLoading());
    
    try {
      _page = 1;
      _filters = {
        'period': event.period,
        'type': event.type,
        'categories': event.categories,
      };
      
      final result = await _transactionService.getTransactions(
        page: _page,
        query: _searchQuery,
        filters: _filters,
      );
      
      emit(TransactionsLoaded(
        transactions: result.transactions,
        hasMore: result.hasMore,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }
}
