import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../admin/admin_loadout_page.dart';
import '../admin/admin_profile_page.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShellPage> {
  int _currentIndex = 0;

  final GlobalKey<AdminProfilePageState> _profileKey =
      GlobalKey<AdminProfilePageState>();

  late final List<Widget> _pages;

  static const _icons = [
    'assets/icons/loadout.svg',
    'assets/icons/profile.svg',
  ];
  static const _labels = ['Loadout', 'Profile'];

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminItemsPage(),
      AdminProfilePage(key: _profileKey),
    ];
  }

  void _onTabTap(int index) {
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
        icons: _icons,
        labels: _labels,
      ),
    );
  }
}
