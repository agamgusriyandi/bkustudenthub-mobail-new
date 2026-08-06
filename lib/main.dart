import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/features/ormawa/data/datasources/ormawa_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/academic_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/health_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/organization_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_voice_provider.dart';

import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/health_view_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/providers/scholarship_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/providers/achievement_provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/services/notification_service.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/app_lifecycle_observer.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/psychologist_dashboard_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/student_counseling_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/referral_provider.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';

import 'package:bkuhub_mobile/features/mahasiswa/data/repositories/student_repository_impl.dart';
import 'package:bkuhub_mobile/features/ormawa/data/repositories/ormawa_repository_impl.dart';
import 'package:bkuhub_mobile/features/counseling/data/repositories/counseling_repository_impl.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/repositories/tk_repository_impl.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_dashboard_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_health_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_schedule_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_booking_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_medical_records_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/providers/self_screening_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/berita/presentation/providers/berita_detail_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/providers/achievement_form_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/providers/scholarship_program_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  await LocalNotificationService.initialize();

  // Initialize Core Networking & Repositories
  final apiClient = ApiClient();
  final studentRepository = StudentRepositoryImpl(apiClient: apiClient);
  final ormawaRepository = OrmawaRepositoryImpl(
    ormawaRemoteDataSource: OrmawaRemoteDataSourceImpl(dio: apiClient.client),
  );
  final counselingRepository = CounselingRepositoryImpl(apiClient: apiClient);
  final tkRepository = TkRepositoryImpl(apiClient: apiClient);

  // Initialize Global Notification Navigation using GoRouter
  BkuAppBar.defaultOnNotificationTap = (context, variant) {
    if (variant == AppBarVariant.ormawa) {
      context.push(AppRoutes.ormawaNotifications);
    } else if (variant == AppBarVariant.psychologist) {
      context.push(AppRoutes.psychologistNotifications);
    } else {
      context.push(AppRoutes.studentNotifications);
    }
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthService()),
        ChangeNotifierProvider.value(value: NotificationService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        ChangeNotifierProvider(create: (_) => ProfileProvider(repository: studentRepository)),
        ChangeNotifierProvider(create: (_) => AcademicProvider(repository: studentRepository)),
        ChangeNotifierProvider(create: (_) => MahasiswaCounselingProvider(repository: studentRepository)),
        ChangeNotifierProvider(create: (_) => HealthProvider(repository: studentRepository)),
        ChangeNotifierProvider(create: (_) => OrganizationProvider(repository: studentRepository)),
        ChangeNotifierProvider(create: (_) => StudentVoiceProvider(repository: studentRepository)),

        ChangeNotifierProvider(
          create: (_) => HealthViewModel(repository: studentRepository),
        ),
        ChangeNotifierProvider(create: (_) => ScholarshipProvider(repository: studentRepository)),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => KencanaProvider()),
        ChangeNotifierProvider(
          create:
              (_) => PsychologistDashboardProvider(
                repository: counselingRepository,
              ),
        ),
        ChangeNotifierProvider(
          create: (_) => CounselingProvider(repository: counselingRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReferralProvider(repository: counselingRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentCounselingProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(create: (_) => OrmawaProvider(ormawaRepository)),
        // TK (Tenaga Kesehatan) Providers
        ChangeNotifierProvider(
          create: (_) => TkDashboardProvider(repository: tkRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TkHealthProvider(repository: tkRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TkScheduleProvider(repository: tkRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TkBookingProvider(repository: tkRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TkPatientProvider(repository: tkRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TkMedicalRecordsProvider(repository: tkRepository),
        ),
        ChangeNotifierProvider(create: (_) => MentorKencanaProvider()),
        ChangeNotifierProvider(create: (_) => SelfScreeningProvider()),
        ChangeNotifierProvider(create: (_) => BeritaDetailProvider()),
        ChangeNotifierProvider(create: (_) => AchievementFormProvider()),
        ChangeNotifierProvider(create: (_) => ScholarshipProgramProvider()),
      ],
      child: const AppLifecycleObserver(child: MyApp()),
    ),
  );
}

class NoStretchScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'BKU Student HUB',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      scrollBehavior: NoStretchScrollBehavior(),
      theme: ThemeData(
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.primary,
          primary: themeProvider.primary,
          onPrimary: themeProvider.onPrimary,
          secondary: themeProvider.secondary,
          onSecondary: themeProvider.onSecondary,
          surface: themeProvider.surface,
          onSurface: themeProvider.secondary,
          onSurfaceVariant: themeProvider.secondary.withValues(alpha: 0.8),
          outline: themeProvider.secondary.withValues(alpha: 0.6),
          outlineVariant: themeProvider.secondary.withValues(alpha: 0.4),
          error: themeProvider.colorError,
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
          backgroundColor: themeProvider.surface,
          elevation: 10,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.neutral50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: const TextStyle(color: AppColors.neutral400),
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: const BorderSide(color: AppColors.neutral200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: const BorderSide(color: AppColors.neutral200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: themeProvider.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: themeProvider.colorError, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.radiusMd,
            borderSide: BorderSide(color: themeProvider.colorError, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeProvider.primary,
            foregroundColor: themeProvider.onPrimary,
            elevation: 0,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: themeProvider.primary,
            side: BorderSide(color: themeProvider.primary),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: themeProvider.primary,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: themeProvider.primary,
          foregroundColor: themeProvider.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        scaffoldBackgroundColor: themeProvider.background,
        // Override AppBar theme with dynamic primary color
        appBarTheme: AppBarTheme(
          backgroundColor: themeProvider.primary,
          foregroundColor: themeProvider.onPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: themeProvider.onPrimary,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: themeProvider.onPrimary, size: 24),
        ),
      ),
    );
  }
}
