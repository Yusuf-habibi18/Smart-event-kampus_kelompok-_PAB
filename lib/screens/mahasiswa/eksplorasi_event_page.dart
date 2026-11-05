import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/campus_event.dart';
import '../../viewmodels/event_viewmodel.dart';
import 'mahasiswa_widgets.dart';

/// View: tab "Eksplorasi", semua event dengan pencarian dan filter.
///
/// State filter disimpan di [EventViewModel] (disediakan oleh MahasiswaShell),
/// sehingga Beranda dapat membuka tab ini dengan filter ormawa tertentu.
class EksplorasiEventPage extends StatefulWidget {
  const EksplorasiEventPage({super.key});

  @override
  State<EksplorasiEventPage> createState() => _EksplorasiEventPageState();
}

class _EksplorasiEventPageState extends State<EksplorasiEventPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EventViewModel vm = context.watch<EventViewModel>();
    final List<CampusEvent> results = vm.filteredEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(
        title: 'Eksplorasi Event',
        subtitle: 'Temukan seminar, lomba, dan workshop kampus',
        showBack: false,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    decoration: appInputDecoration(
                      hint: 'Cari judul, penyelenggara, atau lokasi',
                      prefixIcon: Icons.search_rounded,
                      suffixIcon: vm.query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _search.clear();
                                vm.clearSearch();
                              },
                            ),
                    ),
                    onChanged: vm.search,
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: vm.categories.length,
                    separatorBuilder: (BuildContext _, int index) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int i) {
                      final String label = vm.categories[i];
                      final bool selected = vm.category == label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: AppColors.navy,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                        ),
                        onSelected: (_) => vm.selectCategory(label),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      for (final String? o in <String?>[
                        null,
                        ...vm.ormawaOptions,
                      ]) ...[
                        FilterChip(
                          label: Text(o == null ? 'Semua Ormawa' : 'Ormawa $o'),
                          selected: vm.ormawa == o,
                          showCheckmark: false,
                          selectedColor: AppColors.accentSoft,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: vm.ormawa == o
                                ? AppColors.accentDark
                                : AppColors.textSecondary,
                          ),
                          onSelected: (_) => vm.selectOrmawa(o),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${vm.totalResults} event ditemukan',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? const SingleChildScrollView(
                          child: EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'Event tidak ditemukan',
                            message: 'Coba ubah kata kunci atau filter '
                                'kategori yang dipilih.',
                          ),
                        )
                      : ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: results.length,
                          separatorBuilder: (BuildContext _, int index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (BuildContext context, int i) {
                            final CampusEvent event = results[i];
                            return EventCard(
                              event: event,
                              onTap: () => openEventDetail(context, event),
                            );
                          },
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
