import 'package:flutter/material.dart';

import '../../Models/AdminUser.dart';

class SendMessageDialog extends StatefulWidget {
  final AdminUser user;

  const SendMessageDialog({Key? key, required this.user}) : super(key: key);

  @override
  State<SendMessageDialog> createState() => _SendMessageDialogState();
}

class _SendMessageDialogState extends State<SendMessageDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _messageCtrl = TextEditingController();
  late AnimationController _animController;

  List<GroupModel> _groups = [];
  List<GroupModel> _selectedGroups = [];
  bool _loadingGroups = true;
  bool _isSending = false;
  bool _selectAll = false;
  final AdminApi api = AdminApi();
  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadGroups();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await api.getGroups(widget.user.id);
      if (mounted) {
        setState(() {
          _groups = groups;
          _loadingGroups = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingGroups = false);
        _showErrorSnackBar('فشل تحميل المجموعات');
      }
    }
  }

  Future<void> _handleSend() async {
    if (_selectedGroups.isEmpty || _messageCtrl.text.trim().isEmpty) {
      _showErrorSnackBar('اختر مجموعة واحدة على الأقل واكتب رسالة');
      return;
    }

    setState(() => _isSending = true);

    try {
      await api.sendMessagesWithRandomDelay(
        userId: widget.user.id,
        groupIds: _selectedGroups.map((e) => e.id).toList(),
        message: _messageCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar('تم إرسال الرسالة بنجاح ✓');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _showErrorSnackBar('فشل إرسال الرسالة');
      }
    }
  }

  void _toggleGroupSelection(GroupModel group) {
    setState(() {
      if (_selectedGroups.contains(group)) {
        _selectedGroups.remove(group);
      } else {
        _selectedGroups.add(group);
      }
      _selectAll = _selectedGroups.length == _groups.length;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedGroups = List.from(_groups);
      } else {
        _selectedGroups.clear();
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      contentPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.white,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(user: widget.user),
            Flexible(
              child: _DialogBody(
                loadingGroups: _loadingGroups,
                groups: _groups,
                selectedGroups: _selectedGroups,
                messageController: _messageCtrl,
                selectAll: _selectAll,
                onGroupToggle: _toggleGroupSelection,
                onSelectAllToggle: _toggleSelectAll,
                animation: _animController,
              ),
            ),
            _DialogFooter(
              isSending: _isSending,
              selectedCount: _selectedGroups.length,
              onCancel: () => Navigator.pop(context),
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}
class _DialogHeader extends StatelessWidget {
  final AdminUser user;

  const _DialogHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade500,
            Colors.blue.shade700,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'send_icon',
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إرسال رسالة جماعية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'المرسل: ${user.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
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

// ===== Dialog Body Component =====
class _DialogBody extends StatelessWidget {
  final bool loadingGroups;
  final List<GroupModel> groups;
  final List<GroupModel> selectedGroups;
  final TextEditingController messageController;
  final bool selectAll;
  final Function(GroupModel) onGroupToggle;
  final VoidCallback onSelectAllToggle;
  final AnimationController animation;

  const _DialogBody({
    required this.loadingGroups,
    required this.groups,
    required this.selectedGroups,
    required this.messageController,
    required this.selectAll,
    required this.onGroupToggle,
    required this.onSelectAllToggle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupsSection(
            loadingGroups: loadingGroups,
            groups: groups,
            selectedGroups: selectedGroups,
            selectAll: selectAll,
            onGroupToggle: onGroupToggle,
            onSelectAllToggle: onSelectAllToggle,
            animation: animation,
          ),
          const SizedBox(height: 28),
          _MessageSection(controller: messageController),
        ],
      ),
    );
  }
}
class _GroupsSection extends StatelessWidget {
  final bool loadingGroups;
  final List<GroupModel> groups;
  final List<GroupModel> selectedGroups;
  final bool selectAll;
  final Function(GroupModel) onGroupToggle;
  final VoidCallback onSelectAllToggle;
  final AnimationController animation;

  const _GroupsSection({
    required this.loadingGroups,
    required this.groups,
    required this.selectedGroups,
    required this.selectAll,
    required this.onGroupToggle,
    required this.onSelectAllToggle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.groups_rounded,
                color: Colors.blue.shade700,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'المجموعات المستهدفة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (!loadingGroups && groups.isNotEmpty)
              _SelectAllButton(
                selectAll: selectAll,
                onTap: onSelectAllToggle,
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (loadingGroups)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحميل المجموعات...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 320),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade50.withOpacity(0.5),
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedGroups.isNotEmpty
                        ? Colors.blue.shade300
                        : Colors.grey.shade200,
                    width: selectedGroups.isNotEmpty ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: selectedGroups.isNotEmpty
                          ? Colors.blue.shade100.withOpacity(0.5)
                          : Colors.grey.shade100,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _GroupsHeader(selectedCount: selectedGroups.length),
                    if (groups.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد مجموعات متاحة',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            final isSelected = selectedGroups.contains(group);

                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 300 + (index * 50)),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _GroupTile(
                                group: group,
                                isSelected: isSelected,
                                onTap: () => onGroupToggle(group),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
class _SelectAllButton extends StatelessWidget {
  final bool selectAll;
  final VoidCallback onTap;

  const _SelectAllButton({
    required this.selectAll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selectAll ? Colors.blue.shade600 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectAll ? Colors.blue.shade700 : Colors.blue.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectAll ? Icons.check_circle : Icons.check_circle_outline,
                size: 18,
                color: selectAll ? Colors.white : Colors.blue.shade700,
              ),
              const SizedBox(width: 6),
              Text(
                selectAll ? 'إلغاء الكل' : 'اختيار الكل',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selectAll ? Colors.white : Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Groups Header =====
class _GroupsHeader extends StatelessWidget {
  final int selectedCount;

  const _GroupsHeader({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: selectedCount > 0
            ? LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade500,
          ],
        )
            : null,
        color: selectedCount == 0 ? Colors.grey.shade50 : null,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: selectedCount > 0
                ? Container(
              key: const ValueKey('selected'),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 18,
              ),
            )
                : Icon(
              key: const ValueKey('unselected'),
              Icons.checklist_rounded,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selectedCount > 0 ? Colors.white : Colors.grey.shade700,
              ),
              child: Text(
                selectedCount > 0
                    ? 'تم اختيار $selectedCount مجموعة'
                    : 'اختر المجموعات المستهدفة',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Group Tile =====
class _GroupTile extends StatelessWidget {
  final GroupModel group;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupTile({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.blue.shade50
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Colors.blue.shade300
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade600 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.people_rounded,
                              size: 13,
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${group.participantCount} عضو',
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Message Section =====
class _MessageSection extends StatelessWidget {
  final TextEditingController controller;

  const _MessageSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                color: Colors.blue.shade700,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'نص الرسالة',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade50,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: 5,
            maxLength: 500,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب رسالتك هنا...\nسيتم إرسالها إلى جميع المجموعات المحددة',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                height: 1.5,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
              ),
              counterStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
        ),
      ],
    );
  }
}

// ===== Dialog Footer =====
class _DialogFooter extends StatelessWidget {
  final bool isSending;
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  const _DialogFooter({
    required this.isSending,
    required this.selectedCount,
    required this.onCancel,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isSending ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: isSending
                      ? [Colors.grey.shade400, Colors.grey.shade400]
                      : [Colors.blue.shade600, Colors.blue.shade700],
                ),
                boxShadow: isSending
                    ? null
                    : [
                  BoxShadow(
                    color: Colors.blue.shade300.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isSending ? null : onSend,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                ),
                child: isSending
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 20,color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      selectedCount > 0
                          ? 'إرسال إلى $selectedCount مجموعة'
                          : 'إرسال الآن',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );}}