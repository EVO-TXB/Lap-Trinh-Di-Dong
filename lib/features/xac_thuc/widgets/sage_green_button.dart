import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_styles.dart';

class SageGreenButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool dangXuLy;
  final double height;

  const SageGreenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.dangXuLy = false,
    this.height = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: dangXuLy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          disabledBackgroundColor: AppColors.sageGreen.withOpacity(0.6),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppStyles.buttonRadius,
          ),
        ),
        child: dangXuLy
            ? const SizedBox(
                width: 22.0,
                height: 22.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: AppStyles.buttonText,
              ),
      ),
    );
  }
}

