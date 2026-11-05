import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// View: halaman login.
///
/// Peran terpilih, status loading, validasi, dan proses login ada di
/// [AuthViewModel]. View hanya menyimpan controller input dan state tampilan
/// (sembunyikan/tampilkan kata sandi).
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

  static String _idLabel(UserRole role) {
    switch (role) {
      case UserRole.mahasiswa:
        return 'Nomor Induk Mahasiswa (NIM)';
      case UserRole.ormawa:
        return 'ID Ormawa atau Email Penyelenggara';
      case UserRole.admin:
        return 'ID Pegawai BKA (NIP)';
    }
  }

  static String _idHint(UserRole role) {
    switch (role) {
      case UserRole.mahasiswa:
        return '2110512044';
      case UserRole.ormawa:
        return 'hima.informatika@kampus.ac.id';
      case UserRole.admin:
        return '198503122010011002';
    }
  }

  static TextInputType _idKeyboard(UserRole role) {
    switch (role) {
      case UserRole.mahasiswa:
      case UserRole.admin:
        return TextInputType.number;
      case UserRole.ormawa:
        return TextInputType.emailAddress;
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

  /// Alur data: input → _idController → AuthViewModel.login() →
  /// Navigator ke Beranda → NIM tampil di Beranda, Profil, dan E-Tiket.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final AuthViewModel auth = context.read<AuthViewModel>();
    final NavigatorState navigator = Navigator.of(context);
    await auth.login(
      id: _idController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil(
      auth.role.homeRoute,
      (Route<dynamic> route) => false,
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // --- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final UserRole role = auth.role;
    final bool loading = auth.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.accentDark,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Portal Terintegrasi Kampus',
                            style: TextStyle(
                              color: AppColors.accentDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selamat Datang Kembali',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Akses tiket kegiatan, registrasi ormawa, dan perizinan '
                      'ruang kampus dalam satu genggaman.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Pilih Peran Anda',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RoleSelector(selected: role, onChanged: _changeRole),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _idController,
                      enabled: !loading,
                      keyboardType: _idKeyboard(role),
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: appInputDecoration(
                        label: _idLabel(role),
                        hint: _idHint(role),
                        prefixIcon: Icons.badge_outlined,
                      ),
                      validator: (String? v) => auth.validateId(v, label: _idLabel(role)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !loading,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: appInputDecoration(
                        label: 'Kata Sandi',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          tooltip: _obscure
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: auth.validatePassword,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showInfo(
                          'Reset kata sandi dilakukan lewat portal SSO atau '
                          'Helpdesk BKA.',
                        ),
                        child: const Text('Lupa kata sandi?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
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
                    const SizedBox(height: 20),
                    const _OrDivider(),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: loading
                          ? null
                          : () => _showInfo(
                                'Login SSO akan aktif setelah terhubung ke '
                                'SIAKAD kampus.',
                              ),
                      icon: const Icon(Icons.vpn_key_outlined, size: 20),
                      label: const Text('Masuk dengan Akun SSO Kampus'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        foregroundColor: AppColors.navy,
                        side: const BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (role == UserRole.ormawa) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLow,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Belum punya akun penyelenggara?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.pengajuanAkun),
                              child: const Text('Ajukan akun'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const Center(
                      child: Text(
                        'Dilindungi enkripsi SSL 256-bit\n'
                        'Biro Kemahasiswaan & Alumni (BKA)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.6,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget pendukung
// ---------------------------------------------------------------------------

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Asset Image: logo aplikasi dari assets/images/logo.png.
        Image.asset(
          AppImages.logo,
          width: 48,
          height: 48,
          semanticLabel: 'Logo CampusEvent',
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CampusEvent',
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: AppColors.navy,
              ),
            ),
            Text(
              'Universitas Terpadu',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
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
    final Color foreground = isSelected ? Colors.white : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Peran ${role.label}',
      child: Material(
        color: isSelected ? AppColors.navy : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? AppColors.navy : AppColors.outline,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.outline, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        Expanded(child: Divider(color: AppColors.outline, height: 1)),
      ],
    );
  }
}