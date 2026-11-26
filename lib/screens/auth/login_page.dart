import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';

/// View: halaman masuk.
///
/// Peran, pilihan jenis peserta, status loading, validasi, dan proses login
/// ada di [AuthViewModel]. View hanya menyimpan controller input dan state
/// tampilan (sembunyikan/tampilkan kata sandi).
///
/// Peserta memilih "Saya mahasiswa ITPLN" atau "Saya peserta umum" agar
/// petunjuk kolom email sesuai; jenis akun akhirnya tetap ditentukan dari
/// domain email.
class MasukSmartCampusEvent extends StatefulWidget {
  const MasukSmartCampusEvent({super.key});

  @override
  State<MasukSmartCampusEvent> createState() => _MasukSmartCampusEventState();
}

class _MasukSmartCampusEventState extends State<MasukSmartCampusEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Teks yang berbeda untuk tiap peran ---------------------------------

  static String _idLabel(UserRole role, PesertaType peserta) {
    switch (role) {
      case UserRole.peserta:
        return peserta == PesertaType.mahasiswaItpln ? 'Email kampus' : 'Email';
      case UserRole.ormawa:
        return 'ID Ormawa atau email penyelenggara';
      case UserRole.admin:
        return 'ID Pegawai BKA (NIP)';
    }
  }

  static String _idHint(UserRole role, PesertaType peserta) {
    switch (role) {
      case UserRole.peserta:
        return peserta == PesertaType.mahasiswaItpln
            ? 'nim@itpln.ac.id'
            : 'nama@gmail.com';
      case UserRole.ormawa:
        return 'hima.informatika@kampus.ac.id';
      case UserRole.admin:
        return '198503122010011002';
    }
  }

  static IconData _idIcon(UserRole role) {
    switch (role) {
      case UserRole.peserta:
      case UserRole.ormawa:
        return Icons.alternate_email_rounded;
      case UserRole.admin:
        return Icons.badge_outlined;
    }
  }

  // --- Aksi ----------------------------------------------------------------

  void _changeRole(UserRole role) {
    final AuthViewModel auth = context.read<AuthViewModel>();
    if (role == auth.role || auth.isLoading) return;
    auth.selectRole(role);
    _idController.clear();
    _formKey.currentState?.reset();
  }

  void _choosePeserta(PesertaType type) {
    context.read<AuthViewModel>().choosePeserta(type);
    _formKey.currentState?.reset();
  }

  /// Alur data: input → _idController → AuthViewModel.login() →
  /// Navigator ke beranda peran → identitas tampil di Beranda & Profil.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final AuthViewModel auth = context.read<AuthViewModel>();
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool choseUmum =
        auth.role == UserRole.peserta && auth.pesertaChoice == PesertaType.umum;

    await auth.login(
      id: _idController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;

    // Peserta umum yang ternyata memakai email kampus otomatis jadi mahasiswa.
    if (choseUmum && auth.isMahasiswa) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Email kampus terdeteksi: kamu masuk sebagai Mahasiswa ITPLN.',
          ),
        ),
      );
    }
    navigator.pushNamedAndRemoveUntil(
      auth.role.homeRoute,
      (Route<dynamic> route) => false,
    );
  }

  // --- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final UserRole role = auth.role;
    final PesertaType peserta = auth.pesertaChoice;
    final bool loading = auth.isLoading;

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            const _LoginHero(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const EyebrowText(text: 'Masuk sebagai'),
                        const SizedBox(height: 12),
                        _RoleSelector(selected: role, onChanged: _changeRole),
                        const SizedBox(height: 14),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            role.description,
                            key: ValueKey<UserRole>(role),
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: role != UserRole.peserta
                              ? const SizedBox(width: double.infinity)
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 24),
                                    for (final PesertaType type
                                        in PesertaType.values) ...[
                                      _PesertaChoice(
                                        type: type,
                                        selected: type == peserta,
                                        onTap: () => _choosePeserta(type),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _idController,
                          enabled: !loading,
                          keyboardType: role == UserRole.admin
                              ? TextInputType.number
                              : TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: appInputDecoration(
                            label: _idLabel(role, peserta),
                            hint: _idHint(role, peserta),
                            prefixIcon: _idIcon(role),
                          ),
                          validator: (String? v) => auth.validateId(
                            v,
                            label: _idLabel(role, peserta),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !loading,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _submit(),
                          decoration: appInputDecoration(
                            label: 'Kata sandi',
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              tooltip: _obscure
                                  ? 'Tampilkan kata sandi'
                                  : 'Sembunyikan kata sandi',
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: auth.validatePassword,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => showSnack(
                              context,
                              'Reset kata sandi dilakukan lewat Helpdesk BKA.',
                            ),
                            child: const Text('Lupa kata sandi?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Pressable(
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              boxShadow: AppShadows.lift,
                            ),
                            child: FilledButton(
                              onPressed: loading ? null : _submit,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(54),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Masuk ke Portal'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (role == UserRole.peserta)
                          _FooterLink(
                            question: 'Belum punya akun?',
                            action: 'Daftar sekarang',
                            onTap: () =>
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.daftarAkun),
                          ),
                        if (role == UserRole.ormawa)
                          _FooterLink(
                            question: 'Belum punya akun penyelenggara?',
                            action: 'Ajukan akun',
                            onTap: () =>
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.pengajuanAkun),
                          ),
                        const SizedBox(height: 28),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Data kamu aman dan terlindungi',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Biro Kemahasiswaan & Alumni (BKA)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            letterSpacing: 0.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian-bagian halaman
// ---------------------------------------------------------------------------

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Foto kampus yang memudar ke warna latar halaman.
        SizedBox(
          height: 230,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppImages.campus,
                fit: BoxFit.cover,
                semanticLabel: 'Foto gedung kampus',
                errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                    const ColoredBox(color: AppColors.primarySoft),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.45, 1],
                    colors: [
                      Color(0x590A1A2F),
                      Color(0x000A1A2F),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.raised,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppLogo(size: 30),
                          SizedBox(width: 10),
                          Text(
                            'CampusEvent',
                            style: TextStyle(
                              fontFamily: AppFonts.heading,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EyebrowText(text: 'Portal event kampus ITPLN'),
                  SizedBox(height: 10),
                  Text(
                    'Selamat Datang Kembali',
                    style: TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 30,
                      height: 1.12,
                      letterSpacing: -0.6,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cari event kampus, simpan tiket, dan kumpulkan '
                    'sertifikat dalam satu aplikasi.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});

  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final UserRole role in UserRole.values) ...[
          if (role != UserRole.values.first) const SizedBox(width: 8),
          Expanded(
            child: _RoleTile(
              role: role,
              isSelected: role == selected,
              onTap: () => onChanged(role),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isSelected ? Colors.white : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Peran ${role.label}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          boxShadow: isSelected ? AppShadows.lift : null,
        ),
        child: Material(
          color: isSelected ? AppColors.primary : AppColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(role.icon, size: 22, color: foreground),
                  const SizedBox(height: 6),
                  Text(
                    role.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu pilihan "Saya mahasiswa ITPLN" / "Saya peserta umum".
class _PesertaChoice extends StatelessWidget {
  const _PesertaChoice({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PesertaType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String title = type == PesertaType.mahasiswaItpln
        ? 'Saya mahasiswa ITPLN'
        : 'Saya peserta umum';

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: selected ? AppColors.glow : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                IconSquare(
                  icon: type.icon,
                  size: 42,
                  color: selected ? Colors.white : AppColors.glow,
                  background: selected
                      ? AppColors.primary
                      : AppColors.primarySoft,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type.hint,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.glow : AppColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: AppDecorations.card(radius: AppRadius.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}
