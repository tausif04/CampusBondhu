import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';
import 'package:campusbondhu/features/notifications/notification_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bell icon widget — used in home page header
// ─────────────────────────────────────────────────────────────────────────────
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) return const SizedBox.shrink();

    final unread = ref.watch(unreadCountProvider(user.id)).valueOrNull ?? 0;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: _NotificationsSheet(userId: user.id),
        ),
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_outlined,
                size: 22, color: AppColors.textPrimary),
            if (unread > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : unread.toString(),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification bottom sheet
// Uses plain string type from AppNotification model:
//   'message' | 'event_approved' | 'event_rejected' | 'event_upcoming'
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationsSheet extends ConsumerWidget {
  final String userId;
  const _NotificationsSheet({required this.userId});

  IconData _iconFor(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_outline_rounded;
      case 'event_approved':
        return Icons.check_circle_outline_rounded;
      case 'event_rejected':
        return Icons.cancel_outlined;
      case 'event_upcoming':
        return Icons.alarm_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'message':
        return AppColors.primary;
      case 'event_approved':
        return AppColors.success;
      case 'event_rejected':
        return AppColors.error;
      case 'event_upcoming':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider(userId));
    final service = ref.read(notificationServiceProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(children: [
              Text('Notifications',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () => service.markAllRead(userId),
                child: Text('Mark all read',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: notifsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (notifs) {
                if (notifs.isEmpty) {
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_none_rounded,
                              size: 56, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text('No notifications yet',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary)),
                        ]),
                  );
                }
                return ListView.separated(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: notifs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final n = notifs[i];
                    final color = _colorFor(n.type);
                    return Dismissible(
                      key: Key(n.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => service.deleteNotification(n.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          await service.markRead(n.id);
                          // n.routePath is the field in AppNotification
                          if (n.routePath != null && ctx.mounted) {
                            Navigator.pop(ctx);
                            GoRouter.of(ctx).go(n.routePath!);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? Colors.white
                                : color.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: n.isRead
                                    ? AppColors.border
                                    : color.withOpacity(0.25)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(_iconFor(n.type),
                                  color: color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(n.title,
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: n.isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.w700,
                                                color: AppColors.textPrimary)),
                                      ),
                                      if (!n.isRead)
                                        Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle)),
                                    ]),
                                    const SizedBox(height: 2),
                                    Text(n.body,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: AppColors.textSecondary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(timeago.format(n.createdAt),
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: AppColors.textTertiary)),
                                  ]),
                            ),
                          ]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
