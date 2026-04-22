import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';

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
                _SectionHeader(
                    title: '🔥 Trending Topics',
                    onSeeAll: () => context.go('/study-buddy')),
                const SizedBox(height: 12),
                _TrendingTopicsRow(),
                const SizedBox(height: 24),
                _SectionHeader(
                    title: '📚 Featured Study Groups',
                    onSeeAll: () => context.go('/study-buddy')),
                const SizedBox(height: 12),
                _FeaturedGroupsColumn(),
                const SizedBox(height: 24),
                _SectionHeader(
                    title: '🎉 Upcoming Events',
                    onSeeAll: () => context.go('/events')),
                const SizedBox(height: 12),
                _UpcomingEventsColumn(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
        TextButton(
          onPressed: onSeeAll,
          child: Text('See all',
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _TrendingTopicsRow extends StatelessWidget {
  final _topics = const [
    ('Machine Learning', Icons.psychology_rounded, AppColors.techColor),
    ('Data Science', Icons.bar_chart_rounded, AppColors.scienceColor),
    ('UI/UX Design', Icons.design_services_rounded, AppColors.artsColor),
    ('Blockchain', Icons.link_rounded, AppColors.businessColor),
    ('Robotics', Icons.precision_manufacturing_rounded, AppColors.sportsColor),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final (label, icon, color) = _topics[i];
          return _TopicChip(label: label, icon: icon, color: color)
              .animate(delay: (i * 80).ms)
              .fadeIn()
              .slideX(begin: 0.2);
        },
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _TopicChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _FeaturedGroupsColumn extends StatelessWidget {
  final _groups = const [
    ('ML Study Circle', 'Machine Learning', 12, AppColors.techColor),
    ('DSA Crackdown', 'Data Structures', 8, AppColors.scienceColor),
    ('Design Thinking', 'UI/UX & Product', 15, AppColors.artsColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _groups.asMap().entries.map((e) {
        final (name, subject, members, color) = e.value;
        return _GroupCard(name: name, subject: subject, members: members, color: color)
            .animate(delay: (e.key * 100).ms)
            .fadeIn()
            .slideY(begin: 0.1);
      }).toList(),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String name, subject;
  final int members;
  final Color color;
  const _GroupCard({required this.name, required this.subject, required this.members, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Icon(Icons.groups_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.labelLarge),
                Text(subject, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$members members',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Join',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsColumn extends StatelessWidget {
  final _events = const [
    ('Tech Fest 2025', 'CSE Department', 'Dec 20', 'Auditorium'),
    ('Research Symposium', 'Science Faculty', 'Dec 25', 'Hall A'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _events.asMap().entries.map((e) {
        final (title, org, date, loc) = e.value;
        return _EventCard(title: title, organizer: org, date: date, location: loc)
            .animate(delay: (e.key * 100).ms)
            .fadeIn()
            .slideY(begin: 0.1);
      }).toList(),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title, organizer, date, location;
  const _EventCard({required this.title, required this.organizer, required this.date, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(date.split(' ').last,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(date.split(' ').first,
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                Text(organizer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 2),
                    Text(location,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
