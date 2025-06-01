import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';


class ProfileServices extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileServices({super.key});

  Future<void> setBase64ProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('Users').doc(uid).update({
        'photoProfile': base64Image,
      });
    } else {
      print('No image selected.');
    }
  }

  Future<bool> deleteAccount() async {
    final user = _auth.currentUser;
    final currentUserId = user!.uid;
    final docRef = _firestore.collection('Users').doc(currentUserId);

    try {
      await docRef.delete();
      await user.delete();
      return true;
    } catch (e) {
      log('Error Deleting User');
      return false;
    }
  }

  Future<void> updateKomfyBadge() async {
    String currentUserId = _auth.currentUser!.uid;
    final docRef =  _firestore.collection('Users').doc(currentUserId);
    try {
      final docSnapshot = await docRef.get();
      if(docSnapshot.exists) {
        final dataDoc = docSnapshot.data();
        int hariPemakaian = dataDoc?['hariPemakaian'] ?? 0;
        int jumlahJournal = dataDoc?['jumlahJournal'] ?? 0;
        int jumlahMoodTracker = dataDoc?['jumlahMoodTracker'] ?? 0;
        if(hariPemakaian>=200) {
          if(jumlahMoodTracker>=50 && jumlahJournal>=35) {
            docRef.update({'komfyBadge':'Skye'});
          }
        } else if(hariPemakaian >=100) {
          if(jumlahJournal>=35) {
            docRef.update({'komfyBadge':'Stride'});
          }
        } else if(hariPemakaian >=50) {
          if(jumlahMoodTracker>=30) {
            docRef.update({'komfyBadge':'Barker'});
          }
        } else if(hariPemakaian >= 3) {
          docRef.update({'komfyBadge':'Whisker'});
        }
        return;
      }
      return;
    } catch (e) {
      log('Update Komfy Badge: ${e.toString()}');
      return;
    }
  }

  Future<Map<String, dynamic>> getKomfyStats() async {
    String currentUserId = _auth.currentUser!.uid;
    final docRef =  _firestore.collection('Users').doc(currentUserId);
    try {
      final docSnapshot = await docRef.get();
      if(docSnapshot.exists) {
        final dataDoc = docSnapshot.data();
        Map<String, dynamic> data = {
          'komfyBadge' : dataDoc?['komfyBadge'] ?? 'None',
          'hariPemakaian' : dataDoc?['hariPemakaian'] ?? 0,
          'jumlahJournal' : dataDoc?['jumlahJournal'] ?? 0,
          'jumlahMoodTracker' : dataDoc?['jumlahMoodTracker'] ?? 0
        };
        return data;
      }
      return {
        'komfyBadge' :  'None',
        'hariPemakaian' : 0,
        'jumlahJournal' : 0,
        'jumlahMoodTracker' : 0
      };
    } catch (e) {
      log('Komfy Stats: ${e.toString()}');
      return {
        'komfyBadge' :  'None',
        'hariPemakaian' : 0,
        'jumlahJournal' : 0,
        'jumlahMoodTracker' : 0
      };
    }
  }

  Future<Image?> getBase64Image() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    if (doc.exists && doc['photoProfile'] != null) {
      if(doc['photoProfile'] == '') {
        return null;
      }
      String base64Str = doc['photoProfile'];
      Uint8List bytes = base64Decode(base64Str);
      return Image.memory(bytes, fit: BoxFit.cover);
    }

    return null;
  }

  Future<Map<String, dynamic>> getUserInformation() async {
    final currentUserId = _auth.currentUser!.uid;
    final docSnapshot = await _firestore.collection("Users").doc(currentUserId).get();
    log('docSnapshot: $docSnapshot');

    if(docSnapshot.exists) {
      final data = docSnapshot.data();
      final Map<String, dynamic> userInformation = {
        'namaPanggilan' : data?['namaPanggilan'] ?? '',
        'email': data?['email'] ?? '',
        'nomorTelepon': data?['nomorTelepon'] ?? '',
        'tanggalLahir': data?['tanggalLahir'] ?? '',
        'alamat': data?['alamat'] ?? ''
      };
      return userInformation;
    }
    log('User not Found: $currentUserId');
    return {
      'namaPanggilan': '',
      'email': '',
      'nomorTelepon': '',
      'tanggalLahir': '',
      'alamat': ''
    };
  }

  Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<String?> compressAndConvertToBase64(XFile file) async {
    Uint8List? compressed = await compressImage(file);
    if (compressed == null) return null;

    return base64Encode(compressed);
  }

  Future<void> saveBase64ToFirestore(String base64) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('Users').doc(uid).update({
      'photoProfile': base64,
    });
  }

  Future<Uint8List?> compressImage(XFile file) async {
    return await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 600,
      minHeight: 600,
      quality: 60, // 0–100 (lower = smaller file)
      format: CompressFormat.jpeg,
    );
  }

  Future<void> uploadCompressedProfilePicture() async {
    final file = await pickImage();
    if (file == null) return;

    final base64 = await compressAndConvertToBase64(file);
    if (base64 == null) return;

    await saveBase64ToFirestore(base64);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
