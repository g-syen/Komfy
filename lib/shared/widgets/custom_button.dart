import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komfy/themes/typography.dart';

class CustomButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final bool isInverted;
  final double width;
  final Widget? leadingIcon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = const Color(0xFF284082),
    this.textColor = Colors.white,
    this.isInverted = false,
    this.width = 0,
    this.borderColor = Colors.black,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (leadingIcon != null && width > 0) {
      if (isInverted) {
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: borderColor),
            fixedSize: Size(width, 50),
          ),
          onPressed: onPressed,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: textColor,
                  radius: 16,
                  child: leadingIcon,
                ),
                SizedBox(width: width * 0.1),
                Text(
                  text,
                  style: AppTypography.subtitle4.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        );
      }
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          fixedSize: Size(width, 50),
        ),
        onPressed: onPressed,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: textColor,
                radius: 16,
                child: leadingIcon,
              ),
              SizedBox(width: width * 0.1),
              Text(
                text,
                style: AppTypography.subtitle4.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      );
    } else if (width>0) {
      if (isInverted) {
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: borderColor),
            fixedSize: Size(width, 50),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: AppTypography.subtitle4.copyWith(color: textColor),
          ),
        );
      }
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          fixedSize: Size(width, 50),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTypography.subtitle4.copyWith(color: textColor),
        ),
      );
    }

    if (isInverted) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTypography.subtitle4.copyWith(color: textColor),
        ),
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTypography.subtitle4.copyWith(color: textColor),
      ),
    );
  }
}
