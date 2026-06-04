import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        color: AppColors.primaryDark,
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Find your desired weapon...',
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
          color: AppColors.textSecondary,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(16),
          child: SvgPicture.asset(
            'assets/icons/search.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryDark,
              BlendMode.srcIn,
            ),
          ),
        ),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
