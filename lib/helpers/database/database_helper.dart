import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
    );
  }

  Future<void> _createTable(Database db, String tableName) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        transactionType TEXT NOT NULL,
        amount INTEGER NOT NULL,
        dateTime TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(TransactionModel transaction, String userId) async {
    final db = await instance.database;
    final tableName = 'transactions_$userId';
    await _createTable(db, tableName);
    return await db.insert(tableName, transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final db = await instance.database;
    final tableName = 'transactions_$userId';
    await _createTable(db, tableName);
    final result = await db.query(tableName, orderBy: 'dateTime DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate, String userId) async {
    final db = await instance.database;
    final tableName = 'transactions_$userId';
    await _createTable(db, tableName);
    final result = await db.query(
      tableName,
      where: 'dateTime BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'dateTime DESC',
    );
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<void> deleteTransaction(int id, String userId) async {
    final db = await instance.database;
    final tableName = 'transactions_$userId';
    await _createTable(db, tableName);
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
