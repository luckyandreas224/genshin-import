import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  
  final bool isOutlined;
  final Color? color;
  
  final String? iconAsset;

  const CustomButton({
    super.key, 
    required this.label, 
    this.onPressed,
    this.isOutlined = false,
    this.color,
    this.iconAsset,
  });

@override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconAsset != null) ...[
          Image.asset(iconAsset!, width: 24, height: 24),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
            color: isOutlined ? buttonColor : Colors.white,
          ),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: buttonColor, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: buttonContent,
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: buttonContent,
            ),
    );
  }
}