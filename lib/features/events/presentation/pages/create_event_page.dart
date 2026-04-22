import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:campusbondhu/core/constants/app_constants.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/core/widgets/cb_button.dart';
import 'package:campusbondhu/core/widgets/cb_text_field.dart';
import 'package:campusbondhu/core/widgets/interest_chip.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';
import 'package:campusbondhu/features/events/data/models/event_model.dart';
import 'package:campusbondhu/features/events/presentation/providers/event_provider.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final dateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    final event = EventModel(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      dateTime: dateTime,
      organizerName: user.name,
      organizerId: user.id,
      status: AppConstants.statusPending,
      tags: _selectedTags.toList(),
      createdAt: DateTime.now(),
    );

    await ref.read(eventCreationProvider.notifier).create(event);
    final state = ref.read(eventCreationProvider);

    if (state.hasError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: AppColors.error),
        );
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 28),
                const SizedBox(width: 8),
                Text('Event Submitted!',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
              ],
            ),
            content: Text(
              'Your event has been submitted for admin approval. It will appear publicly once approved.',
              style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: Text('OK',
                    style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(eventCreationProvider).isLoading;
    final dateStr = _selectedDate != null
        ? DateFormat('MMMM d, yyyy').format(_selectedDate!)
        : 'Pick a date';
    final timeStr = _selectedTime != null
        ? _selectedTime!.format(context)
        : 'Pick a time';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Event', style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.info, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Events require admin approval before being visible to everyone.',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CbTextField(
                controller: _titleCtrl,
                label: 'Event Title',
                hint: 'e.g. Annual Tech Fest 2025',
                prefixIcon: Icons.title_rounded,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CbTextField(
                controller: _descCtrl,
                label: 'Description',
                hint: 'Tell people what this event is about...',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              CbTextField(
                controller: _locationCtrl,
                label: 'Location',
                hint: 'e.g. Main Auditorium, Block A',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Date & Time row
              Row(
                children: [
                  Expanded(
                    child: _PickerButton(
                      label: 'Date',
                      value: dateStr,
                      icon: Icons.calendar_today_rounded,
                      onTap: _pickDate,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerButton(
                      label: 'Time',
                      value: timeStr,
                      icon: Icons.access_time_rounded,
                      onTap: _pickTime,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('Tags / Category',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Tech', 'Science', 'Arts', 'Sports', 'Career', 'Social', 'Research', 'Cultural']
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
                label: 'Submit for Approval',
                icon: Icons.send_rounded,
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

class _PickerButton extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _PickerButton({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.color,
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(value,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: value.startsWith('Pick')
                              ? AppColors.textTertiary
                              : AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
