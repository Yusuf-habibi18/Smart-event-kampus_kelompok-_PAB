import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/user_role.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';

/// View: daftar akun peserta baru (mahasiswa ITPLN maupun umum).
///
/// Jenis akun dideteksi langsung dari email yang diketik:
/// email @itpln.ac.id → Mahasiswa ITPLN, selain itu → Peserta Umum (kolom
/// asal instansi muncul). Setelah daftar, pengguna diminta memverifikasi
/// email lalu kembali ke halaman masuk.
class DaftarAkunPage extends StatefulWidget {
  const DaftarAkunPage({super.key});

  @override
  State<DaftarAkunPage> createState() => _DaftarAkunPageState();
}

class _DaftarAkunPageState extends State<DaftarAkunPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _institution = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _obscure = true;
  bool _agree = false;
  bool _agreeError = false;

  @override
  void initState() {
    super.initState();
    // Perbarui kartu "jenis akun" setiap kali email berubah.
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _institution.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _hasEmail => _email.text.contains('@');
  PesertaType get _type => PesertaType.fromEmail(_email.text);

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final bool valid = _formKey.currentState?.validate() ?? false;
    setState(() => _agreeError = !_agree);
    if (!valid || !_agree) return;

    final AuthViewModel auth = context.read<AuthViewModel>();
    final NavigatorState navigator = Navigator.of(context);
    await auth.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      institution: _institution.text,
    );
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        icon: const SuccessBurst(icon: Icons.mark_email_read_outlined),
        title: const Text('Cek Email Kamu'),
        content: Text(
          'Kami mengirim tautan verifikasi ke ${_email.text.trim()}. '
          'Buka tautannya, lalu masuk dengan email dan kata sandi ini.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Kembali ke Halaman Masuk'),
          ),
        ],
      ),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AuthViewModel auth = context.watch<AuthViewModel>();
    final bool loading = auth.isLoading;

    return Scaffold(
      appBar: const ScreenAppBar(
        title: 'Daftar Akun',
        subtitle: 'Peserta mahasiswa & umum',
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  const Text(
                    'Buat akun untuk mendaftar event, menyimpan tiket, dan '
                    'menerima sertifikat.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _name,
                    enabled: !loading,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    decoration: appInputDecoration(
                      label: 'Nama lengkap',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    validator: auth.validateName,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _email,
                    enabled: !loading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: appInputDecoration(
                      label: 'Email',
                      hint: 'nim@itpln.ac.id atau nama@gmail.com',
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                    validator: (String? v) => auth.validateEmail(v),
                  ),
                  if (_hasEmail) ...[
                    const SizedBox(height: 12),
                    _AccountTypeCard(type: _type),
                  ],
                  if (_hasEmail && _type == PesertaType.umum) ...[
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _institution,
                      enabled: !loading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: appInputDecoration(
                        label: 'Asal instansi (opsional)',
                        hint: 'mis. Universitas Indonesia / Umum',
                        prefixIcon: Icons.apartment_rounded,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _password,
                    enabled: !loading,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: appInputDecoration(
                      label: 'Kata sandi',
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        tooltip: _obscure
                            ? 'Tampilkan kata sandi'
                            : 'Sembunyikan kata sandi',
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ).copyWith(helperText: 'Minimal 6 karakter'),
                    validator: auth.validatePassword,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _confirm,
                    enabled: !loading,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    decoration: appInputDecoration(
                      label: 'Ulangi kata sandi',
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    validator: (String? v) =>
                        v != _password.text ? 'Kata sandi tidak sama' : null,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _agree,
                    onChanged: loading
                        ? null
                        : (bool? v) => setState(() {
                            _agree = v ?? false;
                            if (_agree) _agreeError = false;
                          }),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Saya setuju dengan ketentuan penggunaan dan '
                      'kebijakan privasi CampusEvent.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    subtitle: _agreeError
                        ? const Text(
                            'Centang persetujuan untuk melanjutkan',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.danger,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: const BoxDecoration(boxShadow: AppShadows.lift),
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
                          : const Text('Buat Akun'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Sudah punya akun? Masuk'),
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

/// Kartu yang menjelaskan jenis akun hasil deteksi email.
class _AccountTypeCard extends StatelessWidget {
  const _AccountTypeCard({required this.type});

  final PesertaType type;

  @override
  Widget build(BuildContext context) {
    final bool campus = type == PesertaType.mahasiswaItpln;
    return SoftPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconSquare(icon: type.icon, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campus ? 'Akun Mahasiswa ITPLN' : 'Akun Peserta Umum',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  campus
                      ? 'Email kampus terdeteksi. Kamu bisa ikut semua event '
                            'dan mendapat poin SKPI.'
                      : 'Kamu bisa ikut event yang terbuka untuk umum. '
                            'Mahasiswa ITPLN? Pakai email @itpln.ac.id.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
