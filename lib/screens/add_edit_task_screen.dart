import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';

/// Screen for creating a new task or editing an existing task.
class AddEditTaskScreen extends StatefulWidget {
  final TaskItem? existingTask;

  const AddEditTaskScreen({super.key, this.existingTask});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(hours: 2));
  bool _hasTime = true;
  TaskPriority _priority = TaskPriority.medium;
  TaskRepeat _repeat = TaskRepeat.never;

  bool _reminderEnabled = false;
  int _reminderOffsetMinutes = 0; // 0, 10, 30, 60
  ReminderStyle _reminderStyle = ReminderStyle.ringing;
  int _ringDurationSeconds = 30; // 30s auto-stop clock alarm

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final task = widget.existingTask!;
      _titleController.text = task.title;
      _notesController.text = task.notes;
      _dueDate = task.dueDate;
      _hasTime = task.hasTime;
      _priority = task.priority;
      _repeat = task.repeat;
      _reminderEnabled = task.reminderEnabled;
      _reminderOffsetMinutes = task.reminderOffsetMinutes;
      _reminderStyle = task.reminderStyle;
      _ringDurationSeconds = task.ringDurationSeconds;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // â”€â”€ Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dueDate.hour,
          _dueDate.minute,
          0,
          0,
          0,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (picked != null) {
      setState(() {
        _hasTime = true;
        _dueDate = DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          picked.hour,
          picked.minute,
          0,
          0,
          0,
        );
      });
    }
  }

  Future<void> _onReminderToggled(bool value) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification permission is required to receive smart task reminders.',
            ),
          ),
        );
      }
    }
    setState(() => _reminderEnabled = value);
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title.')),
      );
      return;
    }

    final service = TaskService.instance;
    final now = DateTime.now();

    if (_isEditing) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        notes: _notesController.text.trim(),
        dueDate: _dueDate,
        hasTime: _hasTime,
        priority: _priority,
        repeat: _repeat,
        reminderEnabled: _reminderEnabled,
        reminderOffsetMinutes: _reminderOffsetMinutes,
        reminderStyle: _reminderStyle,
        ringDurationSeconds: _ringDurationSeconds,
        modifiedAt: now,
      );
      await service.update(updated);
    } else {
      final newTask = TaskItem(
        id: TaskItem.generateId(),
        title: title,
        notes: _notesController.text.trim(),
        dueDate: _dueDate,
        hasTime: _hasTime,
        priority: _priority,
        repeat: _repeat,
        isCompleted: false,
        reminderEnabled: _reminderEnabled,
        reminderOffsetMinutes: _reminderOffsetMinutes,
        reminderStyle: _reminderStyle,
        ringDurationSeconds: _ringDurationSeconds,
        notificationId: TaskItem.generateNotificationId(),
        createdAt: now,
        modifiedAt: now,
      );
      await service.add(newTask);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // â”€â”€ Build UI â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saveTask,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              _buildSectionLabel('Task Title'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                  decoration: const InputDecoration(
                    hintText: 'What needs to be done?',
                    hintStyle: TextStyle(color: Color(0xFFC4C4C4), fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
              ),

              const SizedBox(height: 20),

              // Priority Selector
              _buildSectionLabel('Priority'),
              const SizedBox(height: 8),
              _buildPrioritySelector(),

              const SizedBox(height: 20),

              // Date & Time Picker
              _buildSectionLabel('Due Date & Time'),
              const SizedBox(height: 8),
              _buildDateTimePicker(),

              const SizedBox(height: 20),

              // Reminder Toggle & Option
              _buildSectionLabel('Smart Reminder'),
              const SizedBox(height: 8),
              _buildReminderCard(),

              const SizedBox(height: 20),

              // Repeat Pattern
              _buildSectionLabel('Repeat Pattern'),
              const SizedBox(height: 8),
              _buildRepeatSelector(),

              const SizedBox(height: 20),

              // Notes Input
              _buildSectionLabel('Notes (optional)'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                  decoration: const InputDecoration(
                    hintText: 'Add details or steps...',
                    hintStyle: TextStyle(color: Color(0xFFC4C4C4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Helper Component Builders â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Color(0xFF6B7280),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final priorities = [
      {'val': TaskPriority.low, 'label': 'Low', 'color': const Color(0xFF10B981), 'icon': Icons.flag_outlined},
      {'val': TaskPriority.medium, 'label': 'Medium', 'color': const Color(0xFFF59E0B), 'icon': Icons.flag_outlined},
      {'val': TaskPriority.high, 'label': 'High', 'color': const Color(0xFFEF4444), 'icon': Icons.flag},
    ];

    return Row(
      children: priorities.map((p) {
        final val = p['val'] as TaskPriority;
        final label = p['label'] as String;
        final color = p['color'] as Color;
        final icon = p['icon'] as IconData;
        final selected = _priority == val;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? color.withAlpha(38) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? color : const Color(0xFFE2E8F0),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? color : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 10),
                        Text(
                          TaskService.formatDate(_dueDate, false),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 10),
                        Text(
                          _hasTime
                              ? TimeOfDay.fromDateTime(_dueDate).format(context)
                              : 'Set Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _hasTime ? const Color(0xFF1A1A2E) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    final ringDurations = [3, 5, 10, 15, 30];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: Color(0xFFF59E0B), size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Remind me',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                  ),
                ],
              ),
              Switch(
                value: _reminderEnabled,
                onChanged: _onReminderToggled,
                activeThumbColor: const Color(0xFFF59E0B),
              ),
            ],
          ),

          if (_reminderEnabled) ...[
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Reminder Time Offset Dropdown
            Row(
              children: [
                const Text(
                  'Reminder Time: ',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _reminderOffsetMinutes,
                      isExpanded: true,
                      onChanged: (val) {
                        if (val != null) setState(() => _reminderOffsetMinutes = val);
                      },
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('At task time')),
                        DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                        DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                        DropdownMenuItem(value: 60, child: Text('1 hour before')),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              'Reminder Sound & Alert Style:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),

            // Reminder Sound Style Segmented Tiles
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _reminderStyle = ReminderStyle.ringing),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _reminderStyle == ReminderStyle.ringing
                            ? const Color(0xFFEF4444).withAlpha(31)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _reminderStyle == ReminderStyle.ringing
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFE2E8F0),
                          width: _reminderStyle == ReminderStyle.ringing ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.alarm_on_rounded, size: 22, color: Color(0xFFEF4444)),
                          const SizedBox(height: 4),
                          Text(
                            'â° Ringing Alarm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _reminderStyle == ReminderStyle.ringing
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _reminderStyle == ReminderStyle.ringing
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '30s Full Screen',
                            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _reminderStyle = ReminderStyle.normal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _reminderStyle == ReminderStyle.normal
                            ? const Color(0xFF3B82F6).withAlpha(31)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _reminderStyle == ReminderStyle.normal
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFE2E8F0),
                          width: _reminderStyle == ReminderStyle.normal ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.notifications_active_rounded, size: 22, color: Color(0xFF3B82F6)),
                          const SizedBox(height: 4),
                          Text(
                            'ðŸ”” Normal Chime',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _reminderStyle == ReminderStyle.normal
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _reminderStyle == ReminderStyle.normal
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Standard Chime',
                            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepeatSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskRepeat>(
          value: _repeat,
          isExpanded: true,
          onChanged: (val) {
            if (val != null) setState(() => _repeat = val);
          },
          items: const [
            DropdownMenuItem(value: TaskRepeat.never, child: Text('Never (One-time)')),
            DropdownMenuItem(value: TaskRepeat.daily, child: Text('Daily')),
            DropdownMenuItem(value: TaskRepeat.weekly, child: Text('Weekly')),
            DropdownMenuItem(value: TaskRepeat.monthly, child: Text('Monthly')),
          ],
        ),
      ),
    );
  }
}

