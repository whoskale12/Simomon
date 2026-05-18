import 'package:flutter/material.dart';

import '../presentation/add_transaction_screen/add_transaction_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/riwayat_screen/riwayat_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String homeScreen = '/home-screen';
  static const String addTransactionScreen = '/add-transaction-screen';
  static const String profileScreen = '/profile-screen';
  static const String riwayatScreen = '/riwayat-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const HomeScreen(),
    homeScreen: (context) => const HomeScreen(),
    addTransactionScreen: (context) => const AddTransactionScreen(),
    profileScreen: (context) => const ProfileScreen(),
    riwayatScreen: (context) => const RiwayatScreen(),
  };
}
