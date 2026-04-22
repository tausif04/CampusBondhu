import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campusbondhu/core/constants/app_constants.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/core/widgets/cb_button.dart';
import 'package:campusbondhu/core/widgets/cb_text_field.dart';
import 'package:campusbondhu/core/widgets/interest_chip.dart';
import 'package:campusbondhu/features/auth/data/datasources/auth_service.dart';
import 'package:campusbondhu/features/auth/data/models/user_model.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _projectsCtrl = TextEditingController();
  final _researchCtrl = TextEditingController();
  final Set<String> _interests = {};
  bool _isLoading = false;
  UserModel? _originalUser;

  // Image picking
  File? _pickedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        _originalUser = user;
        _nameCtrl.text = user.name;
        _bioCtrl.text = user.bio ?? '';
        _projectsCtrl.text = user.projects.join('\n');
        _researchCtrl.text = user.research.join('\n');
        _interests.addAll(user.interests);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _projectsCtrl.dispose();
    _researchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (xfile != null) {
      setState(() => _pickedImage = File(xfile.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_originalUser == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(authServiceProvider);

      // Upload new profile image if picked
      String? newImageUrl = _originalUser!.profileImage;
      if (_pickedImage != null) {
        newImageUrl =
            await service.uploadProfileImage(_originalUser!.id, _pickedImage!);
      }

      final updated = _originalUser!.copyWith(
        name: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        profileImage: newImageUrl,
        interests: _interests.toList(),
        projects: _projectsCtrl.text
            .split('\n')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList(),
        research: _researchCtrl.text
            .split('\n')
            .map((r) => r.trim())
            .where((r) => r.isNotEmpty)
            .toList(),
      );

      await service.updateProfile(updated);
      ref.invalidate(currentUserProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! ✅'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingImageUrl = _originalUser?.profileImage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            Text('Edit Profile', style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar with image picker
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!) as ImageProvider
                          : (existingImageUrl != null
                              ? CachedNetworkImageProvider(existingImageUrl)
                              : null),
                      child: (_pickedImage == null && existingImageUrl == null)
                          ? Text(
                              _nameCtrl.text.isNotEmpty
                                  ? _nameCtrl.text[0].toUpperCase()
                                  : '?',
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
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'New photo selected — save to apply',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: AppColors.primary),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              CbTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                hint: 'Your full name',
                prefixIcon: Icons.badge_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CbTextField(
                controller: _bioCtrl,
                label: 'Bio',
                hint: 'Write a short bio about yourself...',
                prefixIcon: Icons.info_outline_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              CbTextField(
                controller: _projectsCtrl,
                label: 'Projects (one per line)',
                hint: 'Project 1\nProject 2...',
                prefixIcon: Icons.work_outline_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              CbTextField(
                controller: _researchCtrl,
                label: 'Research (one per line)',
                hint: 'Research topic 1\nResearch topic 2...',
                prefixIcon: Icons.science_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              Text('Interests',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.interests
                    .where((i) => i != 'Other')
                    .map((interest) => InterestChip(
                          label: interest,
                          isSelected: _interests.contains(interest),
                          onTap: () => setState(() {
                            _interests.contains(interest)
                                ? _interests.remove(interest)
                                : _interests.add(interest);
                          }),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),

              CbButton(
                label: 'Save Changes',
                icon: Icons.check_rounded,
                isLoading: _isLoading,
                onPressed: _save,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
