import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/dropdown.dart';
import '../../../themes/typography.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _namaLengkapController = TextEditingController();
  final _namaPanggilanController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? selectedProgramStudi;
  String? selectedAngkatan;

  Future<void> _completeProfile() async {
    final namaLengkap = _namaLengkapController.text.trim();
    final namaPanggilan = _namaPanggilanController.text.trim();
    final tanggalLahir = _tanggalLahirController.text.trim();

    if (namaLengkap.isEmpty ||
        namaPanggilan.isEmpty ||
        tanggalLahir.isEmpty ||
        selectedAngkatan!.isEmpty ||
        selectedAngkatan!.isEmpty) {
      _error = 'Pastikan semua data sudah terisi.';
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    Timestamp yesterdayTime = Timestamp.fromDate(yesterday);
    try {
      final data = {
        'namaLengkap': namaLengkap,
        'namaPanggilan': namaPanggilan,
        'tanggalLahir': tanggalLahir,
        'angkatan': selectedAngkatan,
        'programStudi': selectedProgramStudi,
        'hariPemakaian': 0,
        'jumlahMoodTracker': 0,
        'jumlahJurnal': 0,
        'komfyBadge': "None",
        "level": 0,
        'lastCheckedIn': yesterdayTime
      };

      _firestore.collection("Users").doc(_auth.currentUser!.uid).update(data);

      await _auth.currentUser?.sendEmailVerification();

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text('Verify Your Email'),
                content: Text(
                  'Kami telah mengirim email verifikasi ke ${_auth.currentUser!.email}. '
                  'Mohon cek email anda sebelum melakukan login.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    } on FirebaseAuthException catch (e) {
      log('Register error code: ${e.code}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32.0),
              Text(
                'Buat Akun',
                style: AppTypography.title1.copyWith(
                  color: Color(0xFF142553),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Lengkap',
                      textAlign: TextAlign.left,
                      style: AppTypography.subtitle4,
                    ),
                    CustomTextField(
                      textFieldController: _namaLengkapController,
                      hintText: 'Masukkan Nama Lengkap',
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Nama Panggilan',
                      textAlign: TextAlign.left,
                      style: AppTypography.subtitle4,
                    ),
                    CustomTextField(
                      textFieldController: _namaPanggilanController,
                      hintText: 'Masukkan Nama Panggilan',
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Tanggal Lahir',
                      textAlign: TextAlign.left,
                      style: AppTypography.subtitle4,
                    ),
                    buildTanggalLahirField(context),
                    SizedBox(height: 16.0),
                    Text(
                      'Program Studi',
                      textAlign: TextAlign.left,
                      style: AppTypography.subtitle4,
                    ),
                    CustomDropdownField(
                      label: '',
                      hint: 'Pilih Program Studi',
                      items: [
                        'Teknik Informatika',
                        'Teknik Komputer',
                        'Ilmu Komputer',
                        'Sistem Informasi',
                        'Teknologi Informasi',
                        'Pendidikan Teknologi Informasi'
                      ],
                      selectedItem: selectedProgramStudi,
                      onChanged: (value) {
                        selectedProgramStudi = value;
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Angkatan',
                      textAlign: TextAlign.left,
                      style: AppTypography.subtitle4,
                    ),
                    CustomDropdownField(
                      label: '',
                      hint: 'Pilih Angkatan',
                      items: [
                        '2018',
                        '2019',
                        '2020',
                        '2021',
                        '2022',
                        '2023',
                        '2024',
                      ],
                      selectedItem: selectedAngkatan,
                      onChanged: (value) {
                        selectedAngkatan = value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 48.0),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: CustomButton(
                  onPressed: _completeProfile,
                  text: 'Selanjutnya',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTanggalLahirField(BuildContext context) {
    return TextField(
      controller: _tanggalLahirController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: '',
        hintText: 'Masukan Tanggal Lahir',
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          _tanggalLahirController.text =
              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        }
      },
    );
  }
}
