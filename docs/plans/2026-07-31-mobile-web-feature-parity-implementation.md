# Mobile-Web Feature Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 51 missing screens to mobile app to achieve 1:1 feature parity with website.

**Architecture:** Flutter app with go_router, Provider state management, dynamic theme from API. Each phase adds screens per role (Mahasiswa → Ormawa → Mentor → Psikologi → Kesehatan).

**Tech Stack:** Flutter 3.x, Dart, go_router, Provider, google_fonts, flutter_svg, cached_network_image, fl_chart, mobile_scanner

---

## Pre-Flight: Existing Patterns to Follow

Before writing any code, read these files to understand existing patterns:
- `lib/core/theme/app_theme.dart` — theme access pattern
- `lib/core/theme/app_colors.dart` — color tokens
- `lib/core/theme/app_text_styles.dart` — typography
- `lib/core/theme/app_radius.dart` — border radius
- `lib/core/theme/app_spacing.dart` — spacing
- `lib/core/widgets/bku_card.dart` — card component
- `lib/core/widgets/bku_button.dart` — button component
- `lib/core/widgets/unified_app_bar.dart` — app bar
- `lib/core/widgets/bku_shimmer.dart` — loading skeleton
- `lib/features/mahasiswa/dashboard/presentation/pages/dashboard_screen.dart` — existing screen pattern
- `lib/features/mahasiswa/dashboard/presentation/providers/` — provider pattern
- `lib/features/auth/presentation/pages/login_screen.dart` — form pattern
- `lib/features/mahasiswa/kencana/presentation/pages/kencana_screen.dart` — list screen pattern

---

## File Structure Convention

Every new feature follows:
```
lib/features/{role}/{module}/
├── data/
│   ├── models/
│   │   └── {model_name}.dart
│   └── repositories/
│       └── {repository_name}.dart
├── presentation/
│   ├── pages/
│   │   └── {screen_name}_screen.dart
│   └── providers/
│       └── {provider_name}.dart
└── {module_name}.dart (barrel export)
```

---

## PHASE 1: MAHASISWA (10 screens)

### Task 1.1: Presensi Kelas Screen

**Files:**
- Create: `lib/features/mahasiswa/presensi/data/models/presensi_model.dart`
- Create: `lib/features/mahasiswa/presensi/data/repositories/presensi_repository.dart`
- Create: `lib/features/mahasiswa/presensi/presentation/providers/presensi_provider.dart`
- Create: `lib/features/mahasiswa/presensi/presentation/pages/presensi_screen.dart`
- Modify: `lib/core/routes/app_routes.dart` — add route
- Modify: `lib/features/main/presentation/pages/main_screen.dart` — add to nav

- [ ] **Step 1: Create PresensiModel**

```dart
// lib/features/mahasiswa/presensi/data/models/presensi_model.dart
class PresensiModel {
  final String id;
  final String matkulName;
  final String jam;
  final String ruangan;
  final String dosen;
  final String status; // hadir, terlambat, sakit, izin, alpa
  final DateTime? checkInTime;

  PresensiModel({
    required this.id,
    required this.matkulName,
    required this.jam,
    required this.ruangan,
    required this.dosen,
    required this.status,
    this.checkInTime,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    return PresensiModel(
      id: json['id'] ?? '',
      matkulName: json['matkul_name'] ?? '',
      jam: json['jam'] ?? '',
      ruangan: json['ruangan'] ?? '',
      dosen: json['dosen'] ?? '',
      status: json['status'] ?? 'alpa',
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'])
          : null,
    );
  }
}
```

- [ ] **Step 2: Create PresensiRepository**

```dart
// lib/features/mahasiswa/presensi/data/repositories/presensi_repository.dart
import 'package:bkustudenthub/core/services/api_service.dart';
import '../models/presensi_model.dart';

class PresensiRepository {
  final ApiService _api;

  PresensiRepository(this._api);

  Future<List<PresensiModel>> getPresensi() async {
    final response = await _api.get('/api/mahasiswa/presensi');
    return (response.data['data'] as List)
        .map((e) => PresensiModel.fromJson(e))
        .toList();
  }

  Future<void> checkIn(String presensiId) async {
    await _api.post('/api/mahasiswa/presensi/check-in', data: {
      'presensi_id': presensiId,
    });
  }
}
```

- [ ] **Step 3: Create PresensiProvider**

```dart
// lib/features/mahasiswa/presensi/presentation/providers/presensi_provider.dart
import 'package:flutter/material.dart';
import '../../data/repositories/presensi_repository.dart';
import '../../data/models/presensi_model.dart';

class PresensiProvider extends ChangeNotifier {
  final PresensiRepository _repository;
  
  List<PresensiModel> _presensiList = [];
  bool _isLoading = false;
  String? _error;

  PresensiProvider(this._repository);

  List<PresensiModel> get presensiList => _presensiList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPresensi() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _presensiList = await _repository.getPresensi();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkIn(String presensiId) async {
    try {
      await _repository.checkIn(presensiId);
      await loadPresensi(); // refresh
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

- [ ] **Step 4: Create PresensiScreen**

```dart
// lib/features/mahasiswa/presensi/presentation/pages/presensi_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkustudenthub/core/theme/app_theme.dart';
import 'package:bkustudenthub/core/theme/app_radius.dart';
import 'package:bkustudenthub/core/theme/app_spacing.dart';
import 'package:bkustudenthub/core/widgets/unified_app_bar.dart';
import 'package:bkustudenthub/core/widgets/bku_card.dart';
import 'package:bkustudenthub/core/widgets/bku_shimmer.dart';
import 'package:bkustudenthub/core/widgets/bku_button.dart';
import '../providers/presensi_provider.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PresensiProvider>().loadPresensi());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UnifiedAppBar(title: 'Presensi Kelas'),
      body: Consumer<PresensiProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const BkuShimmer();
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }
          if (provider.presensiList.isEmpty) {
            return const Center(child: Text('Tidak ada jadwal hari ini'));
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadPresensi(),
            child: ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: provider.presensiList.length,
              itemBuilder: (context, index) {
                final presensi = provider.presensiList[index];
                return BkuCard(
                  margin: EdgeInsets.only(bottom: AppSpacing.md),
                  child: ListTile(
                    title: Text(presensi.matkulName),
                    subtitle: Text('${presensi.jam} • ${presensi.ruangan}'),
                    trailing: _buildStatusBadge(presensi.status),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'hadir':
        color = context.appColors.success;
        break;
      case 'terlambat':
        color = context.appColors.warning;
        break;
      case 'sakit':
      case 'izin':
        color = context.appColors.info;
        break;
      default:
        color = context.appColors.error;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
```

- [ ] **Step 5: Register route in AppRoutes**

```dart
// Add to lib/core/routes/app_routes.dart
static const String presensi = '/app/student/presensi';

// Add GoRoute in router config
GoRoute(
  path: 'presensi',
  builder: (context, state) => const PresensiScreen(),
),
```

- [ ] **Step 6: Run and verify**

```bash
cd C:\laragon\www\BKU\bkustudenthub-mobail-new
flutter analyze lib/features/mahasiswa/presensi/
```

- [ ] **Step 7: Commit**

```bash
git add lib/features/mahasiswa/presensi/ lib/core/routes/app_routes.dart
git commit -m "feat(mahasiswa): add presensi kelas screen"
```

---

### Task 1.2: Riwayat Konseling Screen

**Files:**
- Create: `lib/features/mahasiswa/counseling/data/models/counseling_history_model.dart`
- Create: `lib/features/mahasiswa/counseling/data/repositories/counseling_history_repository.dart`
- Create: `lib/features/mahasiswa/counseling/presentation/providers/counseling_history_provider.dart`
- Create: `lib/features/mahasiswa/counseling/presentation/pages/counseling_history_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1: Create CounselingHistoryModel**

```dart
// lib/features/mahasiswa/counseling/data/models/counseling_history_model.dart
class CounselingHistoryModel {
  final String id;
  final String psychologistName;
  final String psychologistSpecialization;
  final DateTime date;
  final String status; // menunggu, selesai, dibatalkan
  final String type;
  final String? notes;

  CounselingHistoryModel({
    required this.id,
    required this.psychologistName,
    required this.psychologistSpecialization,
    required this.date,
    required this.status,
    required this.type,
    this.notes,
  });

  factory CounselingHistoryModel.fromJson(Map<String, dynamic> json) {
    return CounselingHistoryModel(
      id: json['id'] ?? '',
      psychologistName: json['psychologist_name'] ?? '',
      psychologistSpecialization: json['psychologist_specialization'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'menunggu',
      type: json['type'] ?? '',
      notes: json['notes'],
    );
  }
}
```

- [ ] **Step 2: Create CounselingHistoryRepository**

```dart
// lib/features/mahasiswa/counseling/data/repositories/counseling_history_repository.dart
import 'package:bkustudenthub/core/services/api_service.dart';
import '../models/counseling_history_model.dart';

class CounselingHistoryRepository {
  final ApiService _api;

  CounselingHistoryRepository(this._api);

  Future<List<CounselingHistoryModel>> getHistory() async {
    final response = await _api.get('/api/counseling/history');
    return (response.data['data'] as List)
        .map((e) => CounselingHistoryModel.fromJson(e))
        .toList();
  }

  Future<void> cancelBooking(String id) async {
    await _api.put('/api/counseling/$id/cancel');
  }

  Future<void> reschedule(String id, DateTime newDate) async {
    await _api.put('/api/counseling/$id/reschedule', data: {
      'date': newDate.toIso8601String(),
    });
  }
}
```

- [ ] **Step 3: Create CounselingHistoryProvider**

```dart
// lib/features/mahasiswa/counseling/presentation/providers/counseling_history_provider.dart
import 'package:flutter/material.dart';
import '../../data/repositories/counseling_history_repository.dart';
import '../../data/models/counseling_history_model.dart';

class CounselingHistoryProvider extends ChangeNotifier {
  final CounselingHistoryRepository _repository;

  List<CounselingHistoryModel> _history = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'all';

  CounselingHistoryProvider(this._repository);

  List<CounselingHistoryModel> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  List<CounselingHistoryModel> get filteredHistory {
    if (_filter == 'all') return _history;
    return _history.where((e) => e.status == _filter).toList();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await _repository.getHistory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      await _repository.cancelBooking(id);
      await loadHistory();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

- [ ] **Step 4: Create CounselingHistoryScreen**

```dart
// lib/features/mahasiswa/counseling/presentation/pages/counseling_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkustudenthub/core/theme/app_theme.dart';
import 'package:bkustudenthub/core/theme/app_radius.dart';
import 'package:bkustudenthub/core/theme/app_spacing.dart';
import 'package:bkustudenthub/core/widgets/unified_app_bar.dart';
import 'package:bkustudenthub/core/widgets/bku_card.dart';
import 'package:bkustudenthub/core/widgets/bku_shimmer.dart';
import '../providers/counseling_history_provider.dart';

class CounselingHistoryScreen extends StatefulWidget {
  const CounselingHistoryScreen({super.key});

  @override
  State<CounselingHistoryScreen> createState() => _CounselingHistoryScreenState();
}

class _CounselingHistoryScreenState extends State<CounselingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CounselingHistoryProvider>().loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UnifiedAppBar(title: 'Riwayat Konseling'),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<CounselingHistoryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const BkuShimmer();
                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }
                if (provider.filteredHistory.isEmpty) {
                  return const Center(child: Text('Belum ada riwayat'));
                }
                return RefreshIndicator(
                  onRefresh: () => provider.loadHistory(),
                  child: ListView.builder(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    itemCount: provider.filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = provider.filteredHistory[index];
                      return BkuCard(
                        margin: EdgeInsets.only(bottom: AppSpacing.md),
                        child: ListTile(
                          title: Text(item.psychologistName),
                          subtitle: Text('${item.type} • ${item.date}'),
                          trailing: _buildStatusBadge(item.status),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['all', 'menunggu', 'selesai', 'dibatalkan'];
    return Consumer<CounselingHistoryProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: filters.map((f) {
              return Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(f.toUpperCase()),
                  selected: provider.filter == f,
                  onSelected: (_) => provider.setFilter(f),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'selesai':
        color = context.appColors.success;
        break;
      case 'menunggu':
        color = context.appColors.warning;
        break;
      default:
        color = context.appColors.error;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
```

- [ ] **Step 5: Register route, run analyze, commit**

```bash
cd C:\laragon\www\BKU\bkustudenthub-mobail-new
flutter analyze lib/features/mahasiswa/counseling/
git add lib/features/mahasiswa/counseling/
git commit -m "feat(mahasiswa): add counseling history screen"
```

---

### Task 1.3: Self-Screening Kesehatan Mental Screen

**Files:**
- Create: `lib/features/mahasiswa/health/data/models/screening_model.dart`
- Create: `lib/features/mahasiswa/health/data/repositories/screening_repository.dart`
- Create: `lib/features/mahasiswa/health/presentation/providers/self_screening_provider.dart`
- Create: `lib/features/mahasiswa/health/presentation/pages/self_screening_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1: Create ScreeningModel**

```dart
// lib/features/mahasiswa/health/data/models/screening_model.dart
class ScreeningQuestion {
  final int id;
  final String text;
  final bool? answer;

  ScreeningQuestion({required this.id, required this.text, this.answer});

  ScreeningQuestion copyWith({bool? answer}) {
    return ScreeningQuestion(id: id, text: text, answer: answer ?? this.answer);
  }
}

class ScreeningResult {
  final int score;
  final String level; // normal, mild, moderate, severe
  final String description;

  ScreeningResult({required this.score, required this.level, required this.description});

  factory ScreeningResult.fromScore(int score) {
    if (score <= 4) {
      return ScreeningResult(score: score, level: 'normal', description: 'Tidak ada indikasi gangguan');
    } else if (score <= 9) {
      return ScreeningResult(score: score, level: 'mild', description: 'Gangguan ringan');
    } else if (score <= 14) {
      return ScreeningResult(score: score, level: 'moderate', description: 'Gangguan sedang');
    } else {
      return ScreeningResult(score: score, level: 'severe', description: 'Gangguan berat');
    }
  }
}
```

- [ ] **Step 2: Create ScreeningRepository**

```dart
// lib/features/mahasiswa/health/data/repositories/screening_repository.dart
import 'package:bkustudenthub/core/services/api_service.dart';
import '../models/screening_model.dart';

class ScreeningRepository {
  final ApiService _api;

  ScreeningRepository(this._api);

  Future<List<ScreeningQuestion>> getQuestions() async {
    final response = await _api.get('/api/mahasiswa/self-screening');
    return (response.data['questions'] as List)
        .map((e) => ScreeningQuestion(id: e['id'], text: e['text']))
        .toList();
  }

  Future<ScreeningResult> submitAnswers(Map<int, bool> answers) async {
    final response = await _api.post('/api/mahasiswa/self-screening/submit', data: {
      'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
    });
    return ScreeningResult.fromScore(response.data['score'] ?? 0);
  }
}
```

- [ ] **Step 3: Create SelfScreeningProvider**

```dart
// lib/features/mahasiswa/health/presentation/providers/self_screening_provider.dart
import 'package:flutter/material.dart';
import '../../data/repositories/screening_repository.dart';
import '../../data/models/screening_model.dart';

class SelfScreeningProvider extends ChangeNotifier {
  final ScreeningRepository _repository;

  List<ScreeningQuestion> _questions = [];
  int _currentIndex = 0;
  Map<int, bool> _answers = {};
  ScreeningResult? _result;
  bool _isLoading = false;
  bool _isSubmitting = false;

  SelfScreeningProvider(this._repository);

  List<ScreeningQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  ScreeningResult? get result => _result;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isComplete => _currentIndex >= _questions.length;
  bool get canProceed => _answers.containsKey(_questions.isNotEmpty ? _questions[_currentIndex].id : -1);

  Future<void> loadQuestions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _questions = await _repository.getQuestions();
    } catch (e) {
      // handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void answerQuestion(bool answer) {
    if (_currentIndex < _questions.length) {
      _answers[_questions[_currentIndex].id] = answer;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  Future<void> submit() async {
    _isSubmitting = true;
    notifyListeners();
    try {
      _result = await _repository.submitAnswers(_answers);
    } catch (e) {
      // handle error
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
```

- [ ] **Step 4: Create SelfScreeningScreen**

```dart
// lib/features/mahasiswa/health/presentation/pages/self_screening_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkustudenthub/core/theme/app_theme.dart';
import 'package:bkustudenthub/core/theme/app_radius.dart';
import 'package:bkustudenthub/core/theme/app_spacing.dart';
import 'package:bkustudenthub/core/widgets/unified_app_bar.dart';
import 'package:bkustudenthub/core/widgets/bku_button.dart';
import 'package:bkustudenthub/core/widgets/bku_card.dart';
import 'package:bkustudenthub/core/widgets/bku_shimmer.dart';
import '../providers/self_screening_provider.dart';

class SelfScreeningScreen extends StatefulWidget {
  const SelfScreeningScreen({super.key});

  @override
  State<SelfScreeningScreen> createState() => _SelfScreeningScreenState();
}

class _SelfScreeningScreenState extends State<SelfScreeningScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SelfScreeningProvider>().loadQuestions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UnifiedAppBar(title: 'Self-Screening'),
      body: Consumer<SelfScreeningProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const BkuShimmer();
          if (provider.result != null) return _buildResult(provider.result!);
          if (provider.questions.isEmpty) {
            return const Center(child: Text('Tidak ada pertanyaan'));
          }
          return _buildQuestionnaire(provider);
        },
      ),
    );
  }

  Widget _buildQuestionnaire(SelfScreeningProvider provider) {
    final question = provider.questions[provider.currentIndex];
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (provider.currentIndex + 1) / provider.totalQuestions,
          ),
          SizedBox(height: AppSpacing.md),
          Text('Pertanyaan ${provider.currentIndex + 1} / ${provider.totalQuestions}'),
          SizedBox(height: AppSpacing.lg),
          BkuCard(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(question.text, style: context.appTextStyles.bodyLarge),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: BkuButton(
                  label: 'Ya',
                  variant: provider.answers[question.id] == true
                      ? ButtonVariant.filled
                      : ButtonVariant.outlined,
                  onPressed: () => provider.answerQuestion(true),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: BkuButton(
                  label: 'Tidak',
                  variant: provider.answers[question.id] == false
                      ? ButtonVariant.filled
                      : ButtonVariant.outlined,
                  onPressed: () => provider.answerQuestion(false),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              if (provider.currentIndex > 0)
                BkuButton(
                  label: 'Sebelumnya',
                  variant: ButtonVariant.outlined,
                  onPressed: () => provider.previousQuestion(),
                ),
              const Spacer(),
              if (provider.currentIndex < provider.totalQuestions - 1)
                BkuButton(
                  label: 'Selanjutnya',
                  onPressed: provider.canProceed
                      ? () => provider.nextQuestion()
                      : null,
                )
              else
                BkuButton(
                  label: 'Submit',
                  onPressed: provider.canProceed
                      ? () => provider.submit()
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult(ScreeningResult result) {
    Color color;
    switch (result.level) {
      case 'normal':
        color = context.appColors.success;
        break;
      case 'mild':
        color = context.appColors.warning;
        break;
      default:
        color = context.appColors.error;
    }
    return Center(
      child: BkuCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.psychology, size: 64, color: color),
              SizedBox(height: AppSpacing.lg),
              Text('Skor: ${result.score}',
                  style: context.appTextStyles.headlineMedium),
              SizedBox(height: AppSpacing.sm),
              Text(result.level.toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              SizedBox(height: AppSpacing.md),
              Text(result.description, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Register route, analyze, commit**

```bash
cd C:\laragon\www\BKU\bkustudenthub-mobail-new
flutter analyze lib/features/mahasiswa/health/
git add lib/features/mahasiswa/health/
git commit -m "feat(mahasiswa): add self-screening mental health screen"
```

---

### Task 1.4: Kencana Timeline Screen

**Files:**
- Create: `lib/features/mahasiswa/kencana/data/models/timeline_model.dart`
- Create: `lib/features/mahasiswa/kencana/data/repositories/timeline_repository.dart`
- Create: `lib/features/mahasiswa/kencana/presentation/providers/kencana_timeline_provider.dart`
- Create: `lib/features/mahasiswa/kencana/presentation/pages/kencana_timeline_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1-4:** Follow same pattern as Task 1.1 (Model → Repository → Provider → Screen)
- [ ] **Step 5:** Register route, analyze, commit

---

### Task 1.5: Kencana Remedial Screen

**Files:**
- Create: `lib/features/mahasiswa/kencana/data/models/remedial_model.dart`
- Create: `lib/features/mahasiswa/kencana/data/repositories/remedial_repository.dart`
- Create: `lib/features/mahasiswa/kencana/presentation/providers/kencana_remedial_provider.dart`
- Create: `lib/features/mahasiswa/kencana/presentation/pages/kencana_remedial_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1-4:** Follow same pattern
- [ ] **Step 5:** Register route, analyze, commit

---

### Task 1.6: Kencana Sertifikat Screen

**Files:**
- Create: `lib/features/mahasiswa/kencana/data/models/certificate_model.dart`
- Create: `lib/features/mahasiswa/kencana/data/repositories/certificate_repository.dart`
- Create: `lib/features/mahasiswa/kencana/presentation/providers/kencana_certificate_provider.dart`
- Create: `lib/features/mahasiswa/kencana/presentation/pages/kencana_certificate_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1-4:** Follow same pattern
- [ ] **Step 5:** Register route, analyze, commit

---

### Task 1.7: Berita Detail Screen

**Files:**
- Create: `lib/features/mahasiswa/berita/data/models/berita_model.dart`
- Create: `lib/features/mahasiswa/berita/data/repositories/berita_repository.dart`
- Create: `lib/features/mahasiswa/berita/presentation/providers/berita_detail_provider.dart`
- Create: `lib/features/mahasiswa/berita/presentation/pages/berita_detail_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1-4:** Follow same pattern
- [ ] **Step 5:** Register route, analyze, commit

---

### Task 1.8: Create Achievement Screen

**Files:**
- Create: `lib/features/mahasiswa/achievement/data/models/achievement_form_model.dart`
- Create: `lib/features/mahasiswa/achievement/data/repositories/achievement_repository.dart`
- Create: `lib/features/mahasiswa/achievement/presentation/providers/achievement_form_provider.dart`
- Create: `lib/features/mahasiswa/achievement/presentation/pages/create_achievement_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1-4:** Follow same pattern
- [ ] **Step 5:** Register route, analyze, commit

---

### Task 1.9: Edit Achievement Screen

**Files:**
- Create: `lib/features/mahasiswa/achievement/presentation/pages/edit_achievement_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1-4:** Reuse form model/provider from Task 1.8, pre-fill data
- [ ] **Step 5:** Register route, analyze, commit

---

### Task 1.10: Scholarship Program Detail Screen

**Files:**
- Create: `lib/features/mahasiswa/scholarship/data/models/scholarship_program_model.dart`
- Create: `lib/features/mahasiswa/scholarship/data/repositories/scholarship_program_repository.dart`
- Create: `lib/features/mahasiswa/scholarship/presentation/providers/scholarship_program_provider.dart`
- Create: `lib/features/mahasiswa/scholarship/presentation/pages/scholarship_program_detail_screen.dart`
- Modify: `lib/core/routes/app_routes.dart`

- [ ] **Step 1-4:** Follow same pattern
- [ ] **Step 5:** Register route, analyze, commit

---

## PHASE 2: ORMAWA (17 screens)

### Task 2.1-2.4: LPJ Management (4 screens)

- [ ] Create LPJ model, repository, provider
- [ ] Create `ormawa_lpj_screen.dart` (list)
- [ ] Create `create_lpj_screen.dart` (form)
- [ ] Create `ormawa_lpj_detail_screen.dart` (detail)
- [ ] Create `edit_lpj_screen.dart` (edit form)
- [ ] Register routes, analyze, commit

### Task 2.5-2.8: Keuangan Detail (4 screens)

- [ ] Create keuangan detail, edit, mutasi, iuran screens
- [ ] Register routes, analyze, commit

### Task 2.9-2.11: CRUD Anggota (3 screens)

- [ ] Create anggota detail, create, edit screens
- [ ] Register routes, analyze, commit

### Task 2.12-2.14: CRUD Jadwal (3 screens)

- [ ] Create kegiatan create, detail, edit screens
- [ ] Register routes, analyze, commit

### Task 2.15-2.17: CRUD Pengumuman (3 screens)

- [ ] Create pengumuman create, detail, edit screens
- [ ] Register routes, analyze, commit

---

## PHASE 3: MENTOR KENCANA (7 screens)

### Task 3.1-3.7: Mentor Features

- [ ] Create mentor groups screen
- [ ] Create mentor group detail screen
- [ ] Create mentor available students screen
- [ ] Create mentor notes screen
- [ ] Create mentor note detail screen
- [ ] Create mentor essay grading screen
- [ ] Create mentor session attendance screen
- [ ] Register all routes, analyze, commit

---

## PHASE 4: PSIKOLOGI (7 screens)

### Task 4.1-4.7: Psychology Features

- [ ] Create admin psychologist list screen
- [ ] Create create psychologist screen
- [ ] Create psychologist detail screen
- [ ] Create edit psychologist screen
- [ ] Create patient medical record screen
- [ ] Create medical record screen
- [ ] Create all schedules screen
- [ ] Register all routes, analyze, commit

---

## PHASE 5: TENAGA KESEHATAN (10 screens)

### Task 5.1-5.10: Health Worker Features

- [ ] Create EMR examination screen
- [ ] Create live examination screen
- [ ] Create patient screen
- [ ] Create patient medical record screen
- [ ] Create medical records screen
- [ ] Create screenings screen
- [ ] Create insurance review screen
- [ ] Create all schedules screen
- [ ] Create admin TK list screen
- [ ] Create CRUD TK screens (create, detail, edit)
- [ ] Register all routes, analyze, commit

---

## Final Verification

After all 5 phases:

- [ ] Run `flutter analyze` — 0 issues
- [ ] Run `flutter test` — all pass
- [ ] Run `flutter build apk --debug` — builds successfully
- [ ] Verify all 51 new screens listed in `docs/DAFTAR_HALAMAN.md`
- [ ] Update `docs/GAP_ANALYSIS_MOBILE_VS_WEB.md` — all items marked ✅

---

## Rollback Strategy

Each phase is independent. If a phase introduces bugs:
1. Revert that phase's commits
2. Other phases remain intact
3. Fix and re-apply

```bash
git revert <commit-hash>  # revert specific phase
```
