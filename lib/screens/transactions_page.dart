import 'package:cipher_schools_assignment/constants/color_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../helpers/models/transaction_model.dart';
import '../helpers/providers/transaction_provider.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(allTransactionsProvider);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: SizedBox.shrink(),
          title: Text(
            'Transactions',
            style: TextStyle(color: kDark, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: transactions.isEmpty
              ? const Center(
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(fontSize: 16, color: kGrey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final isExpense = transaction.transactionType.toLowerCase() == 'expense';

                    return Dismissible(
                      key: Key(transaction.id.toString()),
                      direction: isExpense ? DismissDirection.endToStart : DismissDirection.none,
                      background: isExpense
                          ? Container(
                              color: kRed,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            )
                          : null,
                      confirmDismiss: (direction) async {
                        if (!isExpense) return false;

                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('Delete Transaction'),
                            content: const Text('Are you sure you want to delete this expense?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel', style: TextStyle(color: kGrey)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete', style: TextStyle(color: kRed)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        ref
                            .read(allTransactionsProvider.notifier)
                            .deleteTransaction(transaction.id!);
                        ref.invalidate(transactionProvider);

                        final selectedMonth = ref.read(selectedMonthProvider);
                        final transactionMonth = DateTime(
                          transaction.dateTime.year,
                          transaction.dateTime.month,
                          1,
                        );
                        if (transactionMonth == selectedMonth) {
                          ref.invalidate(headerTransactionsProvider);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Expense deleted successfully!'),
                            backgroundColor: kRed,
                          ),
                        );
                      },
                      child: AllTransactionTile(transaction: transaction),
                    );
                  },
                ),
        ));
  }
}

class AllTransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const AllTransactionTile({super.key, required this.transaction});

  String _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return 'assets/shopping_icon.png';
      case 'subscription':
        return 'assets/subscription_icon.png';
      case 'travel':
        return 'assets/travel_icon.png';
      case 'food':
        return 'assets/food_icon.png';
      default:
        return 'assets/income_icon.png';
    }
  }

  Color _getBackgroundColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'shopping':
        return const Color(0xFFFCEED4);
      case 'subscription':
        return const Color(0xFFEEE5FF);
      case 'travel':
        return const Color(0xFFF1F1FA);
      case 'food':
        return const Color(0xFFFDD5D7);
      default:
        return kGreen.withValues(alpha: 0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.transactionType.toLowerCase() == 'expense';
    final amountText = '${isExpense ? '-' : '+'} ₹${transaction.amount}';
    final dateText = DateFormat('MMM dd, yyyy').format(transaction.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: _getBackgroundColorForCategory(transaction.category),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              _getIconForCategory(transaction.category),
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            transaction.description,
            style: const TextStyle(fontSize: 14, color: kGrey),
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountText,
              style: TextStyle(
                fontSize: 16,
                color: isExpense ? kRed : kGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              dateText,
              style: const TextStyle(fontSize: 12.0, color: kGrey),
            ),
          ],
        ),
      ),
    );
  }
}
