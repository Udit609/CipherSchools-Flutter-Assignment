import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/color_consts.dart';
import '../helpers/models/transaction_model.dart';
import '../helpers/providers/transaction_provider.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdAsync = ref.watch(userIdProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Budget Overview',
          style: TextStyle(color: kDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: userIdAsync.when(
          data: (userId) => FutureBuilder<List<TransactionModel>>(
            future: ref.read(databaseProvider).getTransactions(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Error loading transactions'));
              }

              final transactions = snapshot.data!;

              double income = 0;
              double food = 0;
              double subscription = 0;
              double shopping = 0;
              double travel = 0;

              for (var transaction in transactions) {
                if (transaction.transactionType == 'income') {
                  income += transaction.amount;
                } else if (transaction.transactionType == 'expense') {
                  switch (transaction.category.toLowerCase()) {
                    case 'food':
                      food += transaction.amount;
                      break;
                    case 'subscription':
                      subscription += transaction.amount;
                      break;
                    case 'shopping':
                      shopping += transaction.amount;
                      break;
                    case 'travel':
                      travel += transaction.amount;
                      break;
                  }
                }
              }

              final totalExpenses = food + subscription + shopping + travel;
              final totalAmount = income - totalExpenses;

              final totalForChart = income + food + subscription + shopping + travel;

              List<PieChartSectionData> sections = [];

              if (totalForChart > 0) {
                if (food > 0) {
                  sections.add(
                    PieChartSectionData(
                      color: kRed,
                      value: food,
                      title: '${(food / totalForChart * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                if (income > 0) {
                  sections.add(
                    PieChartSectionData(
                      color: kGreen,
                      value: income,
                      title: '${(income / totalForChart * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                if (subscription > 0) {
                  sections.add(
                    PieChartSectionData(
                      color: kPrimaryColor, // Purple
                      value: subscription,
                      title: '${(subscription / totalForChart * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                if (shopping > 0) {
                  sections.add(
                    PieChartSectionData(
                      color: Color(0xFFFCAC12),
                      value: shopping,
                      title: '${(shopping / totalForChart * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                if (travel > 0) {
                  sections.add(
                    PieChartSectionData(
                      color: Color(0xFF004685),
                      value: travel,
                      title: '${(travel / totalForChart * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              }

              return Center(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 8.0,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sections: sections.isNotEmpty
                                    ? sections
                                    : [
                                        PieChartSectionData(
                                          color: Colors.grey,
                                          value: 1,
                                          title: 'No Data',
                                          radius: 100,
                                          titleStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                sectionsSpace: 0,
                                centerSpaceRadius: 80,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: kDark,
                                  ),
                                ),
                                Text(
                                  '₹${totalAmount.toInt()}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: totalAmount >= 0 ? kGreen : kRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Legend
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _LegendItem(color: kGreen, label: 'Income'),
                          _LegendItem(color: kRed, label: 'Food'),
                          _LegendItem(color: kPrimaryColor, label: 'Subscription'),
                          _LegendItem(color: Color(0xFFFCAC12), label: 'Shopping'),
                          _LegendItem(color: Color(0xFF004685), label: 'Travel'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: kDark,
          ),
        ),
      ],
    );
  }
}
