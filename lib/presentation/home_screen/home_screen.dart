import 'dart:math' as math;

import '../../core/app_export.dart';
import 'package:provider/provider.dart';
import '../../services/user_profile_service.dart';
import './widgets/ai_insight_bubble_widget.dart';
import './widgets/balance_card_widget.dart';
import './widgets/bottom_nav_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/spending_chart_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final UserProfileService _profileService = UserProfileService();
  late AIService _aiService;
  int _selectedNavIndex = 0;
  bool _balanceVisible = true;
  late AnimationController _fabController;
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;

  @override
  void initState() {
    super.initState();
    // AIService depends on TransactionService; initialized in didChangeDependencies
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    _pageController.forward();
    _profileService.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _fabController.dispose();
    _pageController.dispose();
    _profileService.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final txService = Provider.of<TransactionService>(context, listen: false);
    _aiService = AIService(txService);
  }

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _selectedNavIndex = 0);
    } else if (index == 1) {
      setState(() => _selectedNavIndex = 1);
      Navigator.pushNamed(
        context,
        AppRoutes.riwayatScreen,
      ).then((_) => setState(() => _selectedNavIndex = 0));
    } else if (index == 2) {
      setState(() => _selectedNavIndex = 2);
      Navigator.pushNamed(
        context,
        AppRoutes.profileScreen,
      ).then((_) => setState(() => _selectedNavIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _pageAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(_pageAnimation),
            child: isTablet
                ? _buildTabletLayout(
                    theme,
                    isDark,
                    Provider.of<TransactionService>(context),
                  )
                : _buildPhoneLayout(
                    theme,
                    isDark,
                    Provider.of<TransactionService>(context),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavWidget(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
        isDark: isDark,
      ),
      floatingActionButton: _buildKancilFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPhoneLayout(
    ThemeData theme,
    bool isDark,
    TransactionService txService,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: GreetingHeaderWidget(
              onAvatarTap: () => Navigator.pushNamed(
                context,
                AppRoutes.profileScreen,
              ).then((_) => setState(() {})),
              profileService: _profileService,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: BalanceCardWidget(
              balance: txService.balance,
              monthlyIncome: txService.monthlyIncome,
              monthlyExpenses: txService.monthlyExpenses,
              isVisible: _balanceVisible,
              onVisibilityToggle: () =>
                  setState(() => _balanceVisible = !_balanceVisible),
              isDark: isDark,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: QuickActionsWidget(
              onAddIncome: () => Navigator.pushNamed(
                context,
                AppRoutes.addTransactionScreen,
                arguments: 'income',
              ).then((_) => setState(() {})),
              onAddExpense: () => Navigator.pushNamed(
                context,
                AppRoutes.addTransactionScreen,
                arguments: 'expense',
              ).then((_) => setState(() {})),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SpendingChartWidget(
              last7DaysData: txService.last7DaysExpenses,
              isDark: isDark,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: AIInsightBubbleWidget(
              insight: _aiService.analyzeExpensesForUser(_profileService.name),
              onTap: () => _showAiChatSheet(),
              isDark: isDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    ThemeData theme,
    bool isDark,
    TransactionService txService,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: GreetingHeaderWidget(
                    onAvatarTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.profileScreen,
                    ).then((_) => setState(() {})),
                    profileService: _profileService,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: BalanceCardWidget(
                    balance: txService.balance,
                    monthlyIncome: txService.monthlyIncome,
                    monthlyExpenses: txService.monthlyExpenses,
                    isVisible: _balanceVisible,
                    onVisibilityToggle: () =>
                        setState(() => _balanceVisible = !_balanceVisible),
                    isDark: isDark,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: SpendingChartWidget(
                    last7DaysData: txService.last7DaysExpenses,
                    isDark: isDark,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
                child: QuickActionsWidget(
                  onAddIncome: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addTransactionScreen,
                    arguments: 'income',
                  ).then((_) => setState(() {})),
                  onAddExpense: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addTransactionScreen,
                    arguments: 'expense',
                  ).then((_) => setState(() {})),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
                child: AIInsightBubbleWidget(
                  insight: _aiService.analyzeExpensesForUser(
                    _profileService.name,
                  ),
                  onTap: () => _showAiChatSheet(),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKancilFab() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_fabController.value * math.pi) * 4),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _showAiChatSheet(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(102),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showAiChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _AiChatSheet(aiService: _aiService, userName: _profileService.name),
    );
  }
}

// ─── AI Chat Bottom Sheet ─────────────────────────────────────────────────────
class _AiChatSheet extends StatefulWidget {
  final AIService aiService;
  final String userName;
  const _AiChatSheet({required this.aiService, required this.userName});

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingController;

  static const List<String> _quickPrompts = [
    'Pengeluaran terbesar apa? 🔍',
    'Aku boros dimana? 💸',
    'Bandingin bulan ini 📊',
    'Cara hemat dong 💡',
    'Skor keuanganku? 🏆',
  ];

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _messages.add({
      'role': 'kancil',
      'text':
          'Hei ${widget.userName}! Aku Kancil 🦌 asisten finansialmu. Ada yang bisa aku bantu hari ini? ✨',
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  void _sendPrompt(String prompt) {
    setState(() {
      _messages.add({'role': 'user', 'text': prompt});
      _isTyping = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'kancil',
          'text': widget.aiService.respondToPromptForUser(
            prompt,
            widget.userName,
          ),
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(38),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kancil AI',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Asisten finansialmu 🦌',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_isTyping && i == _messages.length) {
                  return _buildTypingBubble(theme, isDark);
                }
                final msg = _messages[i];
                return _buildMessageBubble(msg, theme, isDark);
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                return GestureDetector(
                  onTap: () => _sendPrompt(_quickPrompts[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTheme.primary.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _quickPrompts[i],
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, String> msg,
    ThemeData theme,
    bool isDark,
  ) {
    final isKancil = msg['role'] == 'kancil';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isKancil
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isKancil) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isKancil
                    ? (isDark
                          ? AppTheme.surfaceVariantDark
                          : AppTheme.surfaceVariantLight)
                    : AppTheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isKancil ? 4 : 20),
                  bottomRight: Radius.circular(isKancil ? 20 : 4),
                ),
              ),
              child: Text(
                msg['text'] ?? '',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isKancil ? theme.colorScheme.onSurface : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingBubble(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.surfaceVariantDark
                  : AppTheme.surfaceVariantLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: List.generate(
                3,
                (i) => AnimatedBuilder(
                  animation: _typingController,
                  builder: (ctx, _) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(
                          0.4 +
                              (_typingController.value * 0.6) *
                                  (i == 1 ? 1 : 0.6),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
