import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/features/auth/data/datasources/auth_service.dart';
import 'package:campusbondhu/features/auth/data/models/user_model.dart';

// Real-time stream of all users
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(authServiceProvider).getAllUsersStream();
});

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});
  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('User Management', style: Theme.of(context).textTheme.headlineLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name, email or username...',
                hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) {
          final filtered = _searchQuery.isEmpty ? users : users.where((u) =>
            u.name.toLowerCase().contains(_searchQuery) ||
            u.email.toLowerCase().contains(_searchQuery) ||
            u.username.toLowerCase().contains(_searchQuery) ||
            u.department.toLowerCase().contains(_searchQuery)).toList();

          if (filtered.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.person_search_rounded, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text('No users found', style: Theme.of(context).textTheme.bodyMedium),
            ]));
          }

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(children: [
                Text('${filtered.length} users',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _UserCard(user: filtered[i])
                    .animate(delay: (i * 40).ms).fadeIn().slideY(begin: 0.05),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final UserModel user;
  const _UserCard({required this.user});

  Future<void> _toggleSuspend(BuildContext context, WidgetRef ref) async {
    final action = user.isSuspended ? 'unsuspend' : 'suspend';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${action[0].toUpperCase()}${action.substring(1)} User',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to $action ${user.name}?',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action[0].toUpperCase() + action.substring(1),
                style: TextStyle(color: user.isSuspended ? AppColors.success : AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(authServiceProvider).toggleSuspend(user.id, !user.isSuspended);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${user.name} has been ${user.isSuspended ? 'unsuspended' : 'suspended'}'),
          backgroundColor: user.isSuspended ? AppColors.success : AppColors.warning,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _viewProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserProfileSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: user.isSuspended ? AppColors.error.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
          child: user.profileImage == null
              ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(user.name, style: Theme.of(context).textTheme.labelLarge, overflow: TextOverflow.ellipsis)),
            if (user.isAdmin) ...[const SizedBox(width: 4), const Icon(Icons.shield_rounded, size: 13, color: AppColors.warning)],
            if (user.isSuspended) ...[const SizedBox(width: 4), const Icon(Icons.block_rounded, size: 13, color: AppColors.error)],
          ]),
          Text('@${user.username}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
          Text(user.department, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11), overflow: TextOverflow.ellipsis),
        ])),
        // View Profile button
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, size: 20),
          color: AppColors.primary,
          tooltip: 'View Profile',
          onPressed: () => _viewProfile(context),
        ),
        // Suspend/Unsuspend button
        IconButton(
          icon: Icon(user.isSuspended ? Icons.lock_open_rounded : Icons.block_rounded, size: 20),
          color: user.isSuspended ? AppColors.success : AppColors.error,
          tooltip: user.isSuspended ? 'Unsuspend' : 'Suspend',
          onPressed: () => _toggleSuspend(context, ref),
        ),
      ]),
    );
  }
}

// Full profile bottom sheet
class _UserProfileSheet extends StatelessWidget {
  final UserModel user;
  const _UserProfileSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 0, 20, 40), children: [
            // Avatar + name
            Center(child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
              child: user.profileImage == null
                  ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary))
                  : null,
            )),
            const SizedBox(height: 12),
            Center(child: Text(user.name, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700))),
            Center(child: Text('@${user.username}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600))),
            if (user.isSuspended)
              Center(child: Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('SUSPENDED', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 20),
            _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
            if (user.phone != null) _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: user.phone!),
            _InfoRow(icon: Icons.school_outlined, label: 'Institution', value: user.institution),
            _InfoRow(icon: Icons.book_outlined, label: 'Department', value: user.department),
            _InfoRow(icon: Icons.calendar_today_outlined, label: 'Year', value: user.yearSemester),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Bio', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              Text(user.bio!, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary)),
            ],
            if (user.interests.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Interests', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6, children: user.interests.map((i) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                child: Text(i, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              )).toList()),
            ],
            if (user.projects.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Projects', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              ...user.projects.map((p) => Padding(padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [const Icon(Icons.arrow_right_rounded, color: AppColors.primary, size: 18), const SizedBox(width: 4), Expanded(child: Text(p, style: GoogleFonts.plusJakartaSans(fontSize: 13)))]))),
            ],
            if (user.research.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Research', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              ...user.research.map((r) => Padding(padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [const Icon(Icons.science_outlined, color: AppColors.accent, size: 16), const SizedBox(width: 6), Expanded(child: Text(r, style: GoogleFonts.plusJakartaSans(fontSize: 13)))]))),
            ],
          ])),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
      ]),
    );
  }
}
