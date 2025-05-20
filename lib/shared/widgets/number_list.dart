import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberList extends StatelessWidget {
  final List<String> strings;

  const NumberList(this.strings, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(0, 15, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: strings.asMap().entries.map((entry) {
          int index = entry.key + 1; // Start from 1
          String str = entry.value;

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
