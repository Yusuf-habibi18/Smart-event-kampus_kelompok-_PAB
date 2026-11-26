# Smart Campus Event

Aplikasi mobile Flutter untuk menemukan, mendaftar, dan mengelola keikutsertaan mahasiswa ITPLN dan masyarakat umum dalam event non-akademik kampus (seminar, workshop, kompetisi, kegiatan ormawa/UKM).

Project mata kuliah **Pemrograman Aplikasi Bergerak** — Kelompok 1, Program Studi S1 Sistem Informasi, Institut Teknologi PLN.

## Status

Semua modul berjalan dengan data contoh (dummy), belum terhubung ke backend.

**Peserta** (mahasiswa ITPLN dan masyarakat umum memakai tampilan yang sama):

- Masuk dengan email. Pengguna memilih "Saya mahasiswa ITPLN" atau "Saya peserta umum", lalu jenis akun ditentukan otomatis dari domain email (`@itpln.ac.id` → Mahasiswa ITPLN, selain itu → Umum)
- Daftar akun baru dengan deteksi jenis akun langsung dari email dan simulasi email verifikasi
- Beranda dan Cari Event: event unggulan, pencarian, filter kategori dan ormawa. Event berlabel **Internal ITPLN** disembunyikan untuk akun Umum
- Detail event dan formulir pendaftaran, E-Tiket dengan QR presensi
- Event Saya: tiket per status (Mendatang, Selesai, Dibatalkan), pembatalan, ulasan
- Sertifikat, profil, pengaturan. Poin SKPI dan data SIAKAD hanya tampil untuk mahasiswa ITPLN

**Ormawa** dan **Admin (BKA)**:

- Ormawa: dashboard, pengajuan akun dari halaman masuk, form proposal 3 langkah (termasuk pilihan peserta Umum / Internal ITPLN), status pengajuan, edit informasi event, kelola peserta & presensi, pemindai QR (masih simulasi, belum memakai kamera)
- Admin: ringkasan + review cepat, daftar pengajuan akun & proposal, keputusan setujui / revisi / tolak
- Proposal dan akun dibagikan lewat `ProposalViewModel`, jadi keputusan Admin langsung terlihat di sisi Ormawa

Berikutnya: integrasi Firebase, kamera untuk pemindai QR (`mobile_scanner`), notifikasi, kalender event, dan menghubungkan event yang disetujui Admin ke daftar event peserta.

## Desain

Terang, bersih, dan profesional: aksen biru tunggal, kartu putih bergaris tipis, sudut membulat, dan ruang yang lega. Setiap event punya foto (kartu, poster unggulan, halaman detail), dan halaman masuk memakai foto kampus.

- Panel biru memakai gradasi diagonal + ornamen gelembung transparan (`assets/images/pattern_panel.png`) lewat `AppDecorations.brandPanel()`
- Interaktif: header & kartu muncul bertahap, pindah tab memudar, ikon navigasi memantul, lonceng notifikasi bergoyang, efek tekan + getaran halus, foto event "terbang" ke halaman detail (Hero), angka & progress bar beranimasi, tombol simpan favorit, centang sukses yang memantul, tarik-untuk-muat-ulang, dan transisi halaman yang halus. Semua animasi otomatis mati bila "kurangi animasi" aktif di perangkat
- Warna, font, radius, dan bayangan diatur di `lib/core/app_theme.dart`
- Komponen bersama (header, foto event, navigasi mengambang, dll.) ada di `lib/screens/umum/ui_kit.dart`
- Font dibundel di `assets/fonts/` (Plus Jakarta Sans & Inter, lisensi SIL OFL)
- Foto di `assets/images/` berlisensi Unsplash; kredit fotografer ada di `assets/images/CREDITS.md`

## Arsitektur

MVVM dengan [`provider`](https://pub.dev/packages/provider):

```
lib/
├── main.dart        MultiProvider (Auth, Ticket, Proposal, Presensi)
├── core/            rute (app_routes.dart), tema (app_theme.dart), formatter
├── data/            data contoh (dummy_data.dart, dummy_ormawa_data.dart)
├── models/          CampusEvent, EventTicket, StudentProfile, UserRole/PesertaType, EventProposal, ...
├── viewmodels/      Auth, Event, Ticket, Proposal, Presensi
└── screens/         View: auth/, umum/, mahasiswa/ (peserta), panitia/, admin/
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
