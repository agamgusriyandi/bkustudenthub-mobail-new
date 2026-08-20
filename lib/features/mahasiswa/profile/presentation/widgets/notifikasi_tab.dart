import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';

class NotifikasiTabWidget extends StatefulWidget {
  const NotifikasiTabWidget({super.key});

  @override
  State<NotifikasiTabWidget> createState() => _NotifikasiTabWidgetState();
}

class _NotifikasiTabWidgetState extends State<NotifikasiTabWidget> {
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'EmailAchievement',
      'label': 'Prestasi',
      'desc': 'Update verifikasi dan penolakan laporan prestasi.',
      'icon': Icons.emoji_events_rounded,
      'color': const Color(0xFFD97706),
      'bg': const Color(0xFFFEF3C7),
    },
    {
      'id': 'EmailBeasiswa',
      'label': 'Beasiswa',
      'desc': 'Perubahan status pengajuan dan pengingat deadline beasiswa.',
      'icon': Icons.school_rounded,
      'color': const Color(0xFF2563EB),
      'bg': const Color(0xFFEFF6FF),
    },
    {
      'id': 'EmailCounseling',
      'label': 'Konseling',
      'desc': 'Konfirmasi booking dan pengingat sesi konseling.',
      'icon': Icons.handshake_rounded,
      'color': const Color(0xFF059669),
      'bg': const Color(0xFFECFDF5),
    },
    {
      'id': 'EmailVoice',
      'label': 'Student Voice',
      'desc': 'Notifikasi saat aspirasi atau pengaduanmu direspons admin.',
      'icon': Icons.forum_rounded,
      'color': const Color(0xFF7C3AED),
      'bg': const Color(0xFFF3E8FF),
    },
    {
      'id': 'EmailKencana',
      'label': 'Kencana',
      'desc': 'Pengingat kuis dan materi yang belum diselesaikan.',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFEA580C),
      'bg': const Color(0xFFFFEDD5),
    },
    {
      'id': 'EmailNews',
      'label': 'Pengumuman Kampus',
      'desc': 'Berita dan informasi terbaru dari pihak universitas.',
      'icon': Icons.campaign_rounded,
      'color': const Color(0xFF0284C7),
      'bg': const Color(0xFFE0F2FE),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchPreferensiNotif();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final prefs = profile.notifPrefs;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSystemNotifCard(),
        const SizedBox(height: AppSpacing.lg),

        _buildEmailCategoriesCard(profile, prefs),
        const SizedBox(height: AppSpacing.lg),

        _buildInfoBanner(),
        const SizedBox(height: AppSpacing.s80),
      ],
    );
  }

  Widget _buildSystemNotifCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifikasi Dalam Aplikasi',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          const Text(
            'Pemberitahuan real-time melalui panel navigasi aplikasi.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_rounded, size: 18, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semua Notifikasi Sistem',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Selalu mendapatkan update dari portal BKU Student Hub.',
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Wajib Aktif',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                ),
                const SizedBox(width: 6),
                const Switch(
                  value: true,
                  onChanged: null,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCategoriesCard(ProfileProvider profile, Map<String, bool> prefs) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifikasi Email Berbasis Fitur',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          const Text(
            'Pilih kategori update yang ingin diteruskan ke email Anda.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final cat = _categories[index];
              final id = cat['id'] as String;
              final isChecked = prefs[id] ?? true;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isChecked ? Colors.white : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isChecked ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isChecked ? (cat['bg'] as Color) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        size: 19,
                        color: isChecked ? (cat['color'] as Color) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat['label'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isChecked ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat['desc'] as String,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isChecked ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isChecked,
                      activeThumbColor: Colors.white,
                      activeTrackColor: BkuTheme.primary,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFCBD5E1),
                      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                      onChanged: (val) async {
                        await profile.toggleNotifPreference(id, val);
                        if (mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Notifikasi ${cat['label']} ${val ? 'diaktifkan' : 'dinonaktifkan'}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: val ? const Color(0xFF059669) : const Color(0xFF64748B),
                              duration: const Duration(milliseconds: 1500),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD97706)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Catatan: Perubahan preferensi akan segera diterapkan. Kami menyarankan untuk tetap mengaktifkan notifikasi Beasiswa dan Konseling agar kamu tidak melewatkan info penting.',
              style: TextStyle(fontSize: 11, height: 1.4, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
