import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/features/events/presentation/providers/event_provider.dart';
import 'package:campusbondhu/features/study_buddy/presentation/providers/study_group_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEventsAsync = ref.watch(allEventsProvider);
    final pendingEventsAsync = ref.watch(pendingEventsProvider);
    final allGroupsAsync = ref.watch(allGroupsProvider);

    final totalEvents = allEventsAsync.valueOrNull?.length ?? 0;
    final pendingEvents = pendingEventsAsync.valueOrNull?.length ?? 0;
    final totalGroups = allGroupsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Panel', style: Theme.of(context).textTheme.headlineLarge),
            Text('CampusBondhu Moderation',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats grid
            Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  title: 'Total Events',
                  value: totalEvents.toString(),
                  icon: Icons.event_rounded,
                  color: AppColors.primary,
                ).animate(delay: 0.ms).fadeIn().slideY(begin: 0.15),
                _StatCard(
                  title: 'Pending Approval',
                  value: pendingEvents.toString(),
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.warning,
                  badge: pendingEvents > 0 ? pendingEvents : null,
                ).animate(delay: 60.ms).fadeIn().slideY(begin: 0.15),
                _StatCard(
                  title: 'Study Groups',
                  value: totalGroups.toString(),
                  icon: Icons.groups_rounded,
                  color: AppColors.accent,
                ).animate(delay: 120.ms).fadeIn().slideY(begin: 0.15),
                _StatCard(
                  title: 'Total Users',
                  value: '—',
                  icon: Icons.people_rounded,
                  color: AppColors.secondary,
                ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.15),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions
            Text('Quick Actions', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.event_available_rounded,
              title: 'Event Moderation',
              subtitle: '$pendingEvents events awaiting approval',
              color: AppColors.warning,
              badge: pendingEvents,
              onTap: () => context.push('/admin/events'),
            ).animate(delay: 250.ms).fadeIn(),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.people_alt_rounded,
              title: 'User Management',
              subtitle: 'View, search, and manage students',
              color: AppColors.primary,
              onTap: () => context.push('/admin/users'),
            ).animate(delay: 310.ms).fadeIn(),
            const SizedBox(height: 10),
            _ActionCard(
              icon: Icons.groups_rounded,
              title: 'Study Groups',
              subtitle: 'Monitor $totalGroups active groups',
              color: AppColors.accent,
              onTap: () {},
            ).animate(delay: 370.ms).fadeIn(),

            const SizedBox(height: 24),

            // Recent pending events preview
            if (pendingEvents > 0) ...[
              Text('Pending Events', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              pendingEventsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (events) => Column(
                  children: events
                      .take(3)
                      .map((e) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_rounded,
                                    color: AppColors.warning, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(e.title,
                                      style: Theme.of(context).textTheme.labelLarge),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/admin/events'),
                                  child: Text('Review',
                                      style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final int? badge;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (badge != null && badge! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(badge.toString(),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              Text(title,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final int badge;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge.toString(),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
