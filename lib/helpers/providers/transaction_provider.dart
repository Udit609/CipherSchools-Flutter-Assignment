import 'package:cipher_schools_assignment/helpers/models/month_transaction_model.dart';
import 'package:cipher_schools_assignment/helpers/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final userIdProvider = FutureProvider<String>((ref) async {
  final authService = AuthService();
  final cachedUserId = await authService.getStoredUserId();
  if (cachedUserId != null) {
    return cachedUserId;
  }
  return FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
});

final timePeriodProvider = StateProvider<String>((ref) => 'Today');

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final DatabaseHelper _databaseHelper;
  final String timePeriod;
  final String userId;

  TransactionNotifier(this._databaseHelper, this.timePeriod, this.userId) : super([]) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    DateTime startDate;
    DateTime endDate = DateTime.now();

    switch (timePeriod) {
      case 'Today':
        startDate = DateTime(endDate.year, endDate.month, endDate.day);
        break;
      case 'Week':
        startDate = endDate.subtract(Duration(days: endDate.weekday - 1));
        break;
      case 'Month':
        startDate = DateTime(endDate.year, endDate.month, 1);
        endDate = DateTime(endDate.year, endDate.month + 1, 0);
        break;
      case 'Year':
        startDate = DateTime(endDate.year, 1, 1);
        endDate = DateTime(endDate.year, 12, 31);
        break;
      default:
        startDate = DateTime(endDate.year, endDate.month, endDate.day);
    }

    final transactions =
        await _databaseHelper.getTransactionsByDateRange(startDate, endDate, userId);
    if (mounted) {
      state = transactions;
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _databaseHelper.insertTransaction(transaction, userId);
    await _loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _databaseHelper.deleteTransaction(id, userId);
    await _loadTransactions();
  }

  Future<void> refresh() async {
    await _loadTransactions();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final databaseHelper = ref.watch(databaseProvider);
  final timePeriod = ref.watch(timePeriodProvider);
  final userIdAsync = ref.watch(userIdProvider);
  final userId = userIdAsync.value ?? 'anonymous';

  return TransactionNotifier(databaseHelper, timePeriod, userId);
});

class AllTransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  final DatabaseHelper _databaseHelper;
  final String userId;

  AllTransactionsNotifier(this._databaseHelper, this.userId) : super([]) {
    _loadAllTransactions();
  }

  Future<void> _loadAllTransactions() async {
    final transactions = await _databaseHelper.getTransactions(userId);
    if (mounted) {
      state = transactions;
    }
  }

  Future<void> deleteTransaction(int id) async {
    await _databaseHelper.deleteTransaction(id, userId);
    await _loadAllTransactions();
  }

  Future<void> refresh() async {
    await _loadAllTransactions();
  }
}

final allTransactionsProvider =
    StateNotifierProvider<AllTransactionsNotifier, List<TransactionModel>>((ref) {
  final databaseHelper = ref.watch(databaseProvider);
  final userIdAsync = ref.watch(userIdProvider);
  final userId = userIdAsync.value ?? 'anonymous';

  return AllTransactionsNotifier(databaseHelper, userId);
});

final headerTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final databaseHelper = ref.watch(databaseProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);
  final userIdAsync = ref.watch(userIdProvider);
  final userId = userIdAsync.value ?? 'anonymous';

  final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
  final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

  return await databaseHelper.getTransactionsByDateRange(startDate, endDate, userId);
});

final headerTotalsProvider = FutureProvider<MonthTransactionModel>((ref) async {
  final transactions = await ref.watch(headerTransactionsProvider.future);

  final income = transactions
      .where((t) => t.transactionType == 'income')
      .fold<int>(0, (int sum, t) => sum + t.amount);

  final expenses = transactions
      .where((t) => t.transactionType == 'expense')
      .fold<int>(0, (int sum, t) => sum + t.amount);

  final accountBalance = income - expenses;

  return MonthTransactionModel(
    income: income,
    expenses: expenses,
    accountBalance: accountBalance,
  );
});
