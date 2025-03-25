import 'package:cipher_schools_assignment/constants/color_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../helpers/models/transaction_model.dart';
import '../helpers/providers/transaction_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final selectedTimePeriod = ref.watch(timePeriodProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final headerTotalsAsync = ref.watch(headerTotalsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF6E5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: kFocusColor,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/user.png',
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.keyboard_arrow_down, color: kPrimaryColor),
                        SizedBox(width: 8.0),
                        DropdownButton<DateTime>(
                          value: selectedMonth,
                          items: List.generate(12, (index) {
                            final month = DateTime(DateTime.now().year, index + 1);
                            return DropdownMenuItem<DateTime>(
                              value: month,
                              child: Text(
                                DateFormat('MMMM').format(month),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(selectedMonthProvider.notifier).state =
                                  DateTime(value.year, value.month, 1);
                            }
                          },
                          underline: Container(),
                          icon: SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.notifications,
                      color: kPrimaryColor,
                      size: 28.0,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                headerTotalsAsync.when(
                  data: (totals) => Column(
                    children: [
                      const Text(
                        'Account Balance',
                        style: TextStyle(fontSize: 16, color: kGrey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${totals.accountBalance}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: kDark,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: balanceCard(
                              asset: 'assets/income_icon.png',
                              title: 'Income',
                              amount: '₹${totals.income}',
                              color: kGreen,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: balanceCard(
                              asset: 'assets/expenses_icon.png',
                              title: 'Expenses',
                              amount: '₹${totals.expenses}',
                              color: kRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => const Text('Error loading totals'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTabButton(context, ref, 'Today', selectedTimePeriod == 'Today'),
                    _buildTabButton(context, ref, 'Week', selectedTimePeriod == 'Week'),
                    _buildTabButton(context, ref, 'Month', selectedTimePeriod == 'Month'),
                    _buildTabButton(context, ref, 'Year', selectedTimePeriod == 'Year'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transaction',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDark),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: kFocusColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                      ),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions yet!',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: kDark,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return TransactionTile(
                        transaction: transaction,
                        timePeriod: selectedTimePeriod,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget balanceCard({
    required String asset,
    required String title,
    required String amount,
    required Color color,
  }) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Container(
              height: 48.0,
              width: 48.0,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.0),
                image: DecorationImage(image: AssetImage(asset)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, WidgetRef ref, String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(timePeriodProvider.notifier).state = title;
        ref.read(transactionProvider.notifier).refresh();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFCEED4) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            color: isSelected ? Color(0xFFFCAC12) : kGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String timePeriod;

  const TransactionTile({super.key, required this.transaction, required this.timePeriod});

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
    final timeText = DateFormat('hh:mm a').format(transaction.dateTime);
    final dateText = DateFormat('MMM dd, yyyy').format(transaction.dateTime);

    return Container(
      margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        leading: Container(
          height: 60.0,
          width: 60.0,
          decoration: BoxDecoration(
            color: _getBackgroundColorForCategory(transaction.category),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Image.asset(
            _getIconForCategory(transaction.category),
            height: 30.0,
            width: 30.0,
          ),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: kDark),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            transaction.description.length > 20
                ? '${transaction.description.substring(0, 20)}...'
                : transaction.description,
            style: TextStyle(fontSize: 12.0, color: kGrey),
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
              timePeriod == 'Today' ? timeText : dateText,
              style: const TextStyle(fontSize: 12.0, color: kGrey),
            ),
          ],
        ),
      ),
    );
  }
}
