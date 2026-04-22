import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campusbondhu/core/constants/app_constants.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/core/widgets/cb_button.dart';
import 'package:campusbondhu/core/widgets/cb_text_field.dart';
import 'package:campusbondhu/core/widgets/interest_chip.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 1 controllers
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Profile photo
  File? _profileImage;
  final _picker = ImagePicker();

  // Page 2
  final _institutionCtrl = TextEditingController();
  String? _selectedDept;
  String? _selectedYear;

  // Page 3
  final Set<String> _selectedInterests = {};
  final _otherInterestCtrl = TextEditingController();
  final _projectsCtrl = TextEditingController();
  final _researchCtrl = TextEditingController();

  bool _obscure = true;
  String? _error;

  final _form1Key = GlobalKey<FormState>();
  final _form2Key = GlobalKey<FormState>();

  Future<void> _pickProfileImage() async {
    final xfile = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (xfile != null) {
      setState(() => _profileImage = File(xfile.path));
    }
  }

  Future<void> _register() async {
    setState(() => _error = null);
    final interests = List<String>.from(_selectedInterests);
    if (_otherInterestCtrl.text.isNotEmpty) {
      interests.add(_otherInterestCtrl.text.trim());
    }

    await ref.read(authNotifierProvider.notifier).registerWithImage(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          name: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          institution: _institutionCtrl.text.trim(),
          department: _selectedDept!,
          yearSemester: _selectedYear!,
          interests: interests,
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          profileImage: _profileImage,
        );

    final state = ref.read(authNotifierProvider);
    if (state.hasError) {
      setState(() =>
          _error = state.error.toString().replaceFirst('Exception: ', ''));
    } else {
      if (mounted) context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage == 0 &&
        !(_form1Key.currentState?.validate() ?? false)) return;
    if (_currentPage == 1 &&
        !(_form2Key.currentState?.validate() ?? false)) return;
    _pageController.nextPage(
        duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                ),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/login'),
              ),
        title: Text('Create Account',
            style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 4),
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          i <= _currentPage ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Step ${_currentPage + 1} of 3',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _buildPage1(),
                _buildPage2(),
                _buildPage3(isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Personal Info',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text('Tell us who you are',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            // Profile photo picker
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.person_rounded,
                              size: 44,
                              color: AppColors.primary.withOpacity(0.5))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _profileImage != null
                    ? 'Photo selected ✓'
                    : 'Tap to add profile photo (optional)',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: _profileImage != null
                        ? AppColors.success
                        : AppColors.textTertiary),
              ),
            ),
            const SizedBox(height: 20),

            CbTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Your full name',
              prefixIcon: Icons.badge_outlined,
              validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CbTextField(
              controller: _usernameCtrl,
              label: 'Username',
              hint: 'Unique username (e.g. john_doe)',
              prefixIcon: Icons.alternate_email_rounded,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (v!.length < 3) return 'Minimum 3 characters';
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v))
                  return 'Only letters, numbers & underscore';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CbTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'your@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (!v!.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            CbTextField(
              controller: _phoneCtrl,
              label: 'Phone (optional)',
              hint: '+880...',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CbTextField(
              controller: _passwordCtrl,
              label: 'Password',
              hint: 'Minimum 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textTertiary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (v!.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 32),
            CbButton(label: 'Continue', onPressed: _nextPage),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _form2Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Academic Info',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text('Your institutional details',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            CbTextField(
              controller: _institutionCtrl,
              label: 'Institution Name',
              hint: 'University / College name',
              prefixIcon: Icons.school_outlined,
              validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _DropdownField(
              label: 'Department',
              hint: 'Select department',
              value: _selectedDept,
              items: AppConstants.departments,
              onChanged: (v) => setState(() => _selectedDept = v),
              validator: (v) => v == null ? 'Please select a department' : null,
            ),
            const SizedBox(height: 16),
            _DropdownField(
              label: 'Current Year / Semester',
              hint: 'Select year or semester',
              value: _selectedYear,
              items: AppConstants.yearSemesters,
              onChanged: (v) => setState(() => _selectedYear = v),
              validator: (v) => v == null ? 'Please select your year' : null,
            ),
            const SizedBox(height: 32),
            CbButton(label: 'Continue', onPressed: _nextPage),
          ],
        ),
      ),
    );
  }

  Widget _buildPage3(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Interests & More',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text('Help us match you with the right people',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Text('Your Interests',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.interests
                .where((i) => i != 'Other')
                .map((interest) => InterestChip(
                      label: interest,
                      isSelected: _selectedInterests.contains(interest),
                      onTap: () => setState(() {
                        _selectedInterests.contains(interest)
                            ? _selectedInterests.remove(interest)
                            : _selectedInterests.add(interest);
                      }),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          CbTextField(
            controller: _otherInterestCtrl,
            label: 'Other Interest (optional)',
            hint: 'Type your own interest',
            prefixIcon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 20),
          CbTextField(
            controller: _projectsCtrl,
            label: 'Projects (optional)',
            hint: 'List your current projects...',
            maxLines: 3,
            prefixIcon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: 16),
          CbTextField(
            controller: _researchCtrl,
            label: 'Research (optional)',
            hint: 'Any research work...',
            maxLines: 3,
            prefixIcon: Icons.science_outlined,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!,
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.error, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 32),
          CbButton(
            label: 'Create Account',
            isLoading: isLoading,
            onPressed: _register,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text('Sign in',
                    style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary, fontSize: 14)),
          decoration: InputDecoration(
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
