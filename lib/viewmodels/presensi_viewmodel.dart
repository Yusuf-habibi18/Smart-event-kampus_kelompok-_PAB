import 'package:flutter/foundation.dart';

import '../data/dummy_ormawa_data.dart';
import '../models/participant.dart';

/// Filter daftar peserta di halaman Kelola Peserta.
enum AttendanceFilter {
  semua('Semua'),
  hadir('Sudah Hadir'),
  belum('Belum Hadir');

  const AttendanceFilter(this.label);

  final String label;
}

/// Hasil memindai / memasukkan NIM peserta.
enum CheckInResult { berhasil, sudahHadir, tidakTerdaftar }

/// ViewModel: daftar peserta dan presensi event aktif Ormawa.
///
/// Dipakai bersama oleh halaman Kelola Peserta dan Pemindai QR sehingga
/// peserta yang dipindai langsung berstatus hadir di daftar peserta.
class PresensiViewModel extends ChangeNotifier {
  PresensiViewModel({
    this.eventTitle = 'Workshop UI/UX Design System 2025',
    this.eventLocation = 'Gedung D.402 Lt. 4',
    this.eventTime = '13.00 - 16.00 WIB',
    List<Participant> participants = dummyParticipants,
    DateTime Function()? clock,
  })  : _participants = List<Participant>.of(participants),
        _clock = clock ?? DateTime.now;

  final String eventTitle;
  final String eventLocation;
  final String eventTime;
  final List<Participant> _participants;
  final DateTime Function() _clock;

  String _query = '';
  AttendanceFilter _filter = AttendanceFilter.semua;
  Participant? _lastScanned;
  final List<Participant> _scanHistory = [];

  // --- State yang dibaca View ---------------------------------------------

  String get query => _query;
  AttendanceFilter get filter => _filter;

  List<Participant> get participants => List.unmodifiable(_participants);

  List<Participant> get filteredParticipants {
    return _participants.where((Participant p) {
      final bool okFilter = switch (_filter) {
        AttendanceFilter.semua => true,
        AttendanceFilter.hadir => p.isPresent,
        AttendanceFilter.belum => !p.isPresent,
      };
      return okFilter && p.matches(_query);
    }).toList();
  }

  int get total => _participants.length;
  int get presentCount => _participants.where((Participant p) => p.isPresent).length;
  int get absentCount => total - presentCount;
  int get manualCount =>
      _participants.where((Participant p) => p.isPresent && p.manual).length;
  double get attendanceRatio => total == 0 ? 0 : presentCount / total;
  int get attendancePercent => (attendanceRatio * 100).round();

  int countBy(AttendanceFilter filter) => switch (filter) {
        AttendanceFilter.semua => total,
        AttendanceFilter.hadir => presentCount,
        AttendanceFilter.belum => absentCount,
      };

  /// Peserta terakhir yang berhasil dipindai di halaman Scan QR.
  Participant? get lastScanned => _lastScanned;

  /// Riwayat scan pada sesi ini (terbaru di depan).
  List<Participant> get scanHistory => List.unmodifiable(_scanHistory);

  // --- Aksi dari View ------------------------------------------------------

  void search(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void selectFilter(AttendanceFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    notifyListeners();
  }

  /// Menandai hadir berdasarkan NIM (dari QR maupun input manual).
  CheckInResult checkIn(String nim, {bool manual = false}) {
    final int index =
        _participants.indexWhere((Participant p) => p.nim == nim.trim());
    if (index < 0) return CheckInResult.tidakTerdaftar;
    final Participant current = _participants[index];
    if (current.isPresent) {
      _lastScanned = current;
      notifyListeners();
      return CheckInResult.sudahHadir;
    }
    final Participant updated = current.checkIn(_timeNow(), manual: manual);
    _participants[index] = updated;
    _lastScanned = updated;
    _scanHistory.insert(0, updated);
    notifyListeners();
    return CheckInResult.berhasil;
  }

  /// Simulasi kamera membaca QR: mengambil peserta pertama yang belum hadir.
  ///
  /// TODO: ganti dengan hasil pembacaan kamera (paket `mobile_scanner`).
  CheckInResult? simulateScan() {
    for (final Participant p in _participants) {
      if (!p.isPresent) return checkIn(p.nim);
    }
    return null;
  }

  void clearLastScanned() {
    if (_lastScanned == null) return;
    _lastScanned = null;
    notifyListeners();
  }

  String _timeNow() {
    final DateTime now = _clock();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(now.hour)}.${two(now.minute)}';
  }
}
