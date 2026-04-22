import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/features/study_buddy/data/datasources/study_group_service.dart';
import 'package:campusbondhu/features/study_buddy/data/models/study_group_model.dart';
import 'package:campusbondhu/features/study_buddy/presentation/providers/study_group_provider.dart';

class AdminGroupsPage extends ConsumerStatefulWidget {
  const AdminGroupsPage({super.key});

  @override
  ConsumerState<AdminGroupsPage> createState() => _AdminGroupsPageState();
}

class _AdminGroupsPageState extends ConsumerState<AdminGroupsPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteGroup(StudyGroupModel group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Group',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${group.name}"? This cannot be undone.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ref.read(studyGroupServiceProvider).deleteGroup(group.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"${group.name}" deleted'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  void _viewGroup(StudyGroupModel group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GroupDetailSheet(group: group),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(allGroupsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Study Group Management',
            style: Theme.of(context).textTheme.headlineLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name or subject...',
                hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppColors.textTertiary, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textTertiary, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (groups) {
          final filtered = _searchQuery.isEmpty
              ? groups
              : groups
                  .where((g) =>
                      g.name.toLowerCase().contains(_searchQuery) ||
                      g.subject.toLowerCase().contains(_searchQuery) ||
                      g.createdByName.toLowerCase().contains(_searchQuery))
                  .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.groups_outlined,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text('No study groups found',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(children: [
                  Text('${filtered.length} groups',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
                ]),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _GroupCard(
                    group: filtered[i],
                    onView: () => _viewGroup(filtered[i]),
                    onDelete: () => _deleteGroup(filtered[i]),
                  ).animate(delay: (i * 40).ms).fadeIn().slideY(begin: 0.05),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final StudyGroupModel group;
  final VoidCallback onView;
  final VoidCallback onDelete;

  const _GroupCard(
      {required this.group, required this.onView, required this.onDelete});

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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name,
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis),
                Text(group.subject,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis),
                Row(children: [
                  const Icon(Icons.people_outline,
                      size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Text('${group.memberCount} members',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: AppColors.textTertiary)),
                  const SizedBox(width: 8),
                  const Icon(Icons.person_outline,
                      size: 12, color: AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text('by ${group.createdByName}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: AppColors.textTertiary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ],
            ),
          ),
          // View details
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            color: AppColors.primary,
            tooltip: 'View Details',
            onPressed: onView,
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            color: AppColors.error,
            tooltip: 'Delete Group',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _GroupDetailSheet extends StatelessWidget {
  final StudyGroupModel group;
  const _GroupDetailSheet({required this.group});

  @override
  Widget build(BuildContext context) {
    final color = const [
      AppColors.techColor,
      AppColors.scienceColor,
      AppColors.artsColor,
    ][group.name.length % 3];

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        group.name.isNotEmpty
                            ? group.name[0].toUpperCase()
                            : 'G',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                    child: Text(group.name,
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 20, fontWeight: FontWeight.w700))),
                Center(
                    child: Text(group.subject,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: AppColors.textSecondary))),
                const SizedBox(height: 20),
                _DetailRow(
                    icon: Icons.people_rounded,
                    label: 'Members',
                    value: '${group.memberCount}'),
                _DetailRow(
                    icon: Icons.person_rounded,
                    label: 'Created By',
                    value: group.createdByName),
                _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Created',
                    value:
                        '${group.createdAt.day}/${group.createdAt.month}/${group.createdAt.year}'),
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Description',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary)),
                  const SizedBox(height: 4),
                  Text(group.description,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: AppColors.textSecondary)),
                ],
                if (group.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Tags',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: group.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: color.withOpacity(0.2))),
                              child: Text('#$t',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: color,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text('$label: ',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600)),
        Expanded(
            child: Text(value,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.textPrimary))),
      ]),
    );
  }
}
