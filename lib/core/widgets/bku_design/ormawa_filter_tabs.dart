import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';

class OrmawaTabItem {
  final String key;
  final String label;
  final int count;

  const OrmawaTabItem({
    required this.key,
    required this.label,
    required this.count,
  });
}

class OrmawaFilterTabs extends StatelessWidget {
  final List<OrmawaTabItem> tabs;
  final String activeKey;
  final ValueChanged<String> onTabChanged;

  const OrmawaFilterTabs({
    super.key,
    required this.tabs,
    required this.activeKey,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          final isActive = tab.key == activeKey;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onTabChanged(tab.key),
              borderRadius: OrmawaTheme.rPill,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                decoration: BoxDecoration(
                  color: isActive ? OrmawaTheme.primary : OrmawaTheme.cardSurface,
                  borderRadius: OrmawaTheme.rPill,
                  border: Border.all(
                    color: isActive ? OrmawaTheme.primary : OrmawaTheme.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : OrmawaTheme.textBody,
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withAlpha(45)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tab.count}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isActive ? Colors.white : OrmawaTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
