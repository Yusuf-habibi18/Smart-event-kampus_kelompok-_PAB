import 'package:flutter/material.dart';

const List<String> _hari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const List<String> _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// DateTime(2025, 5, 28) → "Rabu, 28 Mei 2025".
String formatTanggal(DateTime date) {
  return '${_hari[date.weekday - 1]}, ${date.day} ${_bulan[date.month - 1]} '
      '${date.year}';
}

/// DateTime(2025, 5, 28) → "28 Mei 2025".
String formatTanggalPendek(DateTime date) {
  return '${date.day} ${_bulan[date.month - 1]} ${date.year}';
}

/// TimeOfDay(hour: 8, minute: 5) → "08.05".
String formatJam(TimeOfDay time) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(time.hour)}.${two(time.minute)}';
}
