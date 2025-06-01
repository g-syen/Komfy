import 'package:flutter/material.dart';

import '../../themes/typography.dart';

class CustomAlertDialog extends StatelessWidget {
  final double screenWidth;
  final String titleText;
  final String subtitleText;
  final String confirmText;
  final String cancelText;
  final bool switchColor;
  final Future<void> Function()? onConfirm;
  final Future<void> Function()? onCancel;

  const CustomAlertDialog({
    super.key,
    required this.screenWidth,
    required this.titleText,
    this.subtitleText = '',
    required this.confirmText,
    required this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.switchColor = false
  });

  @override
  Widget build(BuildContext context) {
    final bool subtitleTextExists = subtitleText != '';
    return StatefulBuilder(
      builder:
          (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: screenWidth * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          titleText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        subtitleTextExists ? Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              subtitleText,
                              style: AppTypography.bodyText1,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                          ],
                        ) :
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Color(0xFF366870)),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(16.0),
                              ),
                            ),
                            onTap: onConfirm,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: Text(
                                confirmText,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: switchColor ? Colors.red : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1, color: Color(0xFF366870)),
                        Expanded(
                          child: InkWell(
                            customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(16.0),
                              ),
                            ),
                            onTap: onCancel,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: Text(
                                cancelText,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: switchColor ? Colors.black : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
