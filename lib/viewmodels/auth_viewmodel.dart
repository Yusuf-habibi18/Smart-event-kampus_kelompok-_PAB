import 'package:flutter/foundation.dart';

import '../data/dummy_data.dart';
import '../models/student_profile.dart';
import '../models/user_role.dart';

/// ViewModel: state & logika login.
///
/// View (LoginPage) hanya membaca [role], [isLoading], dan memanggil
/// [selectRole] / [login]. Data mahasiswa hasil login ([student]) dibaca
/// oleh halaman lain (Beranda, Profil, Tiket, Sertifikat).
class AuthViewModel extends ChangeNotifier {
  UserRole _role = UserRole.mahasiswa;
  StudentProfile _student = dummyStudent;
  String? _userId;
  bool _isLoading = false;

  UserRole get role => _role;
  StudentProfile get student => _student;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userId != null;

  /// ID yang diketik pengguna saat login (NIM / email / NIP).
  String? get userId => _userId;

  void selectRole(UserRole role) {
    if (role == _role || _isLoading) return;
    _role = role;
    notifyListeners();
  }

  /// [label] adalah nama field yang tampil di View (mis. "NIM").
  String? validateId(String? value, {String label = 'ID'}) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return '$label wajib diisi';

    switch (_role) {
      case UserRole.mahasiswa:
      case UserRole.admin:
        if (!RegExp(r'^\d{8,20}$').hasMatch(text)) {
          return 'Hanya angka, minimal 8 digit';
        }
        break;
      case UserRole.ormawa:
        if (text.length < 4) return 'Minimal 4 karakter';
        break;
    }
    return null;
  }

  String? validatePassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Kata sandi wajib diisi';
    if (text.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  /// Memproses login. NIM yang diketik disimpan ke profil mahasiswa
  /// sehingga tampil di halaman lain setelah navigasi.
  Future<void> login({required String id, required String password}) async {
    _isLoading = true;
    notifyListeners();

    // TODO: ganti dengan pemanggilan API autentikasi yang sebenarnya.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    _userId = id.trim();
    if (_role == UserRole.mahasiswa) {
      _student = dummyStudent.copyWith(nim: _userId);
    }
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _student = dummyStudent;
    _role = UserRole.mahasiswa;
    notifyListeners();
  }
}
