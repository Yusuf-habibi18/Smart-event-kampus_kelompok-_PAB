import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../data/dummy_ormawa_data.dart';
import '../../models/ormawa_account.dart';
import '../../viewmodels/proposal_viewmodel.dart';
import '../mahasiswa/mahasiswa_widgets.dart';
import '../umum/form_widgets.dart';

/// View: Pengajuan Akun Ormawa (dibuka dari halaman login).
///
/// Data formulir dikirim ke [ProposalViewModel.submitAccount] sehingga
/// langsung muncul di antrean verifikasi Admin (BKA).
class PengajuanAkunPage extends StatefulWidget {
  const PengajuanAkunPage({super.key});

  @override
  State<PengajuanAkunPage> createState() => _PengajuanAkunPageState();
}

class _PengajuanAkunPageState extends State<PengajuanAkunPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _shortName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _picName = TextEditingController();
  final TextEditingController _picNim = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _advisor = TextEditingController();

  String _type = organizationTypes.first;
  String? _faculty;
  String? _skFile;
  String? _recommendationFile;
  bool _agreed = false;
  bool _showErrors = false;

  static const Map<String, IconData> _typeIcons = {
    'Himpunan': Icons.groups_rounded,
    'BEM / DPM': Icons.account_balance_rounded,
    'UKM': Icons.sports_basketball_rounded,
    'Komunitas': Icons.diversity_3_rounded,
  };

  @override
  void dispose() {
    for (final TextEditingController c in [
      _fullName,
      _shortName,
      _description,
      _picName,
      _picNim,
      _email,
      _phone,
      _advisor,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String label) =>
      (v ?? '').trim().isEmpty ? '$label wajib diisi' : null;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _showErrors = true);
    final bool formOk = _formKey.currentState!.validate();
    if (!formOk || _skFile == null || _recommendationFile == null || !_agreed) {
      showSnack(context, 'Lengkapi data, dokumen, dan persetujuan.');
      return;
    }

    final ProposalViewModel vm = context.read<ProposalViewModel>();
    final NavigatorState navigator = Navigator.of(context);
    await vm.submitAccount(
      OrmawaAccount(
        id: vm.nextAccountId,
        shortName: _shortName.text.trim().toUpperCase(),
        fullName: _fullName.text.trim(),
        type: _type,
        faculty: _faculty!,
        description: _description.text.trim(),
        picName: _picName.text.trim(),
        picNim: _picNim.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        advisor: _advisor.text.trim(),
        submittedLabel: 'Baru saja',
      ),
    );
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        icon: const SuccessBurst(icon: Icons.mark_email_read_rounded),
        title: const Text('Pengajuan Terkirim'),
        content: Text(
          'Pengajuan akun ${_shortName.text.trim().toUpperCase()} sedang '
          'diverifikasi BKA (maks. 3 hari kerja). Notifikasi dikirim ke '
          '${_email.text.trim()}.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kembali ke Login'),
          ),
        ],
      ),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool submitting = context.watch<ProposalViewModel>().isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScreenAppBar(
        title: 'Pengajuan Akun Ormawa',
        subtitle: 'Registrasi penyelenggara event',
        actions: [
          IconButton(
            tooltip: 'Bantuan',
            onPressed: () => showComingSoon(context, 'Bantuan'),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                const _IntroBanner(),
                const SizedBox(height: 16),
                _sectionOrganization(),
                const SizedBox(height: 16),
                _sectionPic(),
                const SizedBox(height: 16),
                _sectionDocuments(),
                const SizedBox(height: 16),
                FormSectionCard(
                  title: 'Dosen Pembina / Pendamping',
                  icon: Icons.school_outlined,
                  children: [
                    const FieldLabel(
                      'Nama Dosen Pembina & NIP',
                      required: true,
                    ),
                    TextFormField(
                      controller: _advisor,
                      decoration: appInputDecoration(
                        hint: 'mis. Dr. Hendra Kusuma, M.Kom. - NIP 1980...',
                        prefixIcon: Icons.person_search_outlined,
                      ),
                      validator: (String? v) => _required(v, 'Dosen pembina'),
                    ),
                    const SizedBox(height: 10),
                    const NoteBox.success(
                      text:
                          'Dosen pembina akan menerima email konfirmasi '
                          'pendampingan.',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                  child: CheckboxListTile(
                    value: _agreed,
                    onChanged: (bool? v) =>
                        setState(() => _agreed = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'Saya menyatakan seluruh data dan dokumen yang diunggah '
                      'adalah sah, serta bersedia mematuhi Kode Etik '
                      'Penyelenggaraan Kegiatan Kampus.',
                      style: TextStyle(fontSize: 12.5, height: 1.45),
                    ),
                    subtitle: _showErrors && !_agreed
                        ? const Text(
                            'Persetujuan wajib dicentang',
                            style: TextStyle(color: AppColors.danger),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        footnote: 'Verifikasi oleh BKA maksimal 3 hari kerja.',
        children: [
          OutlinedButton.icon(
            onPressed: submitting
                ? null
                : () => showSnack(context, 'Draf pengajuan disimpan.'),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Draf'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: submitting ? null : _submit,
              iconAlignment: IconAlignment.end,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.surface,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Kirim Pengajuan Akun'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionOrganization() {
    return FormSectionCard(
      title: 'Informasi Dasar Organisasi',
      icon: Icons.info_outline_rounded,
      children: [
        const FieldLabel('Tipe Organisasi', required: true),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.8,
          children: [
            for (final String t in organizationTypes)
              _TypeOption(
                label: t,
                icon: _typeIcons[t] ?? Icons.groups_rounded,
                selected: _type == t,
                onTap: () => setState(() => _type = t),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const FieldLabel('Nama Organisasi / Lembaga', required: true),
        TextFormField(
          controller: _fullName,
          textInputAction: TextInputAction.next,
          decoration: appInputDecoration(
            hint: 'Himpunan Mahasiswa Informatika',
            prefixIcon: Icons.apartment_rounded,
          ),
          validator: (String? v) => _required(v, 'Nama organisasi'),
        ),
        const SizedBox(height: 16),
        const FieldLabel('Singkatan', required: true),
        TextFormField(
          controller: _shortName,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.characters,
          decoration: appInputDecoration(hint: 'HMIF'),
          validator: (String? v) {
            final String text = (v ?? '').trim();
            if (text.isEmpty) return 'Singkatan wajib diisi';
            if (text.length > 10) return 'Maksimal 10 karakter';
            return null;
          },
        ),
        const SizedBox(height: 16),
        const FieldLabel('Fakultas / Jurusan Naungan', required: true),
        DropdownButtonFormField<String>(
          initialValue: _faculty,
          isExpanded: true,
          decoration: appInputDecoration(
            hint: 'Pilih fakultas',
            prefixIcon: Icons.account_tree_outlined,
          ),
          items: [
            for (final String f in facultyOptions)
              DropdownMenuItem(value: f, child: Text(f)),
          ],
          onChanged: (String? v) => setState(() => _faculty = v),
          validator: (String? v) => v == null ? 'Pilih fakultas' : null,
        ),
        const SizedBox(height: 16),
        const FieldLabel(
          'Deskripsi Organisasi & Program Kerja',
          required: true,
        ),
        TextFormField(
          controller: _description,
          minLines: 3,
          maxLines: 5,
          maxLength: 300,
          decoration: appInputDecoration(
            hint: 'Visi organisasi dan program kerja utama periode ini',
          ),
          validator: (String? v) => (v ?? '').trim().length < 20
              ? 'Deskripsi minimal 20 karakter'
              : null,
        ),
      ],
    );
  }

  Widget _sectionPic() {
    return FormSectionCard(
      title: 'Penanggung Jawab & Kontak Resmi',
      icon: Icons.contact_phone_outlined,
      children: [
        const FieldLabel('Nama Ketua / PIC Utama', required: true),
        TextFormField(
          controller: _picName,
          textInputAction: TextInputAction.next,
          decoration: appInputDecoration(
            hint: 'Nama lengkap',
            prefixIcon: Icons.person_outline_rounded,
          ),
          validator: (String? v) => _required(v, 'Nama PIC'),
        ),
        const SizedBox(height: 16),
        const FieldLabel('NIM Ketua', required: true),
        TextFormField(
          controller: _picNim,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: appInputDecoration(
            hint: '2110512044',
            prefixIcon: Icons.badge_outlined,
          ),
          validator: (String? v) =>
              (v ?? '').trim().length < 8 ? 'NIM minimal 8 digit' : null,
        ),
        const SizedBox(height: 16),
        const FieldLabel('Email Resmi Organisasi', required: true),
        TextFormField(
          controller: _email,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          decoration: appInputDecoration(
            hint: 'hmif@kampus.ac.id',
            prefixIcon: Icons.mail_outline_rounded,
          ),
          validator: (String? v) {
            final String text = (v ?? '').trim();
            if (text.isEmpty) return 'Email wajib diisi';
            if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(text)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        const Text(
          'Disarankan email domain kampus agar verifikasi lebih cepat.',
          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        const FieldLabel('Nomor WhatsApp Aktif PIC', required: true),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: appInputDecoration(
            hint: '081234567890',
            prefixIcon: Icons.phone_outlined,
          ),
          validator: (String? v) {
            final String text = (v ?? '').trim();
            if (!RegExp(r'^(08|628)\d{8,11}$').hasMatch(text)) {
              return 'Nomor WhatsApp tidak valid (awali 08)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _sectionDocuments() {
    Widget upload({
      required String label,
      required String? file,
      required String fileName,
      required ValueChanged<String?> onChanged,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label, required: true),
          if (file == null) ...[
            UploadBox(
              label: 'Ketuk untuk unggah berkas',
              hint: 'Format PDF / JPG, maksimal 5 MB',
              onTap: () => onChanged(fileName),
            ),
            if (_showErrors)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Dokumen wajib diunggah',
                  style: TextStyle(fontSize: 12, color: AppColors.danger),
                ),
              ),
          ] else
            FileTile(
              fileName: file,
              caption: 'PDF • 1,2 MB • Siap diverifikasi',
              trailing: IconButton(
                tooltip: 'Hapus berkas',
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
        ],
      );
    }

    final String slug = _shortName.text.trim().isEmpty
        ? 'ORMAWA'
        : _shortName.text.trim().toUpperCase();

    return FormSectionCard(
      title: 'Dokumen Legalitas & Persyaratan',
      icon: Icons.folder_open_outlined,
      children: [
        upload(
          label: 'SK Kepengurusan Aktif',
          file: _skFile,
          fileName: 'SK_Kepengurusan_${slug}_2025.pdf',
          onChanged: (String? f) => setState(() => _skFile = f),
        ),
        const SizedBox(height: 16),
        upload(
          label: 'Surat Rekomendasi Dosen Pembina',
          file: _recommendationFile,
          fileName: 'Rekomendasi_Pembina_$slug.pdf',
          onChanged: (String? f) => setState(() => _recommendationFile = f),
        ),
      ],
    );
  }
}

class _IntroBanner extends StatelessWidget {
  const _IntroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.brandPanel(),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Color(0x26FFFFFF),
            child: Icon(Icons.verified_user_outlined, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PERIODE 2025/2026',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    PillBadge(
                      text: 'Dibuka',
                      background: Colors.white,
                      foreground: AppColors.glow,
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Daftarkan organisasi Anda sebagai penyelenggara event. '
                  'Akun aktif setelah diverifikasi Biro Kemahasiswaan & '
                  'Alumni (BKA).',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Color(0xE6FFFFFF),
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

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.glow,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
