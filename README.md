# Smart Campus Event

Aplikasi mobile Flutter untuk menemukan, mendaftar, dan mengelola keikutsertaan mahasiswa dalam event non-akademik kampus (seminar, workshop, kompetisi, kegiatan ormawa/UKM).

Project mata kuliah **Pemrograman Aplikasi Bergerak** — Kelompok 1, Program Studi S1 Sistem Informasi, Institut Teknologi PLN.

## Status (milestone UTS)

Modul **Mahasiswa** sudah berjalan dari awal sampai akhir dengan data contoh (dummy):

- Login berbasis peran (Mahasiswa, Ormawa, Admin) dengan validasi NIM dan kata sandi
- Beranda dan Eksplorasi: daftar event, event unggulan, pencarian, filter kategori dan ormawa
- Detail event dan formulir pendaftaran (nomor WhatsApp, jalur partisipasi, peminatan)
- E-Tiket dengan QR presensi (QR masih placeholder)
- Event Saya: tiket per status (Mendatang, Selesai, Dibatalkan), pembatalan, ulasan
- Sertifikat, poin SKPI, profil, pengaturan, logout

Modul **Ormawa** (pengajuan event) dan **Admin** (persetujuan) dijadwalkan pada sprint berikutnya, bersama integrasi Firebase, pemindai QR, notifikasi, dan kalender event.

## Arsitektur

MVVM dengan [`provider`](https://pub.dev/packages/provider):

```
lib/
├── main.dart        MultiProvider (AuthViewModel, TicketViewModel)
├── core/            rute (app_routes.dart) dan tema (app_theme.dart)
├── data/            data contoh (dummy_data.dart)
├── models/          Model: CampusEvent, EventTicket, StudentProfile, ...
├── viewmodels/      ViewModel: AuthViewModel, EventViewModel, TicketViewModel
└── screens/         View: auth/, umum/, mahasiswa/, panitia/, admin/
```

## Menjalankan

```bash
flutter pub get
flutter run -d chrome     # atau pilih emulator/perangkat Android
```

## Pengujian

```bash
flutter analyze
flutter test              # unit test ViewModel dan widget test alur utama
```
