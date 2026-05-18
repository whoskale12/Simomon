import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import 'package:provider/provider.dart';
import './widgets/amount_input_widget.dart';
import './widgets/category_grid_widget.dart';
import './widgets/transaction_form_fields_widget.dart';
import './widgets/transaction_type_toggle_widget.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  // TransactionService provided via Provider; do not instantiate here.

  TransactionType _selectedType = TransactionType.expense;
  CategoryModel? _selectedCategory;
  double _amount = 0;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late AnimationController _pageController;
  late Animation<double> _pageAnim;

  // Predefined static category lists — no dynamic parsing
  static final List<CategoryModel> _expenseCategories = [
    const CategoryModel(
      id: 'food',
      name: 'Food',
      icon: Icons.fastfood_rounded,
      color: Color(0xFFFF6B6B),
    ),
    const CategoryModel(
      id: 'coffee',
      name: 'Coffee',
      icon: Icons.local_cafe_rounded,
      color: Color(0xFFB5835A),
    ),
    const CategoryModel(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_bike_rounded,
      color: Color(0xFF4361EE),
    ),
    const CategoryModel(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFFF9F43),
    ),
    const CategoryModel(
      id: 'bills',
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF6C63FF),
    ),
    const CategoryModel(
      id: 'gaming',
      name: 'Gaming',
      icon: Icons.sports_esports_rounded,
      color: Color(0xFF00D4AA),
    ),
    const CategoryModel(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: Color(0xFF4ECDC4),
    ),
    const CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFFF6B9D),
    ),
    const CategoryModel(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFFFF4757),
    ),
    const CategoryModel(
      id: 'others',
      name: 'Others',
      icon: Icons.category_rounded,
      color: Color(0xFF9E9BBF),
    ),
  ];

  static final List<CategoryModel> _incomeCategories = [
    const CategoryModel(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.work_rounded,
      color: Color(0xFF26D07C),
    ),
    const CategoryModel(
      id: 'salary',
      name: 'Gaji',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF7C4DFF),
    ),
    const CategoryModel(
      id: 'bonus',
      name: 'Bonus',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFFFD93D),
    ),
    const CategoryModel(
      id: 'others',
      name: 'Others',
      icon: Icons.category_rounded,
      color: Color(0xFF9E9BBF),
    ),
  ];

  List<CategoryModel> get _currentCategories =>
      _selectedType == TransactionType.expense
      ? _expenseCategories
      : _incomeCategories;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pageAnim = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    _pageController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read arguments after context is available
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == 'income' && _selectedType != TransactionType.income) {
      _selectedType = TransactionType.income;
      _selectedCategory = _incomeCategories.first;
    } else {
      _selectedCategory ??= _expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      // Safely reset to first category of new type
      _selectedCategory = type == TransactionType.expense
          ? _expenseCategories.first
          : _incomeCategories.first;
    });
    debugPrint(
      'Type changed to: $type, category reset to: ${_selectedCategory?.name}',
    );
    HapticFeedback.selectionClick();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Masukkan jumlah yang valid ya 💰',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih kategori dulu ya 📂',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final transaction = TransactionModel(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        amount: _amount,
        category: _selectedCategory!.name,
        type: _selectedType,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      debugPrint(
        'Saving transaction: ${transaction.title}, category: ${transaction.category}',
      );
      final txService = Provider.of<TransactionService>(context, listen: false);
      await txService.addTransaction(transaction);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedType == TransactionType.expense
                ? 'Pengeluaran berhasil dicatat! 📝'
                : 'Pemasukan berhasil dicatat! 🎉',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      // Print error to help debugging as requested
      print(e);
      debugPrint('Transaction save error: $e');
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan, coba lagi 🙏',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedType == TransactionType.expense
              ? 'Tambah Pengeluaran'
              : 'Tambah Pemasukan',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _pageAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(_pageAnim),
            child: Form(
              key: _formKey,
              child: isTablet
                  ? _buildTabletLayout(theme, isDark)
                  : _buildPhoneLayout(theme, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme, bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TransactionTypeToggleWidget(
              selectedType: _selectedType,
              onTypeChanged: _onTypeChanged,
              isDark: isDark,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: AmountInputWidget(
              controller: _amountController,
              onChanged: (val) {
                final cleaned = val.replaceAll('.', '').replaceAll(',', '');
                _amount = double.tryParse(cleaned) ?? 0;
              },
              isDark: isDark,
              transactionType: _selectedType,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Kategori',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: CategoryGridWidget(
              categories: _currentCategories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) {
                setState(() => _selectedCategory = cat);
                debugPrint('Category selected: ${cat.name}');
              },
              isDark: isDark,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: TransactionFormFieldsWidget(
              titleController: _titleController,
              notesController: _notesController,
              selectedDate: _selectedDate,
              onDateTap: _pickDate,
              isDark: isDark,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: _buildSubmitButton(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 560,
          child: Column(
            children: [
              TransactionTypeToggleWidget(
                selectedType: _selectedType,
                onTypeChanged: _onTypeChanged,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              AmountInputWidget(
                controller: _amountController,
                onChanged: (val) {
                  final cleaned = val.replaceAll('.', '').replaceAll(',', '');
                  _amount = double.tryParse(cleaned) ?? 0;
                },
                isDark: isDark,
                transactionType: _selectedType,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kategori',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CategoryGridWidget(
                categories: _currentCategories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() => _selectedCategory = cat);
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              TransactionFormFieldsWidget(
                titleController: _titleController,
                notesController: _notesController,
                selectedDate: _selectedDate,
                onDateTap: _pickDate,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitTransaction,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _selectedType == TransactionType.expense
                ? [AppTheme.coral, const Color(0xFFFF4757)]
                : [AppTheme.mint, const Color(0xFF00B894)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color:
                  (_selectedType == TransactionType.expense
                          ? AppTheme.coral
                          : AppTheme.mint)
                      .withAlpha(102),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  _selectedType == TransactionType.expense
                      ? 'Simpan Pengeluaran 💸'
                      : 'Simpan Pemasukan 💰',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
