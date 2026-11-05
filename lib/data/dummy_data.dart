// Sumber data contoh (dummy) untuk modul Mahasiswa.
// Bagian ini termasuk lapisan Model: ViewModel mengambil data dari sini.
// Ganti isi list di bawah dengan pemanggilan API saat backend siap.

import '../models/campus_event.dart';
import '../models/completed_event.dart';
import '../models/event_ticket.dart';
import '../models/student_profile.dart';

/// Profil default yang dipakai sebelum mahasiswa login.
const StudentProfile dummyStudent = StudentProfile(
  name: 'Arya Pratama',
  nim: '2110512044',
  program: 'S1 Teknik Informatika',
  faculty: 'Fakultas Ilmu Komputer',
  semester: 6,
  generation: 'Gen 2022',
);

// ---------------------------------------------------------------------------
// Event
// ---------------------------------------------------------------------------

const List<String> eventCategories = [
  'Semua',
  'Akademik & Seminar',
  'Kompetisi',
  'Seni & Musik',
  'Workshop',
];

const List<String> ormawaCategories = [
  'Penalaran',
  'Olahraga',
  'Seni Budaya',
  'Sosial',
];

const List<CampusEvent> dummyEvents = [
  CampusEvent(
    id: 1,
    title: 'National Tech Summit 2025',
    organizer: 'BEM KM X Fak. Ilmu Komputer',
    category: 'Akademik & Seminar',
    ormawa: 'Penalaran',
    dateLabel: 'Sabtu, 24 Mei 2025',
    startTime: '08.30',
    endTime: '13.00',
    location: 'Auditorium Utama & Online Hybrid',
    points: 10,
    quotaLabel: 'Sisa 48 Kuota',
    featured: true,
  ),
  CampusEvent(
    id: 2,
    title: 'Workshop UI/UX Design System: Membangun Portofolio '
        'Standar Industri',
    organizer: 'HIMATIF ITB Kampus Ganesha',
    category: 'Workshop',
    ormawa: 'Penalaran',
    dateLabel: 'Kamis, 15 Mei 2025',
    startTime: '13.00',
    endTime: '16.00',
    location: 'Lab Komputer 3',
    points: 10,
    quotaLabel: 'Sisa 12 Kursi',
  ),
  CampusEvent(
    id: 3,
    title: 'Lomba Debat Konstitusi Nasional & Seminar Kepemudaan '
        'Mahasiswa',
    organizer: 'UKM Debat & Lembaga Hukum',
    category: 'Kompetisi',
    ormawa: 'Penalaran',
    dateLabel: 'Jumat, 16 Mei 2025',
    startTime: '09.00',
    endTime: '15.00',
    location: 'Gedung Serbaguna Lt. 2',
    points: 15,
    quotaLabel: 'Kuota Terbuka',
  ),
  CampusEvent(
    id: 4,
    title: 'Art & Music Fest 2025: Gelar Karya Seni Rupa & Showcase '
        'Ormawa Musik',
    organizer: 'Dewan Mahasiswa & UKM Seni',
    category: 'Seni & Musik',
    ormawa: 'Seni Budaya',
    dateLabel: 'Sabtu, 17 Mei 2025',
    startTime: '15.30',
    endTime: '21.00',
    location: 'Plaza Teater Terbuka',
    points: 8,
    quotaLabel: 'Kuota Terbuka',
  ),
  CampusEvent(
    id: 5,
    title: 'Hackathon Smart Campus 2025',
    organizer: 'HMIF & Lab Rekayasa Perangkat Lunak',
    category: 'Kompetisi',
    ormawa: 'Penalaran',
    dateLabel: 'Minggu, 25 Mei 2025',
    startTime: '09.00',
    endTime: '21.00',
    location: 'Gedung Inovasi Lt. 5',
    points: 20,
    quotaLabel: 'Sisa 20 Tim',
    featured: true,
  ),
  CampusEvent(
    id: 6,
    title: 'Job Fair & Career Talk Kampus',
    organizer: 'Biro Kemahasiswaan & Alumni (BKA)',
    category: 'Akademik & Seminar',
    ormawa: 'Sosial',
    dateLabel: 'Rabu, 28 Mei 2025',
    startTime: '09.00',
    endTime: '16.00',
    location: 'Gedung Rektorat Lt. 1',
    points: 5,
    quotaLabel: 'Sisa 120 Kuota',
    featured: true,
  ),
  CampusEvent(
    id: 7,
    title: 'Turnamen Futsal Antar Fakultas',
    organizer: 'UKM Olahraga',
    category: 'Kompetisi',
    ormawa: 'Olahraga',
    dateLabel: 'Jumat, 30 Mei 2025',
    startTime: '14.00',
    endTime: '18.00',
    location: 'Lapangan Futsal Kampus',
    points: 8,
    quotaLabel: 'Sisa 6 Tim',
    featured: true,
  ),
];

// ---------------------------------------------------------------------------
// Tiket contoh
// ---------------------------------------------------------------------------

const List<EventTicket> dummyActiveTickets = [
  EventTicket(
    ticketId: 'SCE-2025-97310',
    title: 'Workshop UI/UX Design System 2025',
    organizer: 'Himpunan Mahasiswa Informatika',
    dateLabel: 'Sabtu, 28 Mei 2025',
    timeLabel: 'Sesi Siang 13:00 WIB',
    location: 'Gedung D.402 Lt. 4',
    seat: 'A-24',
    refId: 'CS-ACD-2107',
  ),
  EventTicket(
    ticketId: 'SCE-2025-97652',
    title: 'National Tech Summit 2025: AI & Future Ethics',
    organizer: 'BEM Universitas',
    dateLabel: 'Sabtu, 24 Mei 2025',
    timeLabel: 'Sesi Pagi 08:30 WIB',
    location: 'Auditorium Utama Lt. 1',
    seat: 'B-12',
    refId: 'CS-ACD-2111',
    verified: true,
  ),
];

// ---------------------------------------------------------------------------
// Riwayat kegiatan selesai
// ---------------------------------------------------------------------------

const List<CompletedEvent> dummyCompletedEvents = [
  CompletedEvent(
    title: 'Seminar Nasional AI & Karir Masa Depan 2025',
    heldOn: '22 Maret 2025 • Gedung Rektorat',
    points: 10,
    skpiNumber: 'SK-2025/HMIF-0492',
  ),
  CompletedEvent(
    title: 'Pelatihan Kepemimpinan Mahasiswa (LKMM)',
    heldOn: '1 Maret 2025 • Aula Fakultas',
    points: 15,
    skpiNumber: 'SK-2025/BEM-0388',
  ),
  CompletedEvent(
    title: 'Webinar Karir: Menembus Industri Teknologi',
    heldOn: '15 Februari 2025 • Zoom Meeting',
    points: 5,
    skpiNumber: 'SK-2025/HMIF-0352',
  ),
  CompletedEvent(
    title: 'Seminar Kewirausahaan Digital',
    heldOn: '25 Januari 2025 • Auditorium Utama',
    points: 8,
    skpiNumber: 'SK-2025/UKM-0297',
  ),
  CompletedEvent(
    title: 'Workshop Penulisan Karya Ilmiah',
    heldOn: '11 Januari 2025 • Perpustakaan Pusat Lt. 3',
    points: 10,
    skpiNumber: 'SK-2025/PNL-0264',
  ),
];