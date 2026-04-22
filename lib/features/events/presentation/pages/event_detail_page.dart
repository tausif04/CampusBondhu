import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/core/widgets/cb_button.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';
import 'package:campusbondhu/features/events/data/datasources/event_service.dart';
import 'package:campusbondhu/features/events/data/models/event_model.dart';
import 'package:campusbondhu/features/events/presentation/pages/create_event_page.dart';
import 'package:campusbondhu/features/events/presentation/providers/event_provider.dart';

class EventDetailPage extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    // If 'create' is passed as eventId, redirect to create event page
    if (widget.eventId == 'create') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.replace('/events/create');
      });
    }
  }

  bool _isRegistering = false;

  Future<void> _toggleRegistration(
      EventModel event, String userId, bool isRegistered) async {
    setState(() => _isRegistering = true);
    try {
      final service = ref.read(eventServiceProvider);
      if (isRegistered) {
        await service.unregister(userId, event.id);
      } else {
        await service.registerForEvent(userId, event.id);
      }
      ref.invalidate(registrationProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final eventAsync = ref.watch(singleEventProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (event) {
          if (event == null) {
            return const Center(child: Text('Event not found'));
          }
          return userAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (user) {
              if (user == null) return const SizedBox();
              final regArgs = (userId: user.id, eventId: widget.eventId);
              final isRegisteredAsync =
                  ref.watch(registrationProvider(regArgs));
              final isRegistered = isRegisteredAsync.valueOrNull ?? false;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: AppColors.primary,
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.event_rounded,
                              size: 80, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.displayMedium,
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _InfoPill(
                              icon: Icons.calendar_today_rounded,
                              label:
                                  DateFormat('MMM d, y').format(event.dateTime),
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            _InfoPill(
                              icon: Icons.access_time_rounded,
                              label:
                                  DateFormat('h:mm a').format(event.dateTime),
                              color: AppColors.secondary,
                            ),
                          ],
                        ).animate().fadeIn(delay: 150.ms),
                        const SizedBox(height: 10),
                        _InfoPill(
                          icon: Icons.location_on_rounded,
                          label: event.location,
                          color: AppColors.accent,
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              child: Text(
                                event.organizerName.isNotEmpty
                                    ? event.organizerName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Organized by',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppColors.textTertiary)),
                                Text(event.organizerName,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.people_rounded,
                                      size: 14, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text('${event.registrationCount} going',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 250.ms),
                        const SizedBox(height: 24),
                        Text('About this Event',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        Text(
                          event.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  height: 1.6, color: AppColors.textSecondary),
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 24),
                        if (event.tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: event.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.2)),
                                      ),
                                      child: Text('#$tag',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                          ).animate().fadeIn(delay: 350.ms),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: eventAsync.maybeWhen(
        data: (event) => userAsync.maybeWhen(
          data: (user) {
            if (event == null || user == null) return const SizedBox.shrink();
            final regArgs = (userId: user.id, eventId: widget.eventId);
            final isRegisteredAsync = ref.watch(registrationProvider(regArgs));
            final isRegistered = isRegisteredAsync.valueOrNull ?? false;
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: CbButton(
                label:
                    isRegistered ? 'Cancel Registration' : 'Register for Event',
                icon: isRegistered
                    ? Icons.cancel_outlined
                    : Icons.how_to_reg_rounded,
                isLoading: _isRegistering,
                onPressed: () =>
                    _toggleRegistration(event, user.id, isRegistered),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
