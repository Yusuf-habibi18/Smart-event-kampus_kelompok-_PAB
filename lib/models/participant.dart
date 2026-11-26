/// Model: peserta yang terdaftar pada event milik Ormawa.
class Participant {
  const Participant({
    required this.name,
    required this.nim,
    required this.program,
    required this.seat,
    this.checkInTime,
    this.manual = false,
  });

  final String name;
  final String nim;
  final String program;
  final String seat;

  /// Jam presensi (mis. "08.12"), null jika belum hadir.
  final String? checkInTime;

  /// true jika presensi ditandai manual oleh panitia (bukan scan QR).
  final bool manual;

  bool get isPresent => checkInTime != null;

  String get initials {
    final List<String> parts =
        name.split(' ').where((String p) => p.isNotEmpty).toList();
    return parts.take(2).map((String p) => p[0]).join().toUpperCase();
  }

  bool matches(String query) {
    if (query.isEmpty) return true;
    final String q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        nim.contains(q) ||
        program.toLowerCase().contains(q);
  }

  Participant checkIn(String time, {bool manual = false}) {
    return Participant(
      name: name,
      nim: nim,
      program: program,
      seat: seat,
      checkInTime: time,
      manual: manual,
    );
  }
}
