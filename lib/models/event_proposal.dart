/// Status proposal event selama proses pengajuan ke BKA.
enum ProposalStatus {
  menungguReview('Menunggu Review BKA'),
  perluRevisi('Perlu Revisi'),
  disetujui('Disetujui BKA'),
  ditolak('Ditolak');

  const ProposalStatus(this.label);

  final String label;
}

/// Model: proposal event yang diajukan Ormawa dan diverifikasi Admin (BKA).
class EventProposal {
  const EventProposal({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.ormawa,
    required this.description,
    required this.dateLabel,
    required this.timeLabel,
    required this.location,
    required this.format,
    required this.quota,
    required this.budget,
    required this.skpiPoints,
    required this.advisor,
    required this.fileName,
    required this.submittedLabel,
    this.status = ProposalStatus.menungguReview,
    this.urgent = false,
    this.reviewNote,
    this.registered = 0,
    this.internal = false,
  });

  final int id;

  /// Nomor registrasi proposal, mis. PROP-2025-HMIF-012.
  final String code;
  final String title;
  final String category;

  /// Nama singkat penyelenggara, mis. "HMIF".
  final String ormawa;
  final String description;
  final String dateLabel;
  final String timeLabel;
  final String location;

  /// Luring, Daring, atau Hybrid.
  final String format;

  /// true = khusus mahasiswa ITPLN (Internal ITPLN); false = terbuka umum.
  final bool internal;

  String get audienceLabel => internal ? 'Internal ITPLN' : 'Terbuka untuk Umum';
  final int quota;

  /// Total anggaran (RAB) dalam rupiah.
  final int budget;
  final int skpiPoints;
  final String advisor;
  final String fileName;
  final String submittedLabel;
  final ProposalStatus status;
  final bool urgent;

  /// Catatan dari BKA (wajib diisi saat revisi / tolak).
  final String? reviewNote;

  /// Jumlah peserta terdaftar (hanya relevan setelah disetujui).
  final int registered;

  String get budgetLabel => formatRupiah(budget);
  String get quotaLabel => '$quota Peserta';
  double get registrationRatio =>
      quota == 0 ? 0 : (registered / quota).clamp(0, 1).toDouble();

  bool matches(String query) {
    if (query.isEmpty) return true;
    final String q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        ormawa.toLowerCase().contains(q) ||
        code.toLowerCase().contains(q);
  }

  EventProposal copyWith({
    String? title,
    String? category,
    String? description,
    String? dateLabel,
    String? timeLabel,
    String? location,
    String? format,
    int? quota,
    int? skpiPoints,
    ProposalStatus? status,
    String? reviewNote,
    String? fileName,
    String? submittedLabel,
    bool? urgent,
    bool? internal,
  }) {
    return EventProposal(
      id: id,
      code: code,
      title: title ?? this.title,
      category: category ?? this.category,
      ormawa: ormawa,
      description: description ?? this.description,
      dateLabel: dateLabel ?? this.dateLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      location: location ?? this.location,
      format: format ?? this.format,
      quota: quota ?? this.quota,
      budget: budget,
      skpiPoints: skpiPoints ?? this.skpiPoints,
      advisor: advisor,
      fileName: fileName ?? this.fileName,
      submittedLabel: submittedLabel ?? this.submittedLabel,
      status: status ?? this.status,
      urgent: urgent ?? this.urgent,
      reviewNote: reviewNote ?? this.reviewNote,
      registered: registered,
      internal: internal ?? this.internal,
    );
  }
}

/// 12500000 → "Rp 12.500.000".
String formatRupiah(int value) {
  final String digits = value.toString();
  final StringBuffer out = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
    out.write(digits[i]);
  }
  return 'Rp $out';
}
