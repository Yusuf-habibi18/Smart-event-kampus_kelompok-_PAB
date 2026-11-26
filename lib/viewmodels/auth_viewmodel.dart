import 'package:flutter/foundation.dart';

import '../data/dummy_data.dart';
import '../models/student_profile.dart';
import '../models/user_role.dart';

/// ViewModel: state & logika masuk / daftar akun.
///
/// - Peserta (mahasiswa ITPLN & umum) masuk dengan email. Jenis akunnya
///   ditentukan dari domain email ([PesertaType.fromEmail]).
/// - Ormawa masuk dengan ID/email penyelenggara, Admin dengan NIP.
///
/// Data peserta hasil login ([student]) dibaca oleh halaman lain (Beranda,
/// Profil, Tiket, Sertifikat) untuk menampilkan identitas dan menyaring
/// event Internal ITPLN.
class AuthViewModel extends ChangeNotifier {
  UserRole _role = UserRole.peserta;
  PesertaType _pesertaChoice = PesertaType.mahasiswaItpln;
  StudentProfile _student = dummyStudent;
  String? _userId;
  bool _isLoading = false;

  /// Akun yang sudah didaftarkan lewat form Daftar (simulasi, belum backend).
  final Map<String, StudentProfile> _registered = {};

  UserRole get role => _role;
  StudentProfile get student => _student;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _userId != null;

  /// Pilihan di layar masuk: "Saya mahasiswa ITPLN" / "Saya peserta umum".
  PesertaType get pesertaChoice => _pesertaChoice;

  /// true jika peserta yang masuk adalah mahasiswa ITPLN.
  bool get isMahasiswa => _student.isMahasiswa;

  /// ID yang diketik pengguna saat login (email / ID Ormawa / NIP).
  String? get userId => _userId;

  void selectRole(UserRole role) {
    if (role == _role || _isLoading) return;
    _role = role;
    notifyListeners();
  }

  void choosePeserta(PesertaType type) {
    if (type == _pesertaChoice || _isLoading) return;
    _pesertaChoice = type;
    notifyListeners();
  }

  // --- Validasi --------------------------------------------------------------

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  /// Validasi email peserta. Jika [campusOnly], email wajib @itpln.ac.id.
  String? validateEmail(String? value, {bool campusOnly = false}) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Email wajib diisi';
    if (!_emailPattern.hasMatch(text)) return 'Format email belum benar';
    if (campusOnly && !PesertaType.isCampusEmail(text)) {
      return 'Ini bukan email kampus (${PesertaType.campusDomain}). '
          'Bukan mahasiswa ITPLN? Pilih "Peserta umum".';
    }
    return null;
  }

  /// Validasi ID sesuai peran yang dipilih. [label] = nama field di View.
  String? validateId(String? value, {String label = 'ID'}) {
    final String text = (value ?? '').trim();
    switch (_role) {
      case UserRole.peserta:
        return validateEmail(
          text,
          campusOnly: _pesertaChoice == PesertaType.mahasiswaItpln,
        );
      case UserRole.admin:
        if (text.isEmpty) return '$label wajib diisi';
        if (!RegExp(r'^\d{8,20}$').hasMatch(text)) {
          return 'Hanya angka, minimal 8 digit';
        }
        return null;
      case UserRole.ormawa:
        if (text.isEmpty) return '$label wajib diisi';
        if (text.length < 4) return 'Minimal 4 karakter';
        return null;
    }
  }

  String? validatePassword(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Kata sandi wajib diisi';
    if (text.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  String? validateName(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return 'Nama wajib diisi';
    if (text.length < 3) return 'Minimal 3 huruf';
    return null;
  }

  // --- Aksi -------------------------------------------------------------------

  /// Memproses login. Untuk peserta, profil dibentuk dari email:
  /// email kampus → mahasiswa ITPLN (NIM diambil dari bagian sebelum @ bila
  /// berupa angka), email lain → peserta umum.
  Future<void> login({required String id, required String password}) async {
    _isLoading = true;
    notifyListeners();

    // TODO: ganti dengan Firebase Authentication.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    _userId = id.trim();
    if (_role == UserRole.peserta) {
      _student = _profileFor(_userId!);
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Mendaftarkan akun peserta baru (simulasi). Setelah ini pengguna
  /// diminta memverifikasi email lalu masuk.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? institution,
  }) async {
    _isLoading = true;
    notifyListeners();

    // TODO: ganti dengan Firebase Authentication + email verifikasi.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final String key = email.trim().toLowerCase();
    final PesertaType type = PesertaType.fromEmail(key);
    _registered[key] = _baseProfile(key, type).copyWith(
      name: name.trim(),
      institution: type == PesertaType.umum ? institution?.trim() : null,
    );
    _pesertaChoice = type;
    _isLoading = false;
    notifyListeners();
  }

  StudentProfile _profileFor(String email) {
    final String key = email.toLowerCase();
    return _registered[key] ?? _baseProfile(key, PesertaType.fromEmail(key));
  }

  StudentProfile _baseProfile(String email, PesertaType type) {
    if (type == PesertaType.mahasiswaItpln) {
      final String local = email.split('@').first;
      final bool numeric = RegExp(r'^\d{8,20}$').hasMatch(local);
      return dummyStudent.copyWith(
        email: email,
        nim: numeric ? local : dummyStudent.nim,
      );
    }
    return StudentProfile(
      name: 'Peserta Umum',
      nim: '',
      program: '',
      faculty: '',
      semester: 0,
      generation: '',
      email: email,
      type: PesertaType.umum,
    );
  }

  void logout() {
    _userId = null;
    _student = dummyStudent;
    _role = UserRole.peserta;
    _pesertaChoice = PesertaType.mahasiswaItpln;
    notifyListeners();
  }
}
