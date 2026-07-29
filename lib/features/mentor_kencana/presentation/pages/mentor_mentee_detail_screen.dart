import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import '../../domain/entities/mentor_models.dart';
import 'mentor_handbook_review_screen.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorMenteeDetailScreen extends StatefulWidget {
  final int studentId;
  const MentorMenteeDetailScreen({super.key, required this.studentId});

  @override
  State<MentorMenteeDetailScreen> createState() =>
      _MentorMenteeDetailScreenState();
}

class _MentorMenteeDetailScreenState extends State<MentorMenteeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMenteeDetail(
          widget.studentId,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitNote() async {
    final note = _notesController.text.trim();
    if (note.isEmpty) return;

    final provider = context.read<MentorKencanaProvider>();
    final success = await provider.submitMenteeNotes(widget.studentId, note);
    if (mounted) {
      if (success) {
        AppSnackbar.showSuccess(context, 'Catatan berhasil disimpan');
        _notesController.clear();
        provider.fetchMenteeDetail(widget.studentId);
      } else {
        AppSnackbar.showError(context, 'Gagal menyimpan catatan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final mentee = provider.menteeDetail;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body:
          provider.isLoading && mentee == null
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null && mentee == null
              ? Center(
                child: Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
              : mentee == null
              ? Center(
                child: Text(
                  'Data tidak ditemukan',
                  style: AppTextStyles.labelMd.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              )
              : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    BkuAppBar(
                      title: mentee.name,
                      variant: AppBarVariant.student,
                      isExpandable: false,
                      showBackButton: true,
                      onBack: () => context.pop(),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.neutral800,
                          unselectedLabelColor:
                              Theme.of(context).colorScheme.outline,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: AppRadius.radiusMd,
                          ),
                          tabs: const [
                            Tab(text: 'Progres'),
                            Tab(text: 'Tugas'),
                            Tab(text: 'Catatan'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProgressTab(context, mentee),
                    _buildTasksTab(context, mentee),
                    _buildNotesTab(context, mentee),
                  ],
                ),
              ),
    );
  }

  Widget _buildProgressTab(BuildContext context, mentee) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGridInfoCard(
                  'NIM',
                  mentee.nim,
                  Icons.badge_rounded,
                  iconColor: AppColors.neutral700,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildGridInfoCard(
                  'Status',
                  mentee.status,
                  Icons.info_outline_rounded,
                  isStatus: true,
                  iconColor:
                      mentee.status == 'Lulus'
                          ? context.appColors.success
                          : context.appColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildGridInfoCard(
                  'Kehadiran',
                  '${mentee.attendanceCount} Kali',
                  Icons.event_available_rounded,
                  iconColor: AppColors.neutral700,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildGridInfoCard(
                  'Total Nilai',
                  '${mentee.totalScore} Poin',
                  Icons.military_tech_rounded,
                  iconColor: AppColors.neutral700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BkuCard(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: AppSpacing.padding10,
                  decoration: BoxDecoration(
                    color: AppColors.neutral500.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.neutral600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fakultas',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        mentee.faculty,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          BkuButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MentorHandbookReviewScreen(
                        studentId: mentee.id,
                        studentName: mentee.name,
                      ),
                ),
              );
            },
            icon: Icons.book_rounded,
            text: 'Review Buku Saku (Handbook)',
          ),
        ],
      ),
    );
  }

  Widget _buildGridInfoCard(
    String label,
    String value,
    IconData icon, {
    bool isStatus = false,
    Color? iconColor,
  }) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.neutral500).withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.neutral600,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color:
                    value == 'Lulus'
                        ? context.appColors.success.withAlpha(15)
                        : context.appColors.warning.withAlpha(15),
                border: Border.all(
                  color:
                      value == 'Lulus'
                          ? context.appColors.success.withAlpha(30)
                          : context.appColors.warning.withAlpha(30),
                ),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Text(
                value,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      value == 'Lulus' ? context.appColors.success : context.appColors.warning,
                ),
              ),
            )
          else
            Text(
              value,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(BuildContext context, mentee) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.xl,
            AppSpacing.s20,
            AppSpacing.sm,
          ),
          child: BkuButton(
            onPressed: () => _showAddScoreDialog(context, mentee.id),
            icon: Icons.add_task_rounded,
            text: 'Tambah Nilai Individu',
          ),
        ),
        Expanded(
          child:
              mentee.assignments.isEmpty
                  ? Center(
                    child: Text(
                      'Belum ada tugas yang disubmit',
                      style: AppTextStyles.labelMd.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: mentee.assignments.length,
                    itemBuilder: (context, index) {
                      final task = mentee.assignments[index];
                      return BkuCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.s6),
                                      Row(
                                        children: [
                                          Text(
                                            'Tipe: ${task.type}',
                                            style: AppTextStyles.labelSm
                                                .copyWith(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                                ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (task.status == 'submitted' ||
                                                          task.status ==
                                                              'graded')
                                               ? context.appColors.success
                                                           .withAlpha(15)
                                                       : context.appColors.error
                                                           .withAlpha(15),
                                               border: Border.all(
                                                 color:
                                                     (task.status ==
                                                                 'submitted' ||
                                                             task.status ==
                                                                 'graded')
                                                         ? context.appColors.success
                                                             .withAlpha(30)
                                                         : context.appColors.error
                                                             .withAlpha(30),
                                              ),
                                              borderRadius: AppRadius.radiusXs,
                                            ),
                                            child: Text(
                                              (task.status == 'submitted' ||
                                                      task.status == 'graded')
                                                  ? 'Terkumpul'
                                                  : 'Belum Terkumpul',
                                              style: TextStyle(
                                                color:
                                                     (task.status ==
                                                                 'submitted' ||
                                                             task.status ==
                                                                 'graded')
                                                         ? context.appColors.success
                                                         : context.appColors.error,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Nilai: ${task.score}',
                                  style: AppTextStyles.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (task.status == 'submitted' ||
                                task.status == 'graded') ...[
                              const SizedBox(height: AppSpacing.md),
                              Divider(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Hasil Pekerjaan:',
                                style: AppTextStyles.labelSm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s6),
                              if (task.answerText.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: AppRadius.radiusMd,
                                    border: Border.all(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                    ),
                                  ),
                                  child: Text(
                                    task.answerText,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              if (task.submittedLink.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(12),
                                    borderRadius: AppRadius.radiusMd,
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(51),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link,
                                        size: 16,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Flexible(
                                        child: Text(
                                          task.submittedLink,
                                          style: AppTextStyles.labelSm.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              if (task.submittedFile.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral200,
                                    borderRadius: AppRadius.radiusMd,
                                    border: Border.all(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.download_rounded,
                                        size: 16,
                                        color: Colors.black87,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Flexible(
                                        child: Text(
                                          task.submittedFile.split('/').last,
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ] else ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: context.appColors.warning.withAlpha(15),
                                  borderRadius: AppRadius.radiusMd,
                                  border: Border.all(
                                    color: context.appColors.warning.withAlpha(30),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      size: 16,
                                      color: context.appColors.warning,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        'Mahasiswa belum mengunggah jawaban untuk tugas ini.',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: context.appColors.warning,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildNotesTab(BuildContext context, MenteeDetailData mentee) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan Evaluasi Mentor',
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tambahkan catatan khusus untuk mahasiswa ini jika diperlukan.',
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Tulis progres, evaluasi, atau kendala mahasiswa disini...',
              filled: true,
              fillColor: AppColors.neutral50,
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.radiusLg,
                borderSide: BorderSide(color: AppColors.neutral500),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.lg),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BkuButton(
            onPressed: _submitNote,
            text: 'Simpan Catatan',
            isLoading: context.select((MentorKencanaProvider p) => p.isLoading),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Riwayat Catatan Bimbingan (${mentee.notes.length})',
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (mentee.notes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(
                  'Belum ada catatan bimbingan.',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mentee.notes.length,
              itemBuilder: (context, index) {
                final note = mentee.notes[index];

                String dateDisplay = note.assessedAt;
                try {
                  final parsedDate = DateTime.parse(note.assessedAt).toLocal();
                  dateDisplay =
                      "${parsedDate.day}-${parsedDate.month}-${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
                } catch (_) {}

                return BkuCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: AppSpacing.s6),
                          Text(
                            dateDisplay,
                            style: AppTextStyles.labelSm.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        note.notes,
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.black87,
                          height: 1.4,
                        ),
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
}

extension _MentorTasksTab on _MentorMenteeDetailScreenState {
  void _showAddScoreDialog(BuildContext context, int studentId) {
    final nameController = TextEditingController();
    final scoreController = TextEditingController();
    final notesController = TextEditingController();
    String selectedComponent = 'cognitive';

    showDialog(
      context: context,
      builder: (ctx) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return CustomDialog(
              title: 'Tambah Nilai',
              content: 'Masukkan detail penilaian individu',
              confirmText: 'Simpan',
              cancelText: 'Batal',
              isLoading: isSubmitting,
              onCancel: () => Navigator.pop(ctx),
              onConfirm: () async {
                if (nameController.text.isEmpty ||
                    scoreController.text.isEmpty) {
                  AppSnackbar.showWarning(
                    context,
                    'Nama tugas dan nilai wajib diisi',
                  );
                  return;
                }
                setState(() => isSubmitting = true);

                final payload = {
                  'items': [
                    {
                      'component': selectedComponent,
                      'item_name': nameController.text,
                      'score': double.tryParse(scoreController.text) ?? 0,
                      'notes': notesController.text,
                    },
                  ],
                };

                final success = await context
                    .read<MentorKencanaProvider>()
                    .createScoreItem(studentId, payload);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (success) {
                  AppSnackbar.showSuccess(context, 'Berhasil menambah nilai');
                } else {
                  AppSnackbar.showError(context, 'Gagal menambah nilai');
                }
              },
              customChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedComponent,
                    decoration: InputDecoration(
                      labelText: 'Komponen Nilai',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'cognitive',
                        child: Text('Kognitif (Kuis/Tugas)'),
                      ),
                      DropdownMenuItem(
                        value: 'psychomotor',
                        child: Text('Psikomotor (Kehadiran/Praktek)'),
                      ),
                      DropdownMenuItem(
                        value: 'affective',
                        child: Text('Afektif (Sikap/Keaktifan)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedComponent = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Aktivitas / Tugas',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nilai (0-100)',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 8;
  @override
  double get maxExtent => tabBar.preferredSize.height + 8;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.neutral100,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      child: BkuCard(padding: EdgeInsets.zero, child: tabBar),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
