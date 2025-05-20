import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CustomCalendarWidget extends StatefulWidget {
  final Function(String) onDateSelected;

  const CustomCalendarWidget({super.key, required this.onDateSelected});

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _chatDates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatDates();
  }

  Future<void> _loadChatDates() async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final snapshots =
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .where('createdBy', isEqualTo: currentUserID)
            .get();

    final dates =
        snapshots.docs.map((doc) {
          final timestamp = doc['date'] as Timestamp;
          final date = timestamp.toDate();
          return DateTime(date.year, date.month, date.day);
        }).toSet();

    setState(() {
      _chatDates = dates;
      _isLoading = false; // Done loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _isLoading
                  ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )

                  : Padding(
                padding: const EdgeInsets.all(16),
                child: TableCalendar(
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final isInChat = _chatDates.contains(
                        DateTime(day.year, day.month, day.day),
                      );
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isInChat ? Colors.black : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    final formatted = DateFormat('dd-MM-yyyy')
                        .format(selectedDay);
                    widget.onDateSelected(formatted);
                    Navigator.pop(context);
                  },
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekendStyle: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    weekdayStyle: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A5660),
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left,
                        color: Color(0xFFB5BEC6)),
                    rightChevronIcon: Icon(Icons.chevron_right,
                        color: Color(0xFFB5BEC6)),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    outsideTextStyle: TextStyle(
                      color: Colors.grey.withAlpha(87),
                      fontWeight: FontWeight.normal,
                    ),
                    defaultTextStyle: TextStyle(color: Colors.black),
                    weekendTextStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      )
      ,
    );
  }
}
