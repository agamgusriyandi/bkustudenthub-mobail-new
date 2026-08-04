import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'dart:developer';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/main.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';

class NotificationItem {
  final String id;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? link;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.link,
  });

  static String _parseHtmlString(String htmlString) {
    if (htmlString.isEmpty) return '';
    // Menghapus tag HTML seperti <p>, </p>, <br>, dll
    var document = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    // Mengubah HTML entity yang umum menjadi teks biasa
    document = document
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
    // Format ('TEXT') menjadi "TEXT" agar lebih rapi
    document = document.replaceAll("('", '"').replaceAll("')", '"');
    return document.trim();
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id'] ?? json['ID'] ?? '').toString(),
      title: (json['Judul']?.toString() ??
              json['judul']?.toString() ??
              json['title']?.toString() ??
              'Notifikasi')
          .replaceAll("('", '"')
          .replaceAll("')", '"'),
      content: _parseHtmlString(
        json['Deskripsi']?.toString() ??
            json['deskripsi']?.toString() ??
            json['konten']?.toString() ??
            json['content']?.toString() ??
            '',
      ),
      type:
          json['Tipe']?.toString() ??
          json['tipe']?.toString() ??
          json['type']?.toString() ??
          'info',
      link: json['link']?.toString() ?? json['Link']?.toString(),
      isRead: json['is_read'] == true || json['IsRead'] == true,
      createdAt:
          DateTime.tryParse(
            json['created_at']?.toString() ??
                json['CreatedAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      content: content,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiClient _apiClient = ApiClient();
  Timer? _pollingTimer;
  String? _lastNotifId;
  int _unreadCount = 0;
  List<NotificationItem> _notifications = [];

  int get unreadCount => _unreadCount;
  List<NotificationItem> get notifications => _notifications;

  void startPolling() {
    _pollingTimer?.cancel();
    _checkNewNotifications(); // Jalankan check pertama kali secara instan saat aplikasi dibuka
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkNewNotifications();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void clearState() {
    stopPolling();
    _lastNotifId = null;
    _unreadCount = 0;
    _notifications = [];
    notifyListeners();
  }

  Future<void> _checkNewNotifications() async {
    // Check if user is logged in before polling
    if (AuthService().token == null ||
        AuthService().currentRole == UserRole.guest) {
      return;
    }

    try {
      final notifs = await getNotifications();
      if (notifs.isEmpty) {
        return;
      }

      final latest = notifs.first;
      if (!latest.isRead && latest.id != _lastNotifId && _lastNotifId != null) {
        bool shouldShowPopup = false;

        // Cek Role dan Settings Tenaga Kesehatan
        if (AuthService().currentRole == UserRole.tenagaKesehatan) {
          final prefs = await SharedPreferences.getInstance();
          final isBooking = latest.title.toLowerCase().contains('booking');
          final isAlert =
              latest.title.toLowerCase().contains('batal') ||
              latest.title.toLowerCase().contains('ulang');

          if (isBooking) {
            shouldShowPopup = prefs.getBool('tk_notif_booking') ?? true;
          } else if (isAlert) {
            shouldShowPopup = prefs.getBool('tk_notif_alert') ?? true;
          } else {
            shouldShowPopup = true; // default for other notifs
          }
        } else {
          // Bagi mahasiswa (student) atau role lain, selalu tampilkan pop-up dan suara
          shouldShowPopup = true;
        }

        if (shouldShowPopup) {
          // Show popup local notification for new unread notif
          LocalNotificationService.showNotification(
            id: latest.id.hashCode,
            title: latest.title,
            body: latest.content,
          );

          // Resolve dynamic SnackBar background color based on Super Admin config
          final theme = ThemeProvider.current;
          Color snackbarBgColor = theme?.primary ?? const Color(0xFF1A3BAA);
          Color snackbarTextColor = theme?.onPrimary ?? Colors.white;
          if (theme != null) {
            final titleLower = latest.title.toLowerCase();
            final contentLower = latest.content.toLowerCase();
            final isError =
                titleLower.contains('batal') ||
                titleLower.contains('tolak') ||
                titleLower.contains('gagal') ||
                contentLower.contains('batal') ||
                contentLower.contains('tolak') ||
                contentLower.contains('gagal') ||
                latest.type == 'error';
            final isSuccess =
                titleLower.contains('berhasil') ||
                titleLower.contains('setuju') ||
                titleLower.contains('sukses') ||
                contentLower.contains('berhasil') ||
                contentLower.contains('setuju') ||
                contentLower.contains('sukses') ||
                latest.type == 'success';
            final isWarning =
                titleLower.contains('peringatan') || latest.type == 'warning';

            if (isError) {
              snackbarBgColor = theme.colorError;
              snackbarTextColor = theme.colors.onError;
            } else if (isSuccess) {
              snackbarBgColor = theme.success;
              snackbarTextColor = theme.colors.onSuccess;
            } else if (isWarning) {
              snackbarBgColor = theme.warning;
              snackbarTextColor = theme.colors.onWarning;
            } else {
              snackbarBgColor = theme.primary;
              snackbarTextColor = theme.onPrimary;
            }
          }

          // Show In-App Snackbar
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    latest.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: snackbarTextColor,
                    ),
                  ),
                  if (latest.content.isNotEmpty)
                    Text(
                      latest.content,
                      style: TextStyle(
                        color: snackbarTextColor.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              behavior: SnackBarBehavior.floating,

              backgroundColor: snackbarBgColor,
              margin: const EdgeInsets.all(AppSpacing.lg),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
      _lastNotifId = latest.id;

      final unread = notifs.where((n) => !n.isRead).length;
      bool shouldNotify = false;

      if (_unreadCount != unread) {
        _unreadCount = unread;
        shouldNotify = true;
      }

      if (_notifications.length != notifs.length ||
          _notifications.firstOrNull?.id != notifs.firstOrNull?.id) {
        _notifications = notifs;
        shouldNotify = true;
      }

      if (shouldNotify) {
        notifyListeners();
      }
    } catch (e) {
      log('Polling error: $e');
    }
  }

  /// Ambil semua notifikasi dengan optional filter tipe
  Future<List<NotificationItem>> getNotifications({String? tipe}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (tipe != null && tipe != 'Semua') {
        queryParams['tipe'] = tipe.toLowerCase();
      }
      final role = AuthService().currentRole;
      String endpoint = '/notifikasi/';
      if (role == UserRole.tenagaKesehatan) {
        endpoint = '/tenagakes/notifikasi';
      } else if (role == UserRole.psychologist) {
        endpoint = '/psychologist/notifications';
      }

      final response = await _apiClient.client.get(
        endpoint,
        queryParameters: queryParams,
      );
      final List data = response.data['data'] ?? [];
      log('RAW NOTIFICATIONS FROM SERVER: ${response.data}');
      final notifs =
          data.map((json) => NotificationItem.fromJson(json)).toList();
      _notifications = notifs;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      return notifs;
    } catch (e) {
      log('Error getting notifications: $e');
      return [];
    }
  }

  /// Ambil jumlah notifikasi yang belum dibaca
  Future<int> getUnreadCount() async {
    try {
      final role = AuthService().currentRole;
      String endpoint = '/notifikasi/unread-count';
      if (role == UserRole.tenagaKesehatan) {
        endpoint = '/tenagakes/notifikasi/unread-count';
      } else if (role == UserRole.psychologist) {
        endpoint = '/psychologist/notifications/unread-count';
      }
      final response = await _apiClient.client.get(endpoint);
      return (response.data['count'] ?? 0) as int;
    } catch (e) {
      log('Error getting unread count: $e');
      return 0;
    }
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<bool> markAsRead(String id) async {
    try {
      final role = AuthService().currentRole;
      String endpoint = '/notifikasi/$id/baca';
      if (role == UserRole.tenagaKesehatan) {
        endpoint = '/tenagakes/notifikasi/$id/baca';
      } else if (role == UserRole.psychologist) {
        endpoint = '/psychologist/notifications/$id/read';
      }
      await _apiClient.client.put(endpoint);
      _notifications =
          _notifications
              .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
              .toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      return true;
    } catch (e) {
      log('Error marking notification as read: $e');
      return false;
    }
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<bool> markAllAsRead() async {
    try {
      final role = AuthService().currentRole;
      String endpoint = '/notifikasi/baca-semua';
      if (role == UserRole.tenagaKesehatan) {
        endpoint = '/tenagakes/notifikasi/baca-semua';
      } else if (role == UserRole.psychologist) {
        endpoint = '/psychologist/notifications/read-all';
      }
      await _apiClient.client.put(endpoint);
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
      return true;
    } catch (e) {
      log('Error marking all as read: $e');
      return false;
    }
  }

  /// Hapus satu notifikasi
  Future<bool> deleteNotification(String id) async {
    try {
      final role = AuthService().currentRole;
      String endpoint = '/notifikasi/$id';
      if (role == UserRole.tenagaKesehatan) {
        endpoint = '/tenagakes/notifikasi/$id';
      } else if (role == UserRole.psychologist) {
        endpoint = '/psychologist/notifications/$id';
      }
      await _apiClient.client.delete(endpoint);
      _notifications.removeWhere((n) => n.id == id);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      return true;
    } catch (e) {
      log('Error deleting notification: $e');
      return false;
    }
  }

  /// Hapus semua notifikasi yang sudah dibaca
  Future<bool> deleteReadNotifications() async {
    try {
      final role = AuthService().currentRole;
      String endpoint = '/notifikasi/hapus-dibaca';
      if (role == UserRole.tenagaKesehatan) {
        endpoint = '/tenagakes/notifikasi/hapus-dibaca';
      } else if (role == UserRole.psychologist) {
        endpoint = '/psychologist/notifications/delete-read';
      }
      await _apiClient.client.delete(endpoint);
      _notifications.removeWhere((n) => n.isRead);
      notifyListeners();
      return true;
    } catch (e) {
      log('Error deleting read notifications: $e');
      return false;
    }
  }

  /// Hapus beberapa notifikasi sekaligus (bulk)
  Future<bool> deleteBulk(List<String> ids) async {
    try {
      await _apiClient.client.delete(
        AuthService().currentRole == UserRole.tenagaKesehatan
            ? '/tenagakes/notifikasi/hapus-bulk'
            : (AuthService().currentRole == UserRole.psychologist
                ? '/psychologist/notifications/bulk-delete'
                : '/notifikasi/hapus-bulk'),
        data: {'ids': ids},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return true;
    } catch (e) {
      log('Error deleting bulk notifications: $e');
      return false;
    }
  }
}
