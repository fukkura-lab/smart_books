import '../../models/transaction/transaction.dart';

abstract class TransactionState {}

class TransactionsInitial extends TransactionState {}

class TransactionsLoading extends TransactionState {
  final bool isInitialLoad;
  
  TransactionsLoading({this.isInitialLoad = true});
}

class TransactionsLoaded extends TransactionState {
  final List<Transaction> transactions;
  final bool hasMore;
  
  TransactionsLoaded({
    required this.transactions,
    this.hasMore = false,
  });
}

class TransactionsError extends TransactionState {
  final String message;
  
  TransactionsError(this.message);
}
