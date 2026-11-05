/// Model: identitas mahasiswa yang sedang masuk.
class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.nim,
    required this.program,
    required this.faculty,
    required this.semester,
    required this.generation,
  });

  final String name;
  final String nim;
  final String program;
  final String faculty;
  final int semester;
  final String generation;

  String get initials {
    final List<String> parts =
        name.split(' ').where((String p) => p.isNotEmpty).toList();
    return parts.take(2).map((String p) => p[0]).join().toUpperCase();
  }

  StudentProfile copyWith({String? name, String? nim}) {
    return StudentProfile(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      program: program,
      faculty: faculty,
      semester: semester,
      generation: generation,
    );
  }
}
