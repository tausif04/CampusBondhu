import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:campusbondhu/core/theme/app_theme.dart';
import 'package:campusbondhu/features/auth/presentation/providers/auth_provider.dart';
import 'package:campusbondhu/features/study_buddy/data/datasources/study_group_service.dart';
import 'package:campusbondhu/features/study_buddy/data/models/study_group_model.dart';
import 'package:campusbondhu/features/study_buddy/presentation/providers/study_group_provider.dart';

class StudyGroupChatPage extends ConsumerStatefulWidget {
  final String groupId;
  const StudyGroupChatPage({super.key, required this.groupId});

  @override
  ConsumerState<StudyGroupChatPage> createState() => _StudyGroupChatPageState();
}

class _StudyGroupChatPageState extends ConsumerState<StudyGroupChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  StudyGroupModel? _group;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    final group =
        await ref.read(studyGroupServiceProvider).getGroup(widget.groupId);
    if (mounted) setState(() => _group = group);
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    _msgCtrl.clear();

    final message = MessageModel(
      id: '',
      groupId: widget.groupId,
      senderId: user.id,
      senderName: user.name,
      senderImage: user.profileImage,
      text: text,
      timestamp: DateTime.now(),
    );

    await ref.read(sendMessageProvider.notifier).send(message);
    _scrollToBottom();
  }

  void _showGroupInfo() {
    if (_group == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GroupInfoSheet(
          group: _group!,
          currentUserId: ref.read(currentUserProvider).valueOrNull?.id ?? ''),
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(groupMessagesProvider(widget.groupId));
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _group?.name.isNotEmpty == true
                      ? _group!.name[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _group?.name ?? 'Loading...',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_group?.memberCount ?? 0} members · ${_group?.subject ?? ''}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: _showGroupInfo,
            tooltip: 'Group Info',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text('No messages yet',
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text('Be the first to say something!',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: AppColors.textTertiary)),
                      ],
                    ),
                  );
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == user?.id;
                    final showAvatar = !isMe &&
                        (i == 0 || messages[i - 1].senderId != msg.senderId);
                    return _MessageBubble(
                      message: msg,
                      isMe: isMe,
                      showAvatar: showAvatar,
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                          color: AppColors.textTertiary, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Group Info Bottom Sheet — StatefulWidget for safe async navigation
// ─────────────────────────────────────────────────────────────────────────────
class _GroupInfoSheet extends ConsumerStatefulWidget {
  final StudyGroupModel group;
  final String currentUserId;
  const _GroupInfoSheet({required this.group, required this.currentUserId});

  @override
  ConsumerState<_GroupInfoSheet> createState() => _GroupInfoSheetState();
}

class _GroupInfoSheetState extends ConsumerState<_GroupInfoSheet> {
  StudyGroupModel get group => widget.group;
  String get currentUserId => widget.currentUserId;

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
    final isCreator = group.createdById == currentUserId;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                // Group avatar
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: color.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        group.name.isNotEmpty
                            ? group.name[0].toUpperCase()
                            : 'G',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Name & subject
                Center(
                  child: Text(group.name,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ),
                Center(
                  child: Text(group.subject,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 6),

                // Member count pill
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.people_rounded, size: 14, color: color),
                      const SizedBox(width: 5),
                      Text('${group.memberCount} members',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: color,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Info rows
                _InfoRow(
                    icon: Icons.person_rounded,
                    label: 'Created by',
                    value: group.createdByName),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Created on',
                  value: DateFormat('MMM d, y').format(group.createdAt),
                ),

                // Description
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('About',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary)),
                  const SizedBox(height: 6),
                  Text(group.description,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5)),
                ],

                // Tags
                if (group.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Tags',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: group.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: color.withOpacity(0.2)),
                              ),
                              child: Text('#$t',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: color,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Leave group button (not shown to creator)
                if (!isCreator)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text('Leave Group',
                              style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w700)),
                          content: Text(
                              'Are you sure you want to leave "${group.name}"?',
                              style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textSecondary)),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogCtx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogCtx).pop(true),
                              child: const Text('Leave',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await ref
                            .read(studyGroupServiceProvider)
                            .leaveGroup(group.id, currentUserId);
                        if (mounted) {
                          Navigator.of(context).pop(); // close sheet
                          GoRouter.of(context).go('/study-buddy');
                        }
                      }
                    },
                    icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                    label: const Text('Leave Group'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          ),
        ]),
      ),
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
                  fontSize: 13, color: AppColors.textPrimary)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message bubble
// ─────────────────────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            showAvatar
                ? CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      message.senderName.isNotEmpty
                          ? message.senderName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  )
                : const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe && showAvatar) ...[
                    Text(
                      message.senderName,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      border: isMe ? null : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      message.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeStr,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
