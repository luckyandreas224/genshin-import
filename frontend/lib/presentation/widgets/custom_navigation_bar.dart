import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  final List<String>? icons;
  final List<String>? labels;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.icons,
    this.labels,
  });

  static const _defaultIcons = [
    'assets/icons/market.svg',
    'assets/icons/profile.svg',
  ];
  static const _defaultLabels = ['Market', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final resolvedIcons = icons ?? _defaultIcons;
    final resolvedLabels = labels ?? _defaultLabels;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 34),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            resolvedLabels.length,
            (index) => _buildNavItem(index, resolvedIcons, resolvedLabels),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    List<String> resolvedIcons,
    List<String> resolvedLabels,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryDark : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  resolvedIcons[index],
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                const SizedBox(height: 4),
                Text(
                  resolvedLabels[index],
                  style: isSelected
                      ? AppTextStyles.navLabel
                      : AppTextStyles.navLabelInactive,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -2,
                child: Container(
                  height: 4,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
