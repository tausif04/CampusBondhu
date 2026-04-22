import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/core/widgets/interest_chip.dart';
import 'package:campusbondhu/features/auth/data/models/user_model.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox();
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.background,
                title: Text('Profile',
                    style: Theme.of(context).textTheme.headlineLarge),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: AppColors.primary,
                    onPressed: () => context.push('/profile/edit'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ProfileHeader(user: user).animate().fadeIn(),
                    const SizedBox(height: 20),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      _SectionCard(
                        title: 'About',
                        child: Text(
                          user.bio!,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ).animate(delay: 80.ms).fadeIn(),
                      const SizedBox(height: 12),
                    ],
                    _SectionCard(
                      title: 'Education',
                      child: _EducationSection(user: user),
                    ).animate(delay: 120.ms).fadeIn(),
                    const SizedBox(height: 12),
                    if (user.interests.isNotEmpty) ...[
                      _SectionCard(
                        title: 'Interests',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests
                              .map((i) =>
                                  InterestChip(label: i, isSelected: true))
                              .toList(),
                        ),
                      ).animate(delay: 160.ms).fadeIn(),
                      const SizedBox(height: 12),
                    ],
                    if (user.projects.isNotEmpty) ...[
                      _SectionCard(
                        title: 'Projects',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: user.projects
                              .map((p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.arrow_right_rounded,
                                            color: AppColors.primary, size: 20),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(p,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ).animate(delay: 200.ms).fadeIn(),
                      const SizedBox(height: 12),
                    ],
                    if (user.research.isNotEmpty) ...[
                      _SectionCard(
                        title: 'Research',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: user.research
                              .map((r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.science_outlined,
                                            color: AppColors.accent, size: 16),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(r,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ).animate(delay: 240.ms).fadeIn(),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    // Admin Panel button — only visible to admin users
                    if (user.isAdmin) ...[
                      _AdminPanelButton(),
                      const SizedBox(height: 10),
                    ],
                    // Logout button — uses its own StatefulWidget to safely
                    // handle async navigation without context-after-async issues
                    const _LogoutButton(),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          if (user.isAdmin) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_rounded,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('Admin',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EducationSection extends StatelessWidget {
  final UserModel user;
  const _EducationSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
            icon: Icons.school_rounded,
            label: 'Institution',
            value: user.institution),
        const SizedBox(height: 8),
        _InfoRow(
            icon: Icons.book_rounded,
            label: 'Department',
            value: user.department),
        const SizedBox(height: 8),
        _InfoRow(
            icon: Icons.calendar_month_rounded,
            label: 'Year / Semester',
            value: user.yearSemester),
        if (user.phone != null) ...[
          const SizedBox(height: 8),
          _InfoRow(
              icon: Icons.phone_rounded, label: 'Phone', value: user.phone!),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.textTertiary)),
              Text(value,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout button as its own ConsumerStatefulWidget.
// This is necessary because:
//   1. ProfilePage is a ConsumerWidget — it has no `mounted` guard.
//   2. When logout() invalidates providers, ProfilePage rebuilds mid-async,
//      which causes navigator.dart assertion failures.
//   3. A StatefulWidget has a proper `mounted` check and its own lifecycle,
//      so the async logout + navigation is safe here.
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutButton extends ConsumerStatefulWidget {
  const _LogoutButton();

  @override
  ConsumerState<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends ConsumerState<_LogoutButton> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to log out?',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child:
                Text('Logout', style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authNotifierProvider.notifier).logout();
    } finally {
      // mounted check after every await — StatefulWidget makes this reliable
      if (mounted) setState(() => _isLoading = false);
    }

    // Navigate after logout — mounted is reliable here because this is
    // a StatefulWidget, unlike ConsumerWidget which has no mounted guard
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _handleLogout,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.error),
            )
          : const Icon(Icons.logout_rounded, size: 18),
      label: Text(_isLoading ? 'Logging out...' : 'Log Out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Panel button — only rendered when user.isAdmin == true
// ─────────────────────────────────────────────────────────────────────────────
class _AdminPanelButton extends StatelessWidget {
  const _AdminPanelButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go('/admin'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withOpacity(0.15),
                AppColors.warning.withOpacity(0.05),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Panel',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text('Manage users, events & groups',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.warning, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
