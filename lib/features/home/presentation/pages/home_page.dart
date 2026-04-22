import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';
import 'package:campusbondhu/features/events/data/models/event_model.dart';
import 'package:campusbondhu/features/events/presentation/providers/event_provider.dart';
import 'package:campusbondhu/features/study_buddy/data/models/study_group_model.dart';
import 'package:campusbondhu/features/study_buddy/presentation/providers/study_group_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: _HomeHeader(userAsync: userAsync),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Trending Topics — no "See all", carousel layout ──
                Text('🔥 Trending Topics',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                const _TrendingTopicsCarousel(),
                const SizedBox(height: 24),

                // ── Featured Study Groups — real Firestore data ──
                _SectionHeader(
                    title: '📚 Featured Study Groups',
                    onSeeAll: () => context.go('/study-buddy')),
                const SizedBox(height: 12),
                const _RealGroupsColumn(),
                const SizedBox(height: 24),

                // ── Upcoming Events — real Firestore data ──
                _SectionHeader(
                    title: '🎉 Upcoming Events',
                    onSeeAll: () => context.go('/events')),
                const SizedBox(height: 12),
                const _RealEventsColumn(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final AsyncValue userAsync;
  const _HomeHeader({required this.userAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.05), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                userAsync.when(
                  data: (user) => Text(
                    'Hello, ${user?.name.split(' ').first ?? 'Student'}! 👋',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  loading: () => const SizedBox(height: 28),
                  error: (_, __) => const SizedBox(),
                ),
                Text(
                  'What are you studying today?',
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              color: AppColors.textPrimary,
              onPressed: () {},
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header (with See all)
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 16)),
        TextButton(
          onPressed: onSeeAll,
          child: Text('See all',
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trending Topics — carousel, no "See all" button, more cards
// ─────────────────────────────────────────────────────────────────────────────
class _TrendingTopicsCarousel extends StatefulWidget {
  const _TrendingTopicsCarousel();

  @override
  State<_TrendingTopicsCarousel> createState() =>
      _TrendingTopicsCarouselState();
}

class _TrendingTopicsCarouselState extends State<_TrendingTopicsCarousel> {
  final PageController _ctrl = PageController(viewportFraction: 0.44);
  int _current = 0;

  static const _topics = [
    ('Machine Learning', Icons.psychology_rounded, AppColors.techColor,
        '2.4k students'),
    ('Data Science', Icons.bar_chart_rounded, AppColors.scienceColor,
        '1.8k students'),
    ('UI/UX Design', Icons.design_services_rounded, AppColors.artsColor,
        '3.1k students'),
    ('Blockchain', Icons.link_rounded, AppColors.businessColor,
        '980 students'),
    ('Robotics', Icons.precision_manufacturing_rounded, AppColors.sportsColor,
        '760 students'),
    ('Cybersecurity', Icons.shield_rounded, AppColors.techColor,
        '1.2k students'),
    ('Cloud Computing', Icons.cloud_rounded, AppColors.scienceColor,
        '1.5k students'),
    ('Web Development', Icons.code_rounded, AppColors.businessColor,
        '4.2k students'),
    ('Mobile Apps', Icons.smartphone_rounded, AppColors.artsColor,
        '2.9k students'),
    ('Data Structures', Icons.account_tree_rounded, AppColors.sportsColor,
        '3.6k students'),
  ];

  void _prev() {
    if (_current > 0) {
      _ctrl.animateToPage(
        _current - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _next() {
    if (_current < _topics.length - 1) {
      _ctrl.animateToPage(
        _current + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Left arrow
            _ArrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: _current > 0,
              onTap: _prev,
            ),
            // Carousel
            Expanded(
              child: SizedBox(
                height: 120,
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: _topics.length,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemBuilder: (context, i) {
                    final (label, icon, color, count) = _topics[i];
                    final isActive = i == _current;
                    return AnimatedScale(
                      scale: isActive ? 1.0 : 0.92,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isActive ? color.withOpacity(0.12) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isActive ? color.withOpacity(0.4) : AppColors.border,
                            width: isActive ? 1.5 : 1,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: color, size: 22),
                            ),
                            const SizedBox(height: 8),
                            Text(label,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(count,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Right arrow
            _ArrowButton(
              icon: Icons.chevron_right_rounded,
              enabled: _current < _topics.length - 1,
              onTap: _next,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_topics.length, (i) {
            final isActive = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Real study groups from Firestore (latest 3)
// ─────────────────────────────────────────────────────────────────────────────
class _RealGroupsColumn extends ConsumerWidget {
  const _RealGroupsColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(allGroupsProvider);

    return groupsAsync.when(
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      )),
      error: (e, _) => _ErrorCard(message: e.toString()),
      data: (groups) {
        if (groups.isEmpty) {
          return _EmptyCard(
            icon: Icons.groups_outlined,
            message: 'No study groups yet.\nBe the first to create one!',
            onTap: () => context.go('/study-buddy'),
          );
        }
        // Show latest 3
        final latest = groups.take(3).toList();
        return Column(
          children: latest.asMap().entries.map((e) {
            return _RealGroupCard(group: e.value)
                .animate(delay: (e.key * 100).ms)
                .fadeIn()
                .slideY(begin: 0.1);
          }).toList(),
        );
      },
    );
  }
}

class _RealGroupCard extends StatelessWidget {
  final StudyGroupModel group;
  const _RealGroupCard({required this.group});

  static const _colors = [
    AppColors.techColor,
    AppColors.scienceColor,
    AppColors.artsColor,
    AppColors.businessColor,
    AppColors.sportsColor,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[group.name.length % _colors.length];
    return GestureDetector(
      onTap: () => context.go('/study-buddy'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: Theme.of(context).textTheme.labelLarge),
                  Text(group.subject,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${group.memberCount} members',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Join',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Real events from Firestore (latest 3 approved)
// ─────────────────────────────────────────────────────────────────────────────
class _RealEventsColumn extends ConsumerWidget {
  const _RealEventsColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(approvedEventsProvider);

    return eventsAsync.when(
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      )),
      error: (e, _) => _ErrorCard(message: e.toString()),
      data: (events) {
        if (events.isEmpty) {
          return _EmptyCard(
            icon: Icons.event_outlined,
            message: 'No upcoming events yet.\nCheck back soon!',
            onTap: () => context.go('/events'),
          );
        }
        final latest = events.take(3).toList();
        return Column(
          children: latest.asMap().entries.map((e) {
            return _RealEventCard(event: e.value)
                .animate(delay: (e.key * 100).ms)
                .fadeIn()
                .slideY(begin: 0.1);
          }).toList(),
        );
      },
    );
  }
}

class _RealEventCard extends StatelessWidget {
  final EventModel event;
  const _RealEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('d').format(event.dateTime);
    final month = DateFormat('MMM').format(event.dateTime);

    return GestureDetector(
      onTap: () => context.go('/events/${event.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.secondaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(day,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Text(month,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(event.organizerName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(event.location,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textTertiary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onTap;
  const _EmptyCard(
      {required this.icon, required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.textTertiary),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Text('Error loading data',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.error)),
    );
  }
}
