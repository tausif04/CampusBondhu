import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/core/widgets/interest_chip.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';
import 'package:campusbondhu/features/study_buddy/data/models/study_group_model.dart';
import 'package:campusbondhu/features/study_buddy/presentation/providers/study_group_provider.dart';
import 'package:campusbondhu/features/study_buddy/data/datasources/study_group_service.dart';

class StudyBuddyPage extends ConsumerStatefulWidget {
  const StudyBuddyPage({super.key});

  @override
  ConsumerState<StudyBuddyPage> createState() => _StudyBuddyPageState();
}

class _StudyBuddyPageState extends ConsumerState<StudyBuddyPage>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(filteredGroupsProvider);
    final filter = ref.watch(groupFilterProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: Text('Study Buddy',
                style: Theme.of(context).textTheme.headlineLarge),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary),
                onPressed: () => context.push('/study-buddy/create'),
                tooltip: 'Create Group',
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: [
                    // Search
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => ref
                          .read(groupFilterProvider.notifier)
                          .update((s) => s.copyWith(searchQuery: v)),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search groups...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                            color: AppColors.textTertiary, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textTertiary, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tag filters
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          'ML',
                          'DSA',
                          'Web Dev',
                          'Design',
                          'Physics',
                          'Math',
                          'Chemistry'
                        ]
                            .map((tag) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InterestChip(
                                    label: tag,
                                    isSelected:
                                        filter.selectedInterests.contains(tag),
                                    onTap: () {
                                      final current = List<String>.from(
                                          filter.selectedInterests);
                                      current.contains(tag)
                                          ? current.remove(tag)
                                          : current.add(tag);
                                      ref
                                          .read(groupFilterProvider.notifier)
                                          .update((s) => s.copyWith(
                                              selectedInterests: current));
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (groups) => groups.isEmpty
              ? _EmptyGroupsState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => StudyGroupCard(
                          group: groups[i], currentUserId: user?.id ?? '')
                      .animate(delay: (i * 60).ms)
                      .fadeIn()
                      .slideY(begin: 0.08),
                ),
        ),
      ),
    );
  }
}

class StudyGroupCard extends ConsumerWidget {
  final StudyGroupModel group;
  final String currentUserId;

  const StudyGroupCard({
    super.key,
    required this.group,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMember = group.members.contains(currentUserId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isMember
            ? () => context.push('/study-buddy/chat/${group.id}')
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        group.name.isNotEmpty
                            ? group.name[0].toUpperCase()
                            : 'G',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
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
                  if (isMember)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Text('Joined',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(studyGroupServiceProvider)
                            .joinGroup(group.id, currentUserId);
                        ref.invalidate(allGroupsProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Join'),
                    ),
                ],
              ),
              if (group.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  group.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.people_outline_rounded,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text('${group.memberCount} members',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: AppColors.textTertiary)),
                  const Spacer(),
                  if (group.lastMessage != null) ...[
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      group.lastMessage!.length > 30
                          ? '${group.lastMessage!.substring(0, 30)}...'
                          : group.lastMessage!,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ],
              ),
              if (group.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: group.tags
                      .take(3)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(tag,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500)),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups_outlined,
                size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text('No Groups Yet',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Be the first to create a study group!',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
