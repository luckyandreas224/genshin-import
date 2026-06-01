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

  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MarketPage(),
      ProfilePage(key: _profileKey),
      const Placeholder(),
    ];
  }

  void _onTabTap(int index) {
    if (index == 1 || index == 3) {
      _profileKey.currentState?.refresh();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}