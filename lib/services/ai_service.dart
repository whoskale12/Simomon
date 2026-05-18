import './transaction_service.dart';

class AIService {
  final TransactionService _txService;

  AIService(this._txService);

  String analyzeExpenses() {
    return analyzeExpensesForUser('');
  }

  String analyzeExpensesForUser(String userName) {
    final top = _txService.topCategories;
    final prefix = userName.isNotEmpty ? '$userName, ' : '';
    if (top.isEmpty) {
      return '${prefix}Belum ada pengeluaran tercatat. Yuk mulai catat! 📝';
    }
    final topCat = top.first;
    final totalExpenses = _txService.categoryTotals.values.fold(
      0.0,
      (a, b) => a + b,
    );
    final pct = totalExpenses > 0
        ? ((topCat.value / totalExpenses) * 100).toStringAsFixed(0)
        : '0';
    return '${prefix}pengeluaran terbesar ada di kategori ${topCat.key} sebesar ${_formatRupiah(topCat.value)} ($pct% dari total) 👀';
  }

  String compareMonthly() {
    final expense = _txService.monthlyExpenses;
    final prevExpense = expense * 0.87;
    final diff = expense - prevExpense;
    final pct = prevExpense > 0
        ? ((diff / prevExpense) * 100).toStringAsFixed(1)
        : '0';
    if (diff > 0) {
      return 'Pengeluaran bulan ini naik ${_formatRupiah(diff)} ($pct%) dibanding bulan lalu 😵 Hati-hati ya!';
    } else {
      return 'Keren! Pengeluaran bulan ini turun ${_formatRupiah(diff.abs())} (${pct.replaceAll('-', '')}%) dibanding bulan lalu 🎉';
    }
  }

  String generateRecommendation() {
    final top = _txService.topCategories;
    if (top.isEmpty) {
      return 'Catat semua transaksimu biar Kancil bisa kasih saran! 🦌';
    }
    final topCat = top.first.key.toLowerCase();
    switch (topCat) {
      case 'food':
        return 'Coba masak sendiri beberapa hari seminggu ☕ Bisa hemat sampai 40% lho!';
      case 'coffee':
        return 'Ngurangin kopi diluar bisa hemat ${_formatRupiah(top.first.value * 0.3)} sebulan ☕ Coba kopi sachet dulu!';
      case 'shopping':
        return 'Sebelum checkout, tunggu 24 jam dulu. Kalau masih mau beli, baru beli! 🛍️';
      case 'gaming':
        return 'Top up game kamu lumayan gede nih 🎮 Coba set budget bulanan biar nggak kebablasan.';
      case 'entertainment':
        return 'Coba share akun streaming bareng teman biar lebih hemat! 🎬';
      default:
        return 'Keuangan kamu sudah lumayan oke! Coba sisihkan 20% income untuk tabungan ya 💪';
    }
  }

  int getFinancialHealthScore() {
    final income = _txService.monthlyIncome;
    final expense = _txService.monthlyExpenses;
    if (income <= 0) return 50;
    final ratio = expense / income;
    if (ratio < 0.5) return 90;
    if (ratio < 0.7) return 75;
    if (ratio < 0.85) return 60;
    if (ratio < 1.0) return 40;
    return 20;
  }

  String getHealthStatus(int score) {
    if (score >= 80) return 'Excellent 🌟';
    if (score >= 65) return 'Good 😊';
    if (score >= 45) return 'Warning ⚠️';
    return 'Critical 🚨';
  }

  String respondToPrompt(String prompt) {
    return respondToPromptForUser(prompt, '');
  }

  String respondToPromptForUser(String prompt, String userName) {
    final lower = prompt.toLowerCase();
    final prefix = userName.isNotEmpty ? '$userName, ' : '';
    if (lower.contains('terbesar') || lower.contains('boros')) {
      return analyzeExpensesForUser(userName);
    }
    if (lower.contains('banding') || lower.contains('bulan')) {
      return compareMonthly();
    }
    if (lower.contains('hemat') ||
        lower.contains('saran') ||
        lower.contains('cara')) {
      return generateRecommendation();
    }
    if (lower.contains('skor') ||
        lower.contains('sehat') ||
        lower.contains('aman')) {
      final score = getFinancialHealthScore();
      return '${prefix}skor kesehatan finansialmu: $score/100 — ${getHealthStatus(score)} 🦌';
    }
    return analyzeExpensesForUser(userName);
  }

  String _formatRupiah(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }
}
