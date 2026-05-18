import '../../core/app_export.dart';
import 'package:provider/provider.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _filter = 'Semua'; // Semua, Pemasukan, Pengeluaran
  int? _selectedMonth; // null = all months

  final List<String> _filters = ['Semua', 'Pemasukan', 'Pengeluaran'];

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  List<TransactionModel> get _filteredTransactions {
    // Load ALL transactions — never filter by current month automatically
    final txService = Provider.of<TransactionService>(context);
    var list = txService.transactions;

    if (_filter == 'Pemasukan') {
      list = list.where((t) => t.type == TransactionType.income).toList();
    } else if (_filter == 'Pengeluaran') {
      list = list.where((t) => t.type == TransactionType.expense).toList();
    }

    if (_selectedMonth != null) {
      list = list.where((t) => t.date.month == _selectedMonth).toList();
    }

    return list;
  }

  Map<String, List<TransactionModel>> get _groupedTransactions {
    final grouped = <String, List<TransactionModel>>{};
    for (final t in _filteredTransactions) {
      final monthName = _monthNames[t.date.month - 1];
      final key = '${t.date.day} $monthName ${t.date.year}';
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  String _fmt(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Riwayat Transaksi',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  ..._filters.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _filter == f
                                ? AppTheme.primary
                                : (isDark
                                      ? AppTheme.surfaceVariantDark
                                      : AppTheme.surfaceVariantLight),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            f,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _filter == f
                                  ? Colors.white
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Month filter
                  GestureDetector(
                    onTap: () => _showMonthPicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedMonth != null
                            ? AppTheme.indigo.withAlpha(31)
                            : (isDark
                                  ? AppTheme.surfaceVariantDark
                                  : AppTheme.surfaceVariantLight),
                        borderRadius: BorderRadius.circular(999),
                        border: _selectedMonth != null
                            ? Border.all(
                                color: AppTheme.indigo.withAlpha(102),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: _selectedMonth != null
                                ? AppTheme.indigo
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedMonth != null
                                ? _monthNames[_selectedMonth! - 1].substring(
                                    0,
                                    3,
                                  )
                                : 'Bulan',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _selectedMonth != null
                                  ? AppTheme.indigo
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (_selectedMonth != null) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedMonth = null),
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppTheme.indigo,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Transaction list
            Expanded(
              child: _filteredTransactions.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: _groupedTransactions.length,
                      itemBuilder: (ctx, i) {
                        final dateKey = _groupedTransactions.keys.elementAt(i);
                        final txList = _groupedTransactions[dateKey]!;
                        return _buildDateGroup(dateKey, txList, theme, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroup(
    String dateKey,
    List<TransactionModel> txList,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            dateKey,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...txList.map((t) => _buildTransactionCard(t, theme, isDark)),
      ],
    );
  }

  Widget _buildTransactionCard(
    TransactionModel t,
    ThemeData theme,
    bool isDark,
  ) {
    final isExpense = t.type == TransactionType.expense;
    final catColor = AppTheme.categoryColor(t.category);
    final catIcon = AppTheme.categoryIcon(t.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(51)
                : AppTheme.primary.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: catColor.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(catIcon, color: catColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t.category,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: catColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isExpense ? '-Rp ${_fmt(t.amount)}' : '+Rp ${_fmt(t.amount)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isExpense ? AppTheme.error : AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat pemasukan & pengeluaranmu!',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filter Bulan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(12, (i) {
                final month = i + 1;
                final isSelected = _selectedMonth == month;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedMonth = month);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : (isDark
                                ? AppTheme.surfaceVariantDark
                                : AppTheme.surfaceVariantLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _monthNames[i],
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
