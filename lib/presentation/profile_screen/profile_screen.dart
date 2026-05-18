import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../services/user_profile_service.dart';
import '../../services/transaction_service.dart';
import './widgets/achievements_widget.dart';
import './widgets/financial_health_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/top_categories_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final UserProfileService _profileService = UserProfileService();
  late AIService _aiService;

  late AnimationController _pageController;
  late Animation<double> _pageAnim;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pageAnim = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    _pageController.forward();
    _profileService.addListener(_onProfileChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final txService = Provider.of<TransactionService>(context, listen: false);
    _aiService = AIService(txService);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _profileService.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua transaksi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final txService = Provider.of<TransactionService>(context, listen: false);
      await txService.resetData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua transaksi telah dihapus'),
          backgroundColor: AppTheme.success,
        ),
      );
      setState(() {});
    }
  }

  Future<void> _toggleDarkMode(bool val) async {
    await _profileService.toggleDarkMode(val);
    // Rebuild the whole app via main.dart listener
  }

  Future<void> _toggleNotifications(bool val) async {
    await _profileService.toggleNotifications(val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            val ? 'Notifikasi diaktifkan 🔔' : 'Notifikasi dinonaktifkan 🔕',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      final txService = Provider.of<TransactionService>(context, listen: false);
      final csv = txService.generateCsvContent();

      if (kIsWeb) {
        // Web: show data in dialog for copy
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              'Export Data CSV',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: SelectableText(
                csv,
                style: GoogleFonts.nunito(fontSize: 11),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      } else {
        // Mobile: share via share_plus
        await SharePlus.instance.share(
          ShareParams(text: csv, subject: 'Simomon - Riwayat Transaksi'),
        );
      }
    } catch (e) {
      debugPrint('Export error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan saat export 😅',
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

  void _showAboutPage() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(28),
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
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(77),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Simomon',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Versi 1.0.0',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.surfaceVariantDark
                    : AppTheme.surfaceVariantLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Simomon adalah aplikasi pencatat keuangan pribadi yang cerdas. Dilengkapi dengan AI Kancil yang membantu kamu memahami pola pengeluaran dan memberikan saran finansial yang personal. 🦌',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.smart_toy_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kancil AI — Asisten finansial cerdasmu yang selalu siap membantu analisis keuangan secara personal.',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2026 Simomon. Made with ❤️',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final txService = Provider.of<TransactionService>(context);
    final healthScore = _aiService.getFinancialHealthScore();
    final topCategories = txService.topCategories;
    final totalExpenses = txService.categoryTotals.values.fold(
      0.0,
      (a, b) => a + b,
    );

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
          'Profil',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _pageAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(_pageAnim),
            child: isTablet
                ? _buildTabletLayout(
                    theme,
                    isDark,
                    healthScore,
                    topCategories,
                    totalExpenses,
                  )
                : _buildPhoneLayout(
                    theme,
                    isDark,
                    healthScore,
                    topCategories,
                    totalExpenses,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(
    ThemeData theme,
    bool isDark,
    int healthScore,
    List<MapEntry<String, double>> topCategories,
    double totalExpenses,
  ) {
    final txService = Provider.of<TransactionService>(context);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: ProfileHeaderWidget(
              isDark: isDark,
              balance: txService.balance,
              monthlyIncome: txService.monthlyIncome,
              monthlyExpenses: txService.monthlyExpenses,
              profileService: _profileService,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: FinancialHealthWidget(
              score: healthScore,
              status: _aiService.getHealthStatus(healthScore),
              isDark: isDark,
              aiInsight: _aiService.compareMonthly(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategori Teratas',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Semua waktu',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: TopCategoriesWidget(
              topCategories: topCategories,
              totalExpenses: totalExpenses,
              isDark: isDark,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Pencapaian',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: AchievementsWidget(
              isDark: isDark,
              txService: txService,
              profileService: _profileService,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Pengaturan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: SettingsSectionWidget(
              isDark: isDark,
              isDarkMode: _profileService.isDarkMode,
              notificationsEnabled: _profileService.notificationsEnabled,
              onDarkModeToggle: _toggleDarkMode,
              onNotificationsToggle: _toggleNotifications,
              onExportTap: _exportData,
              onAboutTap: _showAboutPage,
              onResetTap: _resetData,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    ThemeData theme,
    bool isDark,
    int healthScore,
    List<MapEntry<String, double>> topCategories,
    double totalExpenses,
  ) {
    final txService = Provider.of<TransactionService>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 12, 32),
            child: Column(
              children: [
                ProfileHeaderWidget(
                  isDark: isDark,
                  balance: txService.balance,
                  monthlyIncome: txService.monthlyIncome,
                  monthlyExpenses: txService.monthlyExpenses,
                  profileService: _profileService,
                ),
                const SizedBox(height: 16),
                FinancialHealthWidget(
                  score: healthScore,
                  status: _aiService.getHealthStatus(healthScore),
                  isDark: isDark,
                  aiInsight: _aiService.compareMonthly(),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pencapaian',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AchievementsWidget(
                  isDark: isDark,
                  txService: txService,
                  profileService: _profileService,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kategori Teratas',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                TopCategoriesWidget(
                  topCategories: topCategories,
                  totalExpenses: totalExpenses,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                Text(
                  'Pengaturan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                SettingsSectionWidget(
                  isDark: isDark,
                  isDarkMode: _profileService.isDarkMode,
                  notificationsEnabled: _profileService.notificationsEnabled,
                  onDarkModeToggle: _toggleDarkMode,
                  onNotificationsToggle: _toggleNotifications,
                  onExportTap: _exportData,
                  onAboutTap: _showAboutPage,
                  onResetTap: _resetData,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
