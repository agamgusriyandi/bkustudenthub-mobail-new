import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_screen.dart';
import 'package:go_router/go_router.dart';

class DeadlineItem {
  final String name;
  final int daysLeft;
  final String? type;
  final String? link;

  DeadlineItem({
    required this.name,
    required this.daysLeft,
    this.type,
    this.link,
  });
}

class DeadlineAlert extends StatelessWidget {
  final List<DeadlineItem> deadlines;

  const DeadlineAlert({super.key, this.deadlines = const []});

  IconData _getIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'beasiswa':
        return Icons.school_rounded;
      case 'konseling':
        return Icons.support_agent_rounded;
      case 'kampus':
        return Icons.event_note_rounded;
      case 'kencana':
        return Icons.menu_book_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getUrgencyColor(int daysLeft) {
    if (daysLeft <= 3) return const Color(0xFFE11D48);
    if (daysLeft <= 7) return const Color(0xFFD97706);
    return const Color(0xFF2563EB);
  }

  Color _getUrgencyBg(int daysLeft) {
    if (daysLeft <= 3) return const Color(0xFFFFF1F2);
    if (daysLeft <= 7) return const Color(0xFFFEF3C7);
    return const Color(0xFFEFF6FF);
  }

  @override
  Widget build(BuildContext context) {
    if (deadlines.isEmpty) return const SizedBox.shrink();

    final visibleDeadlines = deadlines.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD97706),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pengingat Jatuh Tempo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScholarshipScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleDeadlines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) => _buildDeadlineItem(ctx, visibleDeadlines[idx]),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(BuildContext context, DeadlineItem item) {
    final urgencyColor = _getUrgencyColor(item.daysLeft);
    final urgencyBg = _getUrgencyBg(item.daysLeft);

    return InkWell(
      onTap: () {
        if (item.link != null && item.link!.isNotEmpty) {
          context.push(item.link!);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScholarshipScreen(),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: urgencyBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(item.type),
                color: urgencyColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: urgencyBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: urgencyColor.withAlpha(60)),
              ),
              child: Text(
                '${item.daysLeft} Hari Lagi',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: urgencyColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
