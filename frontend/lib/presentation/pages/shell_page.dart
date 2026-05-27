import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'market_page.dart';
import 'profile_page.dart';
import '../widgets/custom_navigation_bar.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellState();
}

class _ShellState extends State<ShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MarketPage(),
    Placeholder(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
