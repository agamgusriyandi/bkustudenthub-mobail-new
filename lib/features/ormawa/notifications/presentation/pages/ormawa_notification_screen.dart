import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/ormawa/notifications/presentation/pages/ormawa_notifications_screen.dart';

class OrmawaNotificationScreen extends StatelessWidget {
  final bool showBackButton;
  const OrmawaNotificationScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return OrmawaNotificationsScreen(showBackButton: showBackButton);
  }
}
