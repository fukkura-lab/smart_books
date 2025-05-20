abstract class TransactionEvent {}

class LoadTransactionsEvent extends TransactionEvent {}

class LoadMoreTransactionsEvent extends TransactionEvent {}

class SearchTransactionsEvent extends TransactionEvent {
  final String query;
  
  SearchTransactionsEvent(this.query);
}

class FilterTransactionsEvent extends TransactionEvent {
  final String period;
  final String type;
  final List<String>? categories;
  
  FilterTransactionsEvent({
    required this.period,
    required this.type,
    this.categories,
  });
}
