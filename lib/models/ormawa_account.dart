/// Status pengajuan akun penyelenggara (Ormawa) ke BKA.
enum AccountStatus {
  menunggu('Menunggu Verifikasi'),
  perluRevisi('Perlu Revisi'),
  terverifikasi('Terverifikasi BKA'),
  ditolak('Ditolak');

  const AccountStatus(this.label);

  final String label;
}

/// Model: pengajuan akun organisasi mahasiswa sebagai penyelenggara event.
class OrmawaAccount {
  const OrmawaAccount({
    required this.id,
    required this.shortName,
    required this.fullName,
    required this.type,
    required this.faculty,
    required this.description,
    required this.picName,
    required this.picNim,
    required this.email,
    required this.phone,
    required this.advisor,
    required this.submittedLabel,
    this.status = AccountStatus.menunggu,
    this.urgent = false,
    this.skNumber,
    this.reviewNote,
  });

  final int id;

  /// Singkatan, mis. "HMIF".
  final String shortName;
  final String fullName;

  /// Himpunan, BEM / DPM, UKM, atau Komunitas.
  final String type;
  final String faculty;
  final String description;
  final String picName;
  final String picNim;
  final String email;
  final String phone;
  final String advisor;
  final String submittedLabel;
  final AccountStatus status;
  final bool urgent;

  /// Nomor SK legalitas, terisi setelah diverifikasi BKA.
  final String? skNumber;
  final String? reviewNote;

  String get initials {
    final String source = shortName.isNotEmpty ? shortName : fullName;
    return source.length <= 3
        ? source.toUpperCase()
        : source.substring(0, 2).toUpperCase();
  }

  bool matches(String query) {
    if (query.isEmpty) return true;
    final String q = query.toLowerCase();
    return shortName.toLowerCase().contains(q) ||
        fullName.toLowerCase().contains(q) ||
        picName.toLowerCase().contains(q);
  }

  OrmawaAccount copyWith({
    AccountStatus? status,
    String? skNumber,
    String? reviewNote,
  }) {
    return OrmawaAccount(
      id: id,
      shortName: shortName,
      fullName: fullName,
      type: type,
      faculty: faculty,
      description: description,
      picName: picName,
      picNim: picNim,
      email: email,
      phone: phone,
      advisor: advisor,
      submittedLabel: submittedLabel,
      status: status ?? this.status,
      urgent: urgent,
      skNumber: skNumber ?? this.skNumber,
      reviewNote: reviewNote ?? this.reviewNote,
    );
  }
}
