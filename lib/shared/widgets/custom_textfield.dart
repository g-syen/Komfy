import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final FocusNode? focusNode;
  final String hintText;
  final TextEditingController textFieldController;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool chatField;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.textFieldController,
    this.suffixIcon,
    this.obscureText = false,
    this.focusNode,
    this.chatField = false,
  });

  @override
  Widget build(BuildContext context) {
    if (chatField) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 128,
        ),
        child: Scrollbar(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Stack(
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: focusNode,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 8,
                  minLines: 1,
                  maxLength: 128,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF142553)),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    hintText: hintText,
                    hintStyle: GoogleFonts.josefinSans(
                      color: Colors.black.withAlpha(89),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: suffixIcon,
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  obscureText: obscureText,
                ),

                Positioned(
                  right: 12,
                  bottom: 0,
                  child: Text(
                    "${textFieldController.text.length}/128",
                    style: GoogleFonts.josefinSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return TextField(
        focusNode: focusNode,
        controller: textFieldController,
        decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF142553)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.josefinSans(
          color: Colors.black.withAlpha(89),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        )
        ),
      obscureText: obscureText,
    );
  }
}
