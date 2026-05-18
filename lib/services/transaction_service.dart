import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/transaction_model.dart';

class TransactionService extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  bool _loaded = false;

  static const String _storageKey = 'transactions_v2';

  /// All transactions, newest first.
  List<TransactionModel> get transactions {
    final list = List<TransactionModel>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Computed balance from transactions. Income adds, expense subtracts.
  double get balance {
    return _transactions.fold(0.0, (double sum, TransactionModel t) {
      return sum + (t.type == TransactionType.income ? t.amount : -t.amount);
    });
  }

  /// LOAD DATA
  Future<void> loadTransactions() async {
    if (_loaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_storageKey);
      if (stored != null && stored.isNotEmpty) {
        _transactions.clear();
        for (final s in stored) {
          try {
            final parts = s.split('|');
            if (parts.length >= 6) {
              _transactions.add(
                TransactionModel(
                  id: parts[0],
                  title: parts[1],
                  amount: double.tryParse(parts[2]) ?? 0,
                  category: parts[3],
                  type: parts[4] == 'income'
                      ? TransactionType.income
                      : TransactionType.expense,
                  date: DateTime.tryParse(parts[5]) ?? DateTime.now(),
                  notes: parts.length > 6 && parts[6].isNotEmpty ? parts[6] : null,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error parsing transaction: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }

    _loaded = true;
    notifyListeners();
  }

  /// SAVE DATA
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = _transactions.map((t) {
        return [
          t.id,
          t.title,
          t.amount.toString(),
          t.category,
          t.type == TransactionType.income ? 'income' : 'expense',
          t.date.toIso8601String(),
          t.notes ?? '',
        ].join('|');
      }).toList();
      await prefs.setStringList(_storageKey, serialized);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  /// Add transaction
  Future<void> addTransaction(TransactionModel trx) async {
    try {
      _transactions.add(trx);
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  /// Monthly income for current month.
  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Monthly expenses for current month.
  double get monthlyExpenses {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Category totals for ALL expense transactions (not month-filtered)
  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    return totals;
  }

  /// Top categories sorted by expense amount.
  List<MapEntry<String, double>> get topCategories {
    final totals = categoryTotals;
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  /// Returns last 7 days expenses as a list of 7 doubles.
  List<double> get last7DaysExpenses {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.day == day.day &&
              t.date.month == day.month &&
              t.date.year == day.year)
          .fold(0.0, (sum, t) => sum + t.amount);
    });
  }

  /// Unique days that have transactions (for achievements)
  int get uniqueTransactionDays {
    final days = <String>{};
    for (final t in _transactions) {
      days.add('${t.date.year}-${t.date.month}-${t.date.day}');
    }
    return days.length;
  }

  String generateCsvContent() {
    final buffer = StringBuffer();
    buffer.writeln('Tanggal,Judul,Kategori,Tipe,Jumlah');
    for (final t in transactions) {
      final date =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      final type = t.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran';
      buffer.writeln(
        '$date,${t.title},${t.category},$type,${t.amount.toStringAsFixed(0)}',
      );
    }
    return buffer.toString();
  }

  /// RESET DATA
  Future<void> resetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _transactions.clear();
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting transactions: $e');
    }
  }
}