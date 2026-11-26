// Sumber data contoh (dummy) untuk modul Ormawa (Panitia) dan Admin (BKA).
// Ganti isi list di bawah dengan pemanggilan API saat backend siap.

import '../models/event_proposal.dart';
import '../models/ormawa_account.dart';
import '../models/participant.dart';

/// Akun Ormawa yang sedang masuk (sudah terverifikasi BKA).
const OrmawaAccount dummyMyOrmawa = OrmawaAccount(
  id: 1,
  shortName: 'HMIF',
  fullName: 'Himpunan Mahasiswa Informatika',
  type: 'Himpunan',
  faculty: 'Fakultas Teknologi Informasi',
  description: 'Organisasi kemahasiswaan tingkat program studi yang menaungi '
      'pengembangan keilmuan dan minat mahasiswa Informatika.',
  picName: 'Arya Pratama',
  picNim: '2110512044',
  email: 'hmif@kampus.ac.id',
  phone: '+62 812-9843-2210',
  advisor: 'Dr. Ir. Hendra Kusuma, M.Kom.',
  submittedLabel: '12 Agustus 2025',
  status: AccountStatus.terverifikasi,
  skNumber: 'SK/BKA/2025/041',
);

const List<String> organizationTypes = [
  'Himpunan',
  'BEM / DPM',
  'UKM',
  'Komunitas',
];

const List<String> facultyOptions = [
  'Fakultas Teknologi Informasi',
  'Fakultas Teknik',
  'Fakultas Ekonomi & Bisnis',
  'Fakultas Ilmu Sosial',
  'Tingkat Universitas',
];

const List<String> proposalCategories = [
  'Akademik & Seminar',
  'Workshop',
  'Kompetisi',
  'Seni & Musik',
  'Sosial & Pengabdian',
];

const List<String> eventFormats = ['Luring', 'Daring', 'Hybrid'];

// ---------------------------------------------------------------------------
// Proposal event
// ---------------------------------------------------------------------------

const List<EventProposal> dummyProposals = [
  EventProposal(
    id: 1,
    code: 'PROP-2025-HMIF-012',
    title: 'Hackathon Smart Campus 2025',
    internal: true,
    category: 'Kompetisi',
    ormawa: 'HMIF',
    description: 'Kompetisi 24 jam membangun solusi digital untuk '
        'permasalahan kampus, terbuka untuk tim lintas program studi.',
    dateLabel: 'Minggu, 25 Mei 2025',
    timeLabel: '09.00 - 21.00 WIB',
    location: 'Gedung Inovasi Lt. 5',
    format: 'Luring',
    quota: 120,
    budget: 18500000,
    skpiPoints: 20,
    advisor: 'Dr. Ir. Hendra Kusuma, M.Kom.',
    fileName: 'Proposal_Hackathon_2025_v2.pdf',
    submittedLabel: '2 hari lalu',
  ),
  EventProposal(
    id: 2,
    code: 'PROP-2025-HMIF-009',
    title: 'Workshop UI/UX Design System 2025',
    category: 'Workshop',
    ormawa: 'HMIF',
    description: 'Pelatihan praktik membangun design system dengan Figma, '
        'dari token warna sampai komponen siap pakai.',
    dateLabel: 'Sabtu, 28 Mei 2025',
    timeLabel: '13.00 - 16.00 WIB',
    location: 'Gedung D.402 Lt. 4',
    format: 'Hybrid',
    quota: 100,
    budget: 7250000,
    skpiPoints: 10,
    advisor: 'Dr. Ir. Hendra Kusuma, M.Kom.',
    fileName: 'Proposal_Workshop_UIUX_2025.pdf',
    submittedLabel: '3 minggu lalu',
    status: ProposalStatus.disetujui,
    registered: 8,
  ),
  EventProposal(
    id: 3,
    code: 'PROP-2025-HMIF-011',
    title: 'Malam Keakraban Informatika 2025',
    internal: true,
    category: 'Sosial & Pengabdian',
    ormawa: 'HMIF',
    description: 'Malam keakraban untuk menyambut mahasiswa baru '
        'Informatika angkatan 2025.',
    dateLabel: 'Jumat, 6 Juni 2025',
    timeLabel: '18.00 - 22.00 WIB',
    location: 'Villa Puncak Asri, Bogor',
    format: 'Luring',
    quota: 150,
    budget: 24000000,
    skpiPoints: 5,
    advisor: 'Dr. Ir. Hendra Kusuma, M.Kom.',
    fileName: 'Proposal_Makrab_2025.pdf',
    submittedLabel: '1 minggu lalu',
    status: ProposalStatus.perluRevisi,
    reviewNote: 'Lampirkan surat izin orang tua dan rincian transportasi '
        'pada RAB. Rasio pendamping dosen minimal 1:30 peserta.',
  ),
  EventProposal(
    id: 4,
    code: 'PROP-2025-BEM-021',
    title: 'Grand Summit Kewirausahaan Kampus 2025',
    category: 'Akademik & Seminar',
    ormawa: 'BEM Universitas',
    description: 'Konferensi kewirausahaan mahasiswa yang menghadirkan '
        'founder startup, investor, dan pameran produk UMKM kampus.',
    dateLabel: 'Sabtu, 28 Juni 2025',
    timeLabel: '08.00 - 15.00 WIB',
    location: 'Auditorium Utama',
    format: 'Luring',
    quota: 500,
    budget: 35000000,
    skpiPoints: 10,
    advisor: 'Dr. Siti Rahmawati, M.M.',
    fileName: 'Proposal_Grand_Summit_2025.pdf',
    submittedLabel: 'Hari ini, 08.14',
    urgent: true,
  ),
  EventProposal(
    id: 5,
    code: 'PROP-2025-BEMFT-007',
    title: 'National Tech Summit 2025',
    category: 'Akademik & Seminar',
    ormawa: 'BEM Fakultas Teknik',
    description: 'Seminar nasional teknologi dengan sesi panel AI & '
        'etika masa depan.',
    dateLabel: 'Sabtu, 24 Mei 2025',
    timeLabel: '08.30 - 13.00 WIB',
    location: 'Auditorium Utama & Online',
    format: 'Hybrid',
    quota: 300,
    budget: 15000000,
    skpiPoints: 10,
    advisor: 'Prof. Bambang Wijaya, Ph.D.',
    fileName: 'Proposal_NTS_2025.pdf',
    submittedLabel: 'Kemarin, 16.40',
  ),
  EventProposal(
    id: 6,
    code: 'PROP-2025-UKMS-004',
    title: 'Art & Music Fest 2025',
    category: 'Seni & Musik',
    ormawa: 'UKM Musik & Seni',
    description: 'Gelar karya seni rupa dan showcase musik ormawa.',
    dateLabel: 'Sabtu, 17 Mei 2025',
    timeLabel: '15.30 - 21.00 WIB',
    location: 'Plaza Teater Terbuka',
    format: 'Luring',
    quota: 400,
    budget: 21000000,
    skpiPoints: 8,
    advisor: 'Drs. Agus Salim, M.Sn.',
    fileName: 'Proposal_ArtFest_2025.pdf',
    submittedLabel: '1 bulan lalu',
    status: ProposalStatus.disetujui,
    registered: 312,
  ),
];

// ---------------------------------------------------------------------------
// Pengajuan akun Ormawa (antrean Admin)
// ---------------------------------------------------------------------------

const List<OrmawaAccount> dummyAccountApplications = [
  OrmawaAccount(
    id: 2,
    shortName: 'HMSI',
    fullName: 'Himpunan Mahasiswa Sistem Informasi',
    type: 'Himpunan',
    faculty: 'Fakultas Teknologi Informasi',
    description: 'Himpunan program studi S1 Sistem Informasi.',
    picName: 'Nadia Putri',
    picNim: '2210512031',
    email: 'hmsi@kampus.ac.id',
    phone: '+62 813-2211-0098',
    advisor: 'Rina Marlina, S.Kom., M.T.',
    submittedLabel: 'Hari ini, 09.20',
    urgent: true,
  ),
  OrmawaAccount(
    id: 3,
    shortName: 'BEM FT',
    fullName: 'BEM Fakultas Teknik',
    type: 'BEM / DPM',
    faculty: 'Fakultas Teknik',
    description: 'Badan Eksekutif Mahasiswa tingkat Fakultas Teknik.',
    picName: 'Rizky Maulana',
    picNim: '2110411007',
    email: 'bemft@kampus.ac.id',
    phone: '+62 857-1100-4432',
    advisor: 'Prof. Bambang Wijaya, Ph.D.',
    submittedLabel: 'Kemarin, 14.05',
  ),
  OrmawaAccount(
    id: 4,
    shortName: 'UKMS',
    fullName: 'UKM Musik & Seni',
    type: 'UKM',
    faculty: 'Tingkat Universitas',
    description: 'Unit kegiatan mahasiswa bidang musik dan seni rupa.',
    picName: 'Dimas Anggara',
    picNim: '2210311019',
    email: 'ukmseni@kampus.ac.id',
    phone: '+62 821-7788-1200',
    advisor: 'Drs. Agus Salim, M.Sn.',
    submittedLabel: '3 hari lalu',
    status: AccountStatus.perluRevisi,
    reviewNote: 'SK kepengurusan sudah kedaluwarsa, unggah SK periode '
        '2025/2026.',
  ),
];

// ---------------------------------------------------------------------------
// Peserta event aktif (Workshop UI/UX Design System 2025)
// ---------------------------------------------------------------------------

const List<Participant> dummyParticipants = [
  Participant(
    name: 'Arya Pratama',
    nim: '2110512044',
    program: 'S1 Teknik Informatika',
    seat: 'A-24',
    checkInTime: '12.48',
  ),
  Participant(
    name: 'Siti Nurhaliza',
    nim: '2110512061',
    program: 'S1 Sistem Informasi',
    seat: 'B-03',
    checkInTime: '12.51',
  ),
  Participant(
    name: 'Budi Santoso',
    nim: '2210512008',
    program: 'S1 Teknik Elektro',
    seat: 'C-16',
  ),
  Participant(
    name: 'Dimas Anggara',
    nim: '2210311019',
    program: 'D3 Manajemen Informatika',
    seat: 'D-09',
  ),
  Participant(
    name: 'Nadia Putri',
    nim: '2210512031',
    program: 'S1 Sistem Informasi',
    seat: 'A-07',
    checkInTime: '12.40',
  ),
  Participant(
    name: 'Rizky Maulana',
    nim: '2110411007',
    program: 'S1 Teknik Industri',
    seat: 'B-15',
  ),
  Participant(
    name: 'Fajar Nugroho',
    nim: '2310512002',
    program: 'S1 Teknik Informatika',
    seat: 'C-02',
    checkInTime: '12.55',
  ),
  Participant(
    name: 'Laras Wulandari',
    nim: '2310512077',
    program: 'S1 Teknik Informatika',
    seat: 'D-21',
  ),
];
