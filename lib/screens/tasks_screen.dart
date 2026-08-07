import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';
import 'add_edit_task_screen.dart';

/// The main Tasks & Smart Reminders screen for Lifemate.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _svc = TaskService.instance;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    await _svc.load();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openAddTask() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
    if (result == true) {
      _loadTasks();
    }
  }

  Future<void> _openEditTask(TaskItem task) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(existingTask: task)),
    );
    if (result == true) {
      _loadTasks();
    }
  }

  Future<void> _toggleTaskComplete(TaskItem task) async {
    await _svc.toggleComplete(task.id);
    _loadTasks();
  }

  Future<void> _confirmDeleteTask(TaskItem task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _svc.delete(task.id);
      _loadTasks();
    }
  }

  //  Build UI 

  @override
  Widget build(BuildContext context) {
    final isRinging = NotificationService.instance.isRinging;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      body: SafeArea(
        child: Column(
          children: [
            // Floating Active Ringing Banner (Allows manual early stop)
            if (isRinging)
              Container(
                width: double.infinity,
                color: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Reminder Ringing...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        NotificationService.instance.stopRinging();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      child: const Text('Stop Ringing'),
                    ),
                  ],
                ),
              ),

            //  Top Header 
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFF59E0B),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Plan today. Remember what matters.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // + Add Task Button
                  ElevatedButton.icon(
                    onPressed: _openAddTask,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),

            //  Filter Tabs 
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFF59E0B),
                labelColor: const Color(0xFFF59E0B),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Done'),
                  Tab(text: 'All'),
                ],
              ),
            ),

            //  Tab Bar Views 
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTaskList(_svc.todayTasks, 'No tasks for today'),
                        _buildTaskList(_svc.upcomingTasks, 'No upcoming tasks'),
                        _buildTaskList(_svc.completedTasks, 'No completed tasks'),
                        _buildTaskList(_svc.all, 'Nothing planned yet'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskItem> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: tasks.length,
      itemBuilder: (ctx, index) {
        final task = tasks[index];
        return _TaskTile(
          task: task,
          onToggleComplete: () => _toggleTaskComplete(task),
          onTap: () => _openEditTask(task),
          onDelete: () => _confirmDeleteTask(task),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a task and let Lifemate remember it for you.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Reusable Task Card Item 

class _TaskTile extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggleComplete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggleComplete,
    required this.onTap,
    required this.onDelete,
  });

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFEF4444);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.low:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Completion Checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),

                const SizedBox(width: 14),

                // Task Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: task.isCompleted
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF1A1A2E),
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),

                      if (task.notes.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.notes,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 6),

                      // Footer Metadata Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Priority Flag
                          Icon(Icons.flag_rounded, size: 14, color: priorityColor),

                          // Overdue Badge
                          if (task.isOverdue)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Overdue',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ),

                          // Due Date text
                          Text(
                            TaskService.formatDate(task.dueDate, task.hasTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: task.isOverdue
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF94A3B8),
                              fontWeight: task.isOverdue
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),

                          // Smart Reminder Badge
                          if (task.reminderEnabled)
                            const Icon(
                              Icons.notifications_active_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),

                          // Ringing Reminder duration badge
                          if (task.reminderEnabled && task.reminderStyle == ReminderStyle.ringing)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Ring ${task.ringDurationSeconds}s',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),

                          // Repeat Badge
                          if (task.repeat != TaskRepeat.never)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.repeat.name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFCBD5E1)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

