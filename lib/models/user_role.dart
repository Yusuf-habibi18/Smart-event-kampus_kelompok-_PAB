import 'package:flutter/material.dart';

/// Model: peran pengguna yang dapat masuk ke aplikasi.
///
/// Mahasiswa ITPLN dan masyarakat umum sama-sama masuk sebagai [peserta];
/// jenisnya ([PesertaType]) ditentukan otomatis dari domain email.
enum UserRole {
  peserta(
    'Peserta',
    'Mahasiswa ITPLN & umum: cari event, simpan tiket, unduh sertifikat',
    Icons.person_rounded,
  ),
  ormawa(
    'Ormawa',
    'Ajukan event, kelola peserta, dan catat kehadiran',
    Icons.groups_rounded,
  ),
  admin(
    'Admin',
    'Periksa dan setujui pengajuan akun serta event',
    Icons.admin_panel_settings_rounded,
  );

  const UserRole(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;
}

/// Jenis akun peserta.
///
/// - [mahasiswaItpln]: email berakhiran [campusDomain]. Bisa mengikuti semua
///   event (termasuk Internal ITPLN) dan mendapat poin SKPI.
/// - [umum]: email lain. Hanya event berlabel Umum, tanpa SKPI.
enum PesertaType {
  mahasiswaItpln('Mahasiswa ITPLN', 'Pakai email @itpln.ac.id',
      Icons.school_rounded),
  umum('Peserta Umum', 'Pakai email apa saja', Icons.person_outline_rounded);

  const PesertaType(this.label, this.hint, this.icon);

  final String label;
  final String hint;
  final IconData icon;

  static const String campusDomain = '@itpln.ac.id';

  /// Jenis akun ditentukan dari domain email, bukan dari pilihan pengguna,
  /// sehingga pihak luar tidak bisa mengaku sebagai mahasiswa ITPLN.
  static PesertaType fromEmail(String email) {
    return isCampusEmail(email) ? mahasiswaItpln : umum;
  }

  static bool isCampusEmail(String email) =>
      email.trim().toLowerCase().endsWith(campusDomain);
}
