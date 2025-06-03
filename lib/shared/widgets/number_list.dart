import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../themes/typography.dart';

class NumberList extends StatelessWidget {
  final List<String> strings;
  final bool useDividers;

  const NumberList(this.strings, {super.key, this.useDividers = false});

  @override
  Widget build(BuildContext context) {
    if (useDividers) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.fromLTRB(0, 15, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              strings.asMap().entries.map((entry) {
                int index = entry.key + 1; // Start from 1
                String str = entry.value;
                bool isFirst = index == 1;
                List<String> parts = str.split('\n');


                return Column(
                  children: [
                    isFirst
                        ? Divider(thickness: 1, color: Color(0xFF0B1956))
                        : SizedBox(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$index.",
                            style: TextStyle(fontSize: 16, height: 1.55),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parts[0],
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                  style: AppTypography.subtitle4.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  parts[1],
                                  textAlign: TextAlign.left,
                                  softWrap: true,
                                  style: AppTypography.bodyText1,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(thickness: 1, color: Color(0xFF0B1956)),
                  ],
                );
              }).toList(),
        ),
      );
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(0, 15, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            strings.asMap().entries.map((entry) {
              int index = entry.key + 1; // Start from 1
              String str = entry.value;
<<<<<<< Updated upstream

<<<<<<< Updated upstream
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$index.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$str",
                  textAlign: TextAlign.left,
                  softWrap: true,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.55,
=======
=======
>>>>>>> Stashed changes
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$index.", style: TextStyle(fontSize: 16, height: 1.55)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "$str",
                      textAlign: TextAlign.left,
                      softWrap: true,
                      style: GoogleFonts.josefinSans(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}
