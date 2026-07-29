import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/features/ormawa/kalender/presentation/pages/ormawa_agenda_detail_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

class OrmawaKalenderScreen extends StatefulWidget {
  const OrmawaKalenderScreen({super.key});

  @override
  State<OrmawaKalenderScreen> createState() => _OrmawaKalenderScreenState();
}

class _OrmawaKalenderScreenState extends State<OrmawaKalenderScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'Semua';

  final List<String> _statusOptions = [
    'Semua',
    'Direncanakan',
    'Berlangsung',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrmawaAgenda> _getEventsForDay(
    DateTime day,
    List<OrmawaAgenda> allAgendas,
  ) {
    return allAgendas.where((agenda) {
      final matchesDate = isSameDay(agenda.date, day);
      final matchesStatus =
          _filterStatus == 'Semua' ||
          agenda.status.toLowerCase() == _filterStatus.toLowerCase();
      return matchesDate && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        if (!provider.hasPermission('view_calendar')) {
          return Scaffold(
            backgroundColor: AppColors.neutral100,
            body: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'JADWAL KALENDER',
                  subtitle: 'AKSES DITOLAK',
                  expandedHeight: 115.0,
                  showBackButton: true,
                  isExpandable: false,
                ),
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Akses Ditolak',
                            style: AppTextStyles.titleLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Anda tidak memiliki izin untuk mengakses jadwal kalender agenda kegiatan.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final selectedEvents = _getEventsForDay(
          _selectedDay ?? _focusedDay,
          provider.agendas,
        );

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: RefreshIndicator(
            onRefresh: () => context.read<OrmawaProvider>().refreshData(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'JADWAL KALENDER',
                  subtitle: 'AGENDA & KEGIATAN',
                  expandedHeight: 115.0,
                  showBackButton: true,
                  isExpandable: false,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      left: AppSpacing.s20,
                      right: AppSpacing.s20,
                      bottom: AppSpacing.s100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCalendarCard(provider.agendas),
                        const SizedBox(height: AppSpacing.xl),
                        OrmawaListHeader(
                          title:
                              '${DateFormat('d MMMM', 'id').format(_selectedDay ?? _focusedDay).toUpperCase()} - ${selectedEvents.length} AGENDA',
                          searchHint: 'Cari agenda...',
                          searchController: _searchController,
                          onRefresh:
                              () =>
                                  context.read<OrmawaProvider>().refreshData(),
                          onFilterTap: () => _showFilterSheet(),
                          onChanged:
                              (value) => setState(() => _searchQuery = value),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (provider.isLoading)
                          const BkuShimmerList(itemCount: 3, itemHeight: 90)
                        else
                          _buildAgendaList(selectedEvents),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton:
              provider.hasPermission('create_calendar')
                  ? FloatingActionButton.extended(
                    onPressed: () => _showAddJadwal(context),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
                    label: Text(
                      'Tambah Kegiatan',
                      style: TextStyle(
                        color: context.appColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildCalendarCard(List<OrmawaAgenda> agendas) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar<OrmawaAgenda>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) => _getEventsForDay(day, agendas).take(1).toList(),
        startingDayOfWeek: StartingDayOfWeek.monday,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          markerDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(40),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
            borderRadius: AppRadius.radiusMd,
          ),
          formatButtonTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaList(List<OrmawaAgenda> agendas) {
    // Apply search filter
    final filteredAgendas =
        _searchQuery.isEmpty
            ? agendas
            : agendas
                .where(
                  (a) =>
                      a.title.toLowerCase().contains(_searchQuery) ||
                      a.location.toLowerCase().contains(_searchQuery),
                )
                .toList();

    if (filteredAgendas.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        width: double.infinity,
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _searchQuery.isEmpty
                  ? 'Tidak ada agenda di tanggal ini'
                  : 'Agenda tidak ditemukan',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredAgendas.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final agenda = filteredAgendas[index];
        return _buildAgendaCard(agenda);
      },
    );
  }

  Widget _buildAgendaCard(OrmawaAgenda agenda) {
    final provider = Provider.of<OrmawaProvider>(context, listen: false);
    final canEdit = provider.hasPermission('edit_calendar');
    final canDelete = provider.hasPermission('delete_calendar');

    Color statusColor;
    switch (agenda.status.toLowerCase()) {
      case 'terlaksana':
      case 'selesai':
        statusColor = AppColors.success;
        break;
      case 'berlangsung':
        statusColor = AppColors.warning;
        break;
      case 'batal':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.info;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrmawaAgendaDetailScreen(agenda: agenda),
            ),
          );
        },
        borderRadius: AppRadius.radiusXl,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      agenda.status.toUpperCase(),
                      style: AppTextStyles.labelSm.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (canEdit || canDelete)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.neutral500,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(context, agenda);
                        } else if (value == 'edit') {
                          _showEditJadwal(context, agenda);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (canEdit)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_rounded, size: 18),
                                    SizedBox(width: AppSpacing.sm),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                            if (canDelete)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                agenda.title,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              if (agenda.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  agenda.description,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1, color: AppColors.neutral200),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      agenda.location,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${DateFormat('HH:mm').format(agenda.date)} - ${DateFormat('HH:mm').format(agenda.endDate)}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, OrmawaAgenda agenda) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Agenda?'),
            content: Text(
              'Apakah Anda yakin ingin menghapus "${agenda.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BATAL'),
              ),
              TextButton(
                onPressed: () {
                  context.read<OrmawaProvider>().deleteAgenda(agenda.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'HAPUS',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _showAddJadwal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrmawaFormJadwalScreen(
              selectedDate: _selectedDay ?? _focusedDay,
            ),
      ),
    );
  }

  void _showEditJadwal(BuildContext context, OrmawaAgenda agenda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrmawaFormJadwalScreen(
              selectedDate: agenda.date,
              agenda: agenda,
            ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.neutral300,
                      borderRadius: AppRadius.radiusXs,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Filter Status',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _statusOptions.map((option) {
                        final isSelected = _filterStatus == option;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _filterStatus = option);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                        context,
                                      ).colorScheme.primary.withAlpha(10),
                              borderRadius: AppRadius.radiusXl,
                            ),
                            child: Text(
                              option,
                              style: AppTextStyles.labelSm.copyWith(
                                color:
                                    isSelected
                                        ? context.appColors.onPrimary
                                        : Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                if (_filterStatus != 'Semua')
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: TextButton(
                      onPressed: () {
                        setState(() => _filterStatus = 'Semua');
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Reset Filter',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
    );
  }
}

class OrmawaFormJadwalScreen extends StatefulWidget {
  final DateTime selectedDate;
  final OrmawaAgenda? agenda;
  const OrmawaFormJadwalScreen({
    super.key,
    required this.selectedDate,
    this.agenda,
  });

  @override
  State<OrmawaFormJadwalScreen> createState() => _OrmawaFormJadwalScreenState();
}

class _OrmawaFormJadwalScreenState extends State<OrmawaFormJadwalScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final _landasanController = TextEditingController();
  final _bentukController = TextEditingController();
  final _mitraController = TextEditingController();
  final _latarBelakangController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _jadwalController = TextEditingController();
  final _sasaranController = TextEditingController();
  final _indikatorController = TextEditingController();
  final _sumberDanaController = TextEditingController();
  final _estimasiDanaController = TextEditingController();
  final _pjController = TextEditingController();

  String _selectedStatus = 'Direncanakan';
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  final List<String> _statuses = [
    'Direncanakan',
    'Persiapan',
    'Berlangsung',
    'Terlaksana',
    'Batal',
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedDate;

    if (widget.agenda != null) {
      _titleController.text = widget.agenda!.title;
      _descriptionController.text = widget.agenda!.description;
      _locationController.text = widget.agenda!.location;

      final rawStatus = widget.agenda!.status;
      if (_statuses.any((s) => s.toLowerCase() == rawStatus.toLowerCase())) {
        _selectedStatus = _statuses.firstWhere(
          (s) => s.toLowerCase() == rawStatus.toLowerCase(),
        );
      } else {
        _selectedStatus = _statuses.first;
      }

      _startTime = TimeOfDay.fromDateTime(widget.agenda!.date);
      _endTime = TimeOfDay.fromDateTime(widget.agenda!.endDate);

      _landasanController.text = widget.agenda!.landasanKegiatan ?? '';
      _bentukController.text = widget.agenda!.bentukKegiatan ?? '';
      _mitraController.text = widget.agenda!.mitra ?? '';
      _latarBelakangController.text = widget.agenda!.latarBelakang ?? '';
      _tujuanController.text = widget.agenda!.tujuanKegiatan ?? '';
      _jadwalController.text = widget.agenda!.jadwalPelaksanaan ?? '';
      _sasaranController.text = widget.agenda!.sasaranKegiatan ?? '';
      _indikatorController.text = widget.agenda!.indikatorKeberhasilan ?? '';
      _sumberDanaController.text = widget.agenda!.sumberDana ?? '';
      _pjController.text = widget.agenda!.pjKegiatan ?? '';

      if (widget.agenda!.estimasiDana != null &&
          widget.agenda!.estimasiDana! > 0) {
        _estimasiDanaController.text = _formatCurrencyValue(
          widget.agenda!.estimasiDana!,
        );
      }
    } else {
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay(
        hour: (_startTime.hour + 2) % 24,
        minute: _startTime.minute,
      );
    }
  }

  String _formatCurrencyValue(double val) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(val);
  }

  void _onEstimasiDanaChanged(String val) {
    if (val.isEmpty) return;
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final number = int.tryParse(clean) ?? 0;
    final formatted = _formatCurrencyValue(number.toDouble());
    _estimasiDanaController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _submit() async {
    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.showError(context, 'Nama kegiatan tidak boleh kosong');
      return;
    }

    final DateTime fullStartDate = DateTime.utc(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final DateTime fullEndDate = DateTime.utc(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (fullEndDate.isBefore(fullStartDate)) {
      AppSnackbar.showError(
        context,
        'Waktu selesai tidak boleh sebelum waktu mulai',
      );
      return;
    }

    final cleanDana = _estimasiDanaController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final double estimasiDana = double.tryParse(cleanDana) ?? 0.0;

    final data = {
      'Judul': _titleController.text.trim(),
      'Deskripsi': _descriptionController.text.trim(),
      'TanggalMulai': fullStartDate.toIso8601String(),
      'TanggalSelesai': fullEndDate.toIso8601String(),
      'Lokasi': _locationController.text.trim(),
      'Status':
          _selectedStatus.toLowerCase() == 'direncanakan'
              ? 'terjadwal'
              : _selectedStatus.toLowerCase(),
      'landasan_kegiatan': _landasanController.text.trim(),
      'bentuk_kegiatan': _bentukController.text.trim(),
      'mitra': _mitraController.text.trim(),
      'latar_belakang': _latarBelakangController.text.trim(),
      'tujuan_kegiatan': _tujuanController.text.trim(),
      'jadwal_pelaksanaan':
          _jadwalController.text.trim().isNotEmpty
              ? _jadwalController.text.trim()
              : "${DateFormat('EEEE, dd MMMM yyyy', 'id').format(fullStartDate)}, ${_startTime.format(context)} - ${_endTime.format(context)} WIB",
      'sasaran_kegiatan': _sasaranController.text.trim(),
      'indikator_keberhasilan': _indikatorController.text.trim(),
      'sumber_dana': _sumberDanaController.text.trim(),
      'estimasi_dana': estimasiDana,
      'pj_kegiatan': _pjController.text.trim(),
    };

    try {
      if (widget.agenda != null) {
        await context.read<OrmawaProvider>().updateAgenda(
          widget.agenda!.id,
          data,
        );
      } else {
        await context.read<OrmawaProvider>().addAgenda(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.agenda != null;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: isEdit ? 'EDIT KEGIATAN' : 'JADWALKAN KEGIATAN',
            subtitle: 'EVENT REGISTRY',
            variant: AppBarVariant.ormawa,
            expandedHeight: 115.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(isEdit),
                  const SizedBox(height: AppSpacing.xl),

                  _buildFormSectionTitle('1. INFORMASI UTAMA'),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    'NAMA KEGIATAN *',
                    'Contoh: Rapat Kerja Anggota...',
                    _titleController,
                    Icons.title_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'PENANGGUNG JAWAB (PJ)',
                    'Nama PJ kegiatan...',
                    _pjController,
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'LOKASI / RUANG',
                    'Contoh: Aula Serbaguna Lt. 2...',
                    _locationController,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatusDropdown(),
                  const SizedBox(height: AppSpacing.s20),
                  _buildDateTimePicker(),

                  const SizedBox(height: AppSpacing.xxl),

                  _buildFormSectionTitle('2. PARAMETER OPERASIONAL'),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    'LANDASAN KEGIATAN',
                    'Contoh: GBHP Organisasi 2026...',
                    _landasanController,
                    Icons.gavel_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'BENTUK KEGIATAN',
                    'Contoh: Seminar / Workshop...',
                    _bentukController,
                    Icons.category_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'SASARAN KEGIATAN',
                    'Contoh: Seluruh mahasiswa baru...',
                    _sasaranController,
                    Icons.track_changes_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'MITRA KERJA',
                    'Contoh: Sponsor, UKM lain...',
                    _mitraController,
                    Icons.handshake_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'SUMBER DANA',
                    'Contoh: Dana kemahasiswaan...',
                    _sumberDanaController,
                    Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'INDIKATOR KEBERHASILAN',
                    'Contoh: Target kehadiran 80%...',
                    _indikatorController,
                    Icons.emoji_events_outlined,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCurrencyField(
                    'ESTIMASI ANGGARAN (RP)',
                    'Contoh: Rp 5.000.000',
                    _estimasiDanaController,
                    Icons.payments_outlined,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  _buildFormSectionTitle('3. DESKRIPSI & NARASI'),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    'LATAR BELAKANG',
                    'Tuliskan latar belakang singkat...',
                    _latarBelakangController,
                    Icons.article_outlined,
                    maxLines: 4,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'TUJUAN KEGIATAN',
                    'Tuliskan tujuan kegiatan...',
                    _tujuanController,
                    Icons.flag_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTextField(
                    'DESKRIPSI DETAIL & MEKANISME',
                    'Detail alur / mekanisme agenda...',
                    _descriptionController,
                    Icons.description_outlined,
                    maxLines: 4,
                  ),

                  const SizedBox(height: AppSpacing.xxxl),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(10),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelSm.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isEdit) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isEdit
                ? Icons.edit_calendar_rounded
                : Icons.event_available_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'REGISTRASI AGENDA KEGIATAN',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                isEdit ? 'PERBARUI AGENDA' : 'BUAT KEGIATAN BARU',
                style: AppTextStyles.titleLg.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral800,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.neutral500),
            filled: true,
            fillColor: AppColors.neutral100,
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: _onEstimasiDanaChanged,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral800,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.neutral500),
            filled: true,
            fillColor: AppColors.neutral100,
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: const BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) setState(() => _startDate = date);
          },
          child: _buildInfoBox(
            'TANGGAL PELAKSANAAN',
            DateFormat('EEEE, dd MMMM yyyy', 'id').format(_startDate),
            Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) setState(() => _startTime = time);
                },
                child: _buildInfoBox(
                  'JAM MULAI',
                  _startTime.format(context),
                  Icons.access_time_rounded,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (time != null) setState(() => _endTime = time);
                },
                child: _buildInfoBox(
                  'JAM SELESAI',
                  _endTime.format(context),
                  Icons.access_time_rounded,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.neutral500),
              const SizedBox(width: AppSpacing.md),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS AGENDA',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.flag_rounded,
                  size: 20,
                  color: AppColors.neutral500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral800,
                fontSize: 14,
              ),
              items:
                  _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged: (v) => setState(() => _selectedStatus = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),

            child: const Text(
              'BATAL',
              style: TextStyle(
                color: AppColors.neutral600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _submit,

            child: Text(
              widget.agenda != null ? 'PERBARUI AGENDA' : 'SIMPAN JADWAL',
              style: TextStyle(
                color: context.appColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
