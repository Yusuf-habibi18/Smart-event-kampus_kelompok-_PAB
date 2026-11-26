import 'user_role.dart';

/// Model: identitas peserta yang sedang masuk.
///
/// Dipakai untuk mahasiswa ITPLN maupun peserta umum. Untuk peserta umum,
/// field akademik ([nim], [program], [faculty]) kosong dan [institution]
/// berisi asal instansi (opsional).
class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.nim,
    required this.program,
    required this.faculty,
    required this.semester,
    required this.generation,
    this.email = '',
    this.type = PesertaType.mahasiswaItpln,
    this.institution,
  });

  final String name;
  final String nim;
  final String program;
  final String faculty;
  final int semester;
  final String generation;
  final String email;
  final PesertaType type;

  /// Asal instansi peserta umum (mis. "Universitas Indonesia").
  final String? institution;

  bool get isMahasiswa => type == PesertaType.mahasiswaItpln;

  /// Baris identitas singkat di bawah nama.
  String get identityLine => isMahasiswa
      ? 'NIM $nim • $program'
      : (institution?.isNotEmpty ?? false)
          ? 'Peserta Umum • $institution'
          : 'Peserta Umum';

  String get initials {
    final List<String> parts =
        name.split(' ').where((String p) => p.isNotEmpty).toList();
    return parts.take(2).map((String p) => p[0]).join().toUpperCase();
  }

  StudentProfile copyWith({
    String? name,
    String? nim,
    String? email,
    PesertaType? type,
    String? institution,
  }) {
    return StudentProfile(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      program: program,
      faculty: faculty,
      semester: semester,
      generation: generation,
      email: email ?? this.email,
      type: type ?? this.type,
      institution: institution ?? this.institution,
    );
  }
}
