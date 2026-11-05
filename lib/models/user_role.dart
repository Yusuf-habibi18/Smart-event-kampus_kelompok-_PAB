import 'package:flutter/material.dart';

/// Model: peran pengguna yang dapat masuk ke aplikasi.
enum UserRole {
  mahasiswa(
    'Mahasiswa',
    'Jelajahi event, tiket, dan sertifikat SKPI',
    Icons.school_rounded,
  ),
  ormawa(
    'Ormawa',
    'Kelola event, peserta, dan presensi QR',
    Icons.groups_rounded,
  ),
  admin(
    'Admin',
    'Verifikasi proposal dan monitoring event',
    Icons.admin_panel_settings_rounded,
  );

  const UserRole(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;
}
