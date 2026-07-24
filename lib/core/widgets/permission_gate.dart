import 'package:flutter/material.dart';
import '../services/permission_service.dart';

/// PermissionGate - A reusable widget for permission-based UI rendering
///
/// Usage:
/// ```dart
/// PermissionGate(
///   permission: 'delete_members',
///   child: IconButton(
///     icon: Icon(Icons.delete),
///     onPressed: _onDelete,
///   ),
/// )
///
/// // With custom fallback
/// PermissionGate(
///   permission: 'edit_members',
///   child: EditButton(),
///   fallback: ViewOnlyButton(),
/// )
/// ```
class PermissionGate extends StatelessWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess = PermissionService().hasPermission(permission);

    if (hasAccess) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// PermissionGateAll - Shows child only if user has ALL of the specified permissions
class PermissionGateAll extends StatelessWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;

  const PermissionGateAll({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess = PermissionService().hasAllPermissions(permissions);

    if (hasAccess) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// PermissionGateAny - Shows child only if user has ANY of the specified permissions
class PermissionGateAny extends StatelessWidget {
  final List<String> permissions;
  final Widget child;
  final Widget? fallback;

  const PermissionGateAny({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccess = PermissionService().hasAnyPermission(permissions);

    if (hasAccess) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// PermissionGateOrmawa - Special gate for Ormawa role-based access
/// Automatically checks if user is logged in as Ormawa
class PermissionGateOrmawa extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const PermissionGateOrmawa({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    // Check if user has at least some Ormawa permission
    final hasAccess = PermissionService().hasAnyPermission([
      'view_dashboard',
      'view_proposal',
      'view_members',
      'view_calendar',
    ]);

    if (hasAccess) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
