import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:campusbondhu/core/constants/app_constants.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/features/events/data/datasources/event_service.dart';
import 'package:campusbondhu/features/events/data/models/event_model.dart';
import 'package:campusbondhu/features/events/presentation/providers/event_provider.dart';

class AdminEventsPage extends ConsumerStatefulWidget {
  const AdminEventsPage({super.key});

  @override
  ConsumerState<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends ConsumerState<AdminEventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String eventId, String status) async {
    try {
      await ref.read(eventServiceProvider).updateStatus(eventId, status);
      ref.invalidate(allEventsProvider);
      ref.invalidate(pendingEventsProvider);
      ref.invalidate(approvedEventsProvider);

      if (mounted) {
        final label = status == AppConstants.statusApproved ? 'Approved' : 'Rejected';
        final color = status == AppConstants.statusApproved ? AppColors.success : AppColors.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event $label!'), backgroundColor: color),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEventsAsync = ref.watch(allEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Event Moderation', style: Theme.of(context).textTheme.headlineLarge),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: allEventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (events) {
          final pending = events.where((e) => e.status == AppConstants.statusPending).toList();
          final approved = events.where((e) => e.status == AppConstants.statusApproved).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _EventList(
                events: pending,
                showActions: true,
                onApprove: (id) => _updateStatus(id, AppConstants.statusApproved),
                onReject: (id) => _updateStatus(id, AppConstants.statusRejected),
                emptyMessage: 'No pending events 🎉',
              ),
              _EventList(
                events: approved,
                showActions: false,
                emptyMessage: 'No approved events yet',
              ),
              _EventList(
                events: events,
                showActions: true,
                onApprove: (id) => _updateStatus(id, AppConstants.statusApproved),
                onReject: (id) => _updateStatus(id, AppConstants.statusRejected),
                emptyMessage: 'No events yet',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<EventModel> events;
  final bool showActions;
  final void Function(String)? onApprove;
  final void Function(String)? onReject;
  final String emptyMessage;

  const _EventList({
    required this.events,
    required this.showActions,
    this.onApprove,
    this.onReject,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(emptyMessage, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _AdminEventCard(
        event: events[i],
        showActions: showActions,
        onApprove: onApprove,
        onReject: onReject,
      ).animate(delay: (i * 50).ms).fadeIn().slideY(begin: 0.08),
    );
  }
}

class _AdminEventCard extends StatelessWidget {
  final EventModel event;
  final bool showActions;
  final void Function(String)? onApprove;
  final void Function(String)? onReject;

  const _AdminEventCard({
    required this.event,
    required this.showActions,
    this.onApprove,
    this.onReject,
  });

  Color get _statusColor {
    switch (event.status) {
      case AppConstants.statusApproved: return AppColors.success;
      case AppConstants.statusRejected: return AppColors.error;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(event.title,
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    event.status.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: _statusColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _MetaChip(
                        icon: Icons.calendar_today_rounded,
                        label: DateFormat('MMM d, yyyy').format(event.dateTime)),
                    _MetaChip(icon: Icons.location_on_outlined, label: event.location),
                    _MetaChip(icon: Icons.person_outline_rounded, label: event.organizerName),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          if (showActions && event.status == AppConstants.statusPending) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showConfirmDialog(context, false),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showConfirmDialog(context, true),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showConfirmDialog(BuildContext context, bool approve) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(approve ? 'Approve Event' : 'Reject Event',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text(
            approve
                ? 'This event will be visible to all students.'
                : 'This event will be rejected and hidden.',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(approve ? 'Approve' : 'Reject',
                style: TextStyle(
                    color: approve ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (approve) {
        onApprove?.call(event.id);
      } else {
        onReject?.call(event.id);
      }
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
