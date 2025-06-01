import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data.dart';

void checkAndAssignBadge(UserData user) {
  FirebaseAuth _auth = FirebaseAuth.instance;
  if (user.hariPemakaian >= 200 &&
      user.jumlahMoodTracker >= 50 &&
      user.jumlahJurnal >= 35) {
    updateBadge(_auth.currentUser!.uid, "Skye");
  } else if (user.hariPemakaian >= 100 &&
      user.jumlahJurnal >= 35) {
    updateBadge(_auth.currentUser!.uid, "Stride");
  } else if (user.hariPemakaian >= 50 &&
      user.jumlahMoodTracker >= 30) {
    updateBadge(_auth.currentUser!.uid, "Barker");
  } else if (user.hariPemakaian >= 3) {
    updateBadge(_auth.currentUser!.uid, "Whisker");
  }
}

Future<void> updateBadge(String uid, String badge) async {
  await FirebaseFirestore.instance.collection('Users').doc(uid).update({
    'lencanaKomfy': badge,
  });
}

void addPoints(String uid, int pointsToAdd) async {
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
  int currentPoints = doc['points'];
  int level = doc['level'];
  int newPoints = currentPoints + pointsToAdd;

  if (newPoints >= getPointsThresholdForLevel(level + 1)) {
    level++;
  }

  await FirebaseFirestore.instance.collection('Users').doc(uid).update({
    'points': newPoints,
    'level': level,
  });
}

int getPointsThresholdForLevel(int level) {
  return level * 1000;
}

