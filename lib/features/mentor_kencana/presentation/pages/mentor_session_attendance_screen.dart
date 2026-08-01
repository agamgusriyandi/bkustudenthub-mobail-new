import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorSessionAttendanceScreen extends StatefulWidget {
  final int sessionId;
  const MentorSessionAttendanceScreen({super.key, required this.sessionId});

  @override
  State<MentorSessionAttendanceScreen> createState() =>
      _MentorSessionAttendanceScreenState();
}

class _MentorSessionAttendanceScreenState
    extends State<MentorSessionAttendanceScreen> {
  final Map<int, String> _attendanceStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchSessionAttendance(
          widget.sessionId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final students = provider.attendanceStudents;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchSessionAttendance(widget.sessionId),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Absensi Sesi',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && students.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && students.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: context.appColors.error,
                    ),
                  ),
                ),
              )
            else if (students.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Tidak ada data kehadiran untuk sesi ini.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      final presentCount = students.where((s) {
                        final st =
                            _attendanceStatus[s.studentId] ?? s.status;
                        return st.toLowerCase() == 'present' ||
                            st.toLowerCase() == 'hadir';
                      }).length;
                      return BkuCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: context.appColors.info.withAlpha(15),
                                borderRadius: AppRadius.radiusLg,
                              ),
                              child: Icon(
                                Icons.how_to_reg_rounded,
                                color: context.appColors.info,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ringkasan Kehadiran',
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    '$presentCount / ${students.length} hadir',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: context.appColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final student = students[index - 1];
                    final currentStatus =
                        _attendanceStatus[student.studentId] ??
                        student.status;

                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral200,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.neutral300,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    student.name.isNotEmpty
                                        ? student.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : '',
                                    style: const TextStyle(
                                      color: AppColors.neutral700,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      student.nim,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              _buildStatusChip(
                                context,
                                'Hadir',
                                currentStatus.toLowerCase() == 'present' ||
                                    currentStatus.toLowerCase() == 'hadir',
                                () {
                                  setState(() {
                                    _attendanceStatus[student.studentId] =
                                        'present';
                                  });
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _buildStatusChip(
                                context,
                                'Izin',
                                currentStatus.toLowerCase() == 'permission' ||
                                    currentStatus.toLowerCase() == 'izin',
                                () {
                                  setState(() {
                                    _attendanceStatus[student.studentId] =
                                        'permission';
                                  });
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _buildStatusChip(
                                context,
                                'Alpa',
                                currentStatus.toLowerCase() == 'absent' ||
                                    currentStatus.toLowerCase() == 'alpa',
                                () {
                                  setState(() {
                                    _attendanceStatus[student.studentId] =
                                        'absent';
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }, childCount: students.length + 1),
                ),
              ),
            if (students.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: BkuButton(
                    onPressed: () async {
                      final attendances =
                          _attendanceStatus.entries
                              .map(
                                (e) => {
                                  'student_id': e.key,
                                  'status': e.value,
                                },
                              )
                              .toList();
                      if (attendances.isEmpty) {
                        final attendancesFromServer =
                            students
                                .map(
                                  (s) => {
                                    'student_id': s.studentId,
                                    'status': s.status,
                                  },
                                )
                                .toList();
                        final success = await provider
                            .submitSessionAttendance(
                              widget.sessionId,
                              attendancesFromServer,
                            );
                        if (context.mounted) {
                          if (success) {
                            AppSnackbar.showSuccess(
                              context,
                              'Absensi berhasil disimpan',
                            );
                          } else {
                            AppSnackbar.showError(
                              context,
                              'Gagal menyimpan absensi',
                            );
                          }
                        }
                        return;
                      }
                      final success = await provider.submitSessionAttendance(
                        widget.sessionId,
                        attendances,
                      );
                      if (context.mounted) {
                        if (success) {
                          AppSnackbar.showSuccess(
                            context,
                            'Absensi berhasil disimpan',
                          );
                        } else {
                          AppSnackbar.showError(
                            context,
                            'Gagal menyimpan absensi',
                          );
                        }
                      }
                    },
                    icon: Icons.save_rounded,
                    text: 'Simpan Absensi',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    Color chipColor;
    switch (label) {
      case 'Hadir':
        chipColor = context.appColors.success;
        break;
      case 'Izin':
        chipColor = context.appColors.warning;
        break;
      default:
        chipColor = context.appColors.error;
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? chipColor.withAlpha(15) : Colors.transparent,
            border: Border.all(
              color: isSelected ? chipColor : AppColors.neutral300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: AppRadius.radiusSm,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? chipColor : context.appColors.outline,
            ),
          ),
        ),
      ),
    );
  }
}
