import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/core/widgets/cb_button.dart';
import 'package:campusbondhu/core/widgets/cb_text_field.dart';
import 'package:campusbondhu/core/widgets/interest_chip.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';
import 'package:campusbondhu/features/study_buddy/data/models/study_group_model.dart';
import 'package:campusbondhu/features/study_buddy/presentation/providers/study_group_provider.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final group = StudyGroupModel(
      id: '',
      name: _nameCtrl.text.trim(),
      subject: _subjectCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      createdById: user.id,
      createdByName: user.name,
      members: [user.id],
      tags: _selectedTags.toList(),
      memberCount: 1,
      createdAt: DateTime.now(),
    );

    await ref.read(groupCreationProvider.notifier).create(group);
    final state = ref.read(groupCreationProvider);

    if (state.hasError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      if (mounted) {
        final newId = state.valueOrNull;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group created successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        if (newId != null) {
          context.pushReplacement('/study-buddy/chat/$newId');
        } else {
          context.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(groupCreationProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            Text('Create Study Group', style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon preview
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      _nameCtrl.text.isNotEmpty
                          ? _nameCtrl.text[0].toUpperCase()
                          : 'G',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              CbTextField(
                controller: _nameCtrl,
                label: 'Group Name',
                hint: 'e.g. ML Study Circle',
                prefixIcon: Icons.groups_rounded,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CbTextField(
                controller: _subjectCtrl,
                label: 'Subject / Topic',
                hint: 'e.g. Machine Learning, DSA, Physics',
                prefixIcon: Icons.book_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CbTextField(
                controller: _descCtrl,
                label: 'Description',
                hint: 'What will you study? What are the goals?',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              Text('Tags / Interests',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Machine Learning', 'Deep Learning', 'Data Science',
                  'Web Dev', 'Mobile Dev', 'DSA', 'Algorithms', 'Math',
                  'Physics', 'Chemistry', 'Design', 'Research', 'Programming'
                ]
                    .map((tag) => InterestChip(
                          label: tag,
                          isSelected: _selectedTags.contains(tag),
                          onTap: () => setState(() {
                            _selectedTags.contains(tag)
                                ? _selectedTags.remove(tag)
                                : _selectedTags.add(tag);
                          }),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 32),

              CbButton(
                label: 'Create Group',
                icon: Icons.check_circle_outline_rounded,
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
