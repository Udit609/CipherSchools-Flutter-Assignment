class TransactionModel {
  final int? id;
  final String category;
  final String description;
  final String transactionType;
  final int amount;
  final DateTime dateTime;

  TransactionModel({
    this.id,
    required this.category,
    required this.description,
    required this.transactionType,
    required this.amount,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'transactionType': transactionType,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      category: map['category'],
      description: map['description'],
      transactionType: map['transactionType'],
      amount: map['amount'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }
}

// final List<TransactionModel> transactions = [
//   TransactionModel(
//     category: 'Shopping',
//     description: 'Buy some grocery',
//     transactionType: 'expense',
//     amount: 120,
//     dateTime: DateTime.now().subtract(Duration(hours: 2)),
//   ),
//   TransactionModel(
//     category: 'Subscription',
//     description: 'Disney+ Annual Subscription',
//     transactionType: 'expense',
//     amount: 499,
//     dateTime: DateTime.now().subtract(Duration(hours: 5)),
//   ),
//   TransactionModel(
//     category: 'Travel',
//     description: 'Chandigarh to Delhi',
//     transactionType: 'expense',
//     amount: 1000,
//     dateTime: DateTime.now().subtract(Duration(hours: 2)),
//   ),
// ];
