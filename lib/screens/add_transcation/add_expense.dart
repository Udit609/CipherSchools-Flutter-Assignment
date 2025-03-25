import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/color_consts.dart';
import '../../helpers/models/transaction_model.dart';
import '../../helpers/providers/transaction_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddExpense extends ConsumerStatefulWidget {
  const AddExpense({super.key});

  @override
  ConsumerState<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends ConsumerState<AddExpense> {
  String? selectedCategory;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController(text: '0');

  final List<String> categories = ['Shopping', 'Subscription', 'Travel', 'Food'];

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kRed,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:
              Platform.isIOS ? const Icon(Icons.arrow_back_ios_new) : const Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        title: const Text(
          'Expense',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: kRed),
              padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    'How much?',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  TextField(
                    controller: amountController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      prefixText: '₹',
                      prefixStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          // Form Section
          Expanded(
            child: Container(
              color: kRed,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kGrey.withValues(alpha: 0.5), width: 1.0),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kPrimaryColor, width: 1.2),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      value: selectedCategory,
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: 'Description',
                      controller: descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      isLast: true,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 60.0,
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          if (selectedCategory == null || amountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all required fields'),
                                backgroundColor: kRed,
                              ),
                            );
                            return;
                          }
                          final amount = int.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid amount'),
                                backgroundColor: kRed,
                              ),
                            );
                            return;
                          }
                          final transaction = TransactionModel(
                            category: selectedCategory!,
                            description: descriptionController.text,
                            transactionType: 'expense',
                            amount: amount,
                            dateTime: DateTime.now(),
                          );

                          ref.read(transactionProvider.notifier).addTransaction(transaction);
                          ref.invalidate(headerTransactionsProvider);
                          ref.invalidate(allTransactionsProvider);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Expanse added successfully!'),
                              backgroundColor: kGreen,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: kRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Expense',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
