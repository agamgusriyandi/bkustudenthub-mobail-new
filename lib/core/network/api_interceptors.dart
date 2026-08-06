import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';
import 'package:bkuhub_mobile/core/services/secure_storage_service.dart';

/// Global key to access navigator from anywhere in the app
/// Set this in MaterialApp.router or wrap with Navigator material key
final GlobalKey<NavigatorState> apiNavigatorKey = GlobalKey<NavigatorState>();

class ApiInterceptor extends Interceptor {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ensure path has /api prefix (avoids URI resolution issues with leading slashes)
    if (!options.path.startsWith('http') && !options.path.startsWith('/api')) {
      options.path = '/api${options.path.startsWith('/') ? '' : '/'}${options.path}';
    }

    // Inject token if available
    final token = await SecureStorageService().getToken();

    final isLoginRequest = options.path.contains('/auth/login');

    if (token != null && !isLoginRequest) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Origin'] = 'https://bkustudenthub.com';

    if (kDebugMode) {
      log('--> ${options.method} ${options.uri}');
      log('Headers: ${options.headers}');
      if (options.data != null) {
        if (isLoginRequest) {
          log('Body: [REDACTED FOR SECURITY]');
        } else {
          log('Body: ${options.data}');
        }
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('<-- ${response.statusCode} ${response.requestOptions.uri}');

    // Global API success validation
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('status') && data['status'] == 'error') {
        final error = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message:
              data['message']?.toString() ?? 'Terjadi kesalahan pada server',
        );
        handler.reject(error);
        return;
      }
    }

    super.onResponse(response, handler);
  }

  static bool _isHandling401 = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    log('<-- Error ${err.response?.statusCode} ${err.requestOptions.uri}');
    log('Message: ${err.message}');
    log('Response body: ${err.response?.data}');
    log('Type: ${err.type}');

    // Handle global 401 Unauthorized
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/login')) {
      log('Unauthorized! Session expired or invalid token.');

      if (!_isHandling401) {
        _isHandling401 = true;

        // Use AuthService logout to clear state completely
        try {
          // Import auth_service.dart if not imported (we will add it at the top)
          // Wait, we can't easily import it without creating a circular dependency if AuthService uses ApiClient.
          // ApiClient imports ApiInterceptors. AuthService imports ApiClient.
          // Let's just clear SharedPreferences directly and navigate.
          final sharedPrefs = await prefs;
          await SecureStorageService().deleteToken();
          await SecureStorageService().deleteUserData();
          await sharedPrefs.remove('user_role');

          final navigator = apiNavigatorKey.currentState;
          if (navigator != null && navigator.mounted) {
            ScaffoldMessenger.of(navigator.context).showSnackBar(
              const SnackBar(
                content: Text('Sesi telah berakhir. Silakan login kembali.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              if (navigator.mounted) {
                // Since this uses GoRouter, we go('/login')
                navigator.context.go('/login');

                // Reset flag after a while so user can login again
                Future.delayed(const Duration(seconds: 2), () {
                  _isHandling401 = false;
                });
              } else {
                _isHandling401 = false;
              }
            });
          } else {
            _isHandling401 = false;
          }
        } catch (e) {
          _isHandling401 = false;
        }
      }
    }

    super.onError(err, handler);
  }
}
