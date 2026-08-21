import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/dashboard/presentation/widgets/ipk_chart_card.dart';

class AkademikTabWidget extends StatefulWidget {
  const AkademikTabWidget({super.key});

  @override
  State<AkademikTabWidget> createState() => _AkademikTabWidgetState();
}

class _AkademikTabWidgetState extends State<AkademikTabWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchAkademikData();
    });
  }

  Color _getGradeColor(String? grade) {
    final g = (grade ?? '').toUpperCase().trim();
    if (g.startsWith('A')) return const Color(0xFF059669);
    if (g.startsWith('B')) return const Color(0xFF2563EB);
    if (g.startsWith('C')) return const Color(0xFFD97706);
    if (g.startsWith('D') || g.startsWith('E')) return const Color(0xFFE11D48);
    return const Color(0xFF64748B);
  }

  Color _getGradeBg(String? grade) {
    final g = (grade ?? '').toUpperCase().trim();
    if (g.startsWith('A')) return const Color(0xFFECFDF5);
    if (g.startsWith('B')) return const Color(0xFFEFF6FF);
    if (g.startsWith('C')) return const Color(0xFFFEF3C7);
    if (g.startsWith('D') || g.startsWith('E')) return const Color(0xFFFFF1F2);
    return const Color(0xFFF1F5F9);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    if (profile.isAkademikLoading && profile.krsList.isEmpty && profile.transkripList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            BkuShimmer(width: double.infinity, height: 120, borderRadius: BorderRadius.all(Radius.circular(20))),
            SizedBox(height: AppSpacing.lg),
            BkuShimmerList(itemCount: 4, itemHeight: 80),
          ],
        ),
      );
    }

    final filteredKrs = profile.selectedPeriode == null
        ? profile.krsList
        : profile.krsList.where((item) {
            if (item is Map) {
              final p = (item['id_periode'] ?? item['periode'] ?? item['IdPeriode'] ?? '').toString();
              return p == profile.selectedPeriode;
            }
            return false;
          }).toList();

    return RefreshIndicator(
      onRefresh: () => profile.fetchAkademikData(),
      color: BkuTheme.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          _buildKpiSummary(
            ipk: profile.ipk > 0 ? profile.ipk.toStringAsFixed(2) : '0.00',
            totalSks: '${profile.totalSks}',
            mkKrs: '${filteredKrs.length}',
            totalTranskrip: '${profile.transkripList.length}',
            info: profile.akademikInfo,
          ),
          const SizedBox(height: AppSpacing.lg),

          IpkChartCard(
            currentIpk: profile.ipk,
            currentSemester: profile.semester,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildKrsSection(profile, filteredKrs),
          const SizedBox(height: AppSpacing.lg),

          _buildTranskripSection(profile),
          const SizedBox(height: AppSpacing.s80),
        ],
      ),
    );
  }

  Widget _buildKpiSummary({
    required String ipk,
    required String totalSks,
    required String mkKrs,
    required String totalTranskrip,
    String? info,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Akademik',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Data terintegrasi real-time dari sistem akademik BKU.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (info != null && info.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      info,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildKpiItem('IPK Terakhir', ipk, const Color(0xFF059669), const Color(0xFFECFDF5)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildKpiItem('Total SKS', totalSks, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildKpiItem('MK KRS', mkKrs, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildKpiItem('Transkrip', totalTranskrip, const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKrsSection(ProfileProvider profile, List<dynamic> krsList) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kartu Rencana Studi (KRS)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Mata kuliah semester aktif saat ini.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (profile.uniquePeriodes.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: profile.selectedPeriode,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      items: profile.uniquePeriodes.map((p) {
                        final label = p.startsWith('Periode') ? p : 'Periode $p';
                        return DropdownMenuItem<String>(
                          value: p,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (val) => profile.setSelectedPeriode(val),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          if (krsList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Tidak ada data KRS aktif untuk periode ini.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: krsList.length,
              separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF8FAFC)),
              itemBuilder: (_, index) {
                final item = krsList[index];
                if (item is! Map) return const SizedBox.shrink();

                final kode = item['kode_mata_kuliah'] ?? item['kode_mk'] ?? item['kode'] ?? '-';
                final nama = item['mata_kuliah'] ?? item['nama_mata_kuliah'] ?? item['nama_mk'] ?? '-';
                final sks = item['sks'] ?? item['sks_mata_kuliah'] ?? '0';
                final smt = item['id_periode'] ?? item['periode'] ?? '-';

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$kode',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$nama',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Periode $smt',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        '$sks SKS',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8)),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTranskripSection(ProfileProvider profile) {
    final trList = profile.transkripList;

    return Container(
      width: double.infinity,
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
            'Riwayat Transkrip Nilai',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 2),
          const Text(
            'Nilai keseluruhan per mata kuliah dari sistem akademik BKU.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          if (trList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Tidak ada data transkrip nilai.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trList.length,
              separatorBuilder: (_, __) => const Divider(height: 16, color: Color(0xFFF8FAFC)),
              itemBuilder: (_, index) {
                final item = trList[index];
                if (item is! Map) return const SizedBox.shrink();

                final kode = item['kode_mata_kuliah'] ?? item['kode_mk'] ?? item['kode'] ?? '-';
                final nama = item['nama_mata_kuliah'] ?? item['mata_kuliah'] ?? item['nama_mk'] ?? '-';
                final sks = item['sks_mata_kuliah'] ?? item['sks'] ?? '0';
                final grade = (item['nilai_huruf'] ?? '-').toString();
                final angka = (item['nilai_angka'] ?? '-').toString();
                final smt = item['periode'] ?? item['semester_mahasiswa'] ?? item['id_periode'] ?? '-';

                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getGradeBg(grade),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _getGradeColor(grade).withAlpha(60)),
                      ),
                      child: Center(
                        child: Text(
                          grade,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _getGradeColor(grade),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$nama',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$kode • $sks SKS • Mutu $angka • Smt $smt',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
