import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/permission_service.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import '../services/notification_service.dart';

/// A widget that observes app lifecycle and syncs permissions on resume
///
/// Wrap your app with this widget to ensure permissions are synced
/// when the app comes back from background.
class AppLifecycleObserver extends StatefulWidget {
  final Widget child;

  const AppLifecycleObserver({super.key, required this.child});

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  // //   DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService().startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService().stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // _pausedTime = DateTime.now();
        break;

      case AppLifecycleState.resumed:
        _onAppResumed();
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _onAppResumed() async {
    // Sync permissions when app comes back from background
    // This ensures user gets fresh permissions if admin changed them in Web
    try {
      final synced = await PermissionService().syncPermissions();
      if (synced && mounted) {
        debugPrint('[AppLifecycleObserver] Permissions synced on resume');

        // Also notify OrmawaProvider to refresh UI if needed
        try {
          final ormawaProvider = context.read<OrmawaProvider>();
          ormawaProvider.refreshData();
        } catch (_) {
          // OrmawaProvider might not be in context, ignore
        }
      }
    } catch (e) {
      debugPrint('[AppLifecycleObserver] Failed to sync permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
