import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment_model.dart';
import '../providers/assignment_provider.dart';
import '../providers/theme_provider.dart';
import 'setting_screen.dart'; // Ensure this matches your file path

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0, // Prevents Material 3 scroll shadow
        title: Text(
          'Academic Manager',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AssignmentProvider>(
        builder: (context, provider, child) {
          final urgentTasks = provider.pendingAssignments.where((a) => a.isUrgent).toList();
          final focusTodayTasks = provider.pendingAssignments.where((a) => a.priority == 'High' || a.isUrgent).toList();
          final backlogTasks = [
            ...provider.pendingAssignments.where((a) => a.priority != 'High' && !a.isUrgent),
            ...provider.completedAssignments,
          ];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. DYNAMIC EMERGENCY BANNER (Pill shaped, no shadow)
                if (urgentTasks.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(32), // Cozy Earth soft shape
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.onPrimary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You have ${urgentTasks.length} urgent task(s) due within 48 hours.',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 2. SLIDING TAB BAR SELECTOR
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent, // Clean flat look
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    tabs: const [
                      Tab(text: 'FOCUS TODAY'),
                      Tab(text: 'BACKLOG'),
                    ],
                  ),
                ),

                // 3. TASK LIST HEADER
                Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Daily Workflow',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. TASK VIEW GRID/LIST AREAS
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTaskGrid(focusTodayTasks, provider, theme),
                      _buildTaskGrid(backlogTasks, provider, theme),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // FLOATING ACTION BUTTON (Flat, Pill-shaped)
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_add_task_fab',
        backgroundColor: theme.colorScheme.primary,
        elevation: 0, // Cozy Earth Flat UI
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        onPressed: () => _showAddAssignmentSheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // WIDGET BUILDER: Renders flat, 32px rounded containers mapped from state
  Widget _buildTaskGrid(
      List<Assignment> tasks,
      AssignmentProvider provider,
      ThemeData theme,
      ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'All clean! No tasks here.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      padding: const EdgeInsets.only(bottom: 100, top: 8), // Padding for FAB
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: task.isCompleted ? theme.scaffoldBackgroundColor : theme.cardColor,
            borderRadius: BorderRadius.circular(32), // 2rem radius from DESIGN.md
            border: Border.all(
              color: task.isCompleted
                  ? theme.colorScheme.onSurface.withOpacity(0.1)
                  : theme.colorScheme.onSurface.withOpacity(0.05),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            key: ValueKey(task.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom Flat Checkbox
                          GestureDetector(
                            onTap: () => provider.toggleCompletion(task),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(top: 2, right: 16),
                              decoration: BoxDecoration(
                                color: task.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: task.isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: task.isCompleted
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: task.isCompleted ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5) : theme.colorScheme.onSurface,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                              child: Text(task.title),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPriorityBadge(task.priority, theme),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0), // Align with text
                  child: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: task.isCompleted ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5) : theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Horizontal linear subtask progress indicator bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: task.progressPercentage,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      task.isCompleted ? theme.colorScheme.onSurfaceVariant.withOpacity(0.3) : theme.colorScheme.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: task.isCompleted ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5) : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd').format(task.dueDate),
                          style: TextStyle(
                            color: task.isCompleted ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5) : theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
                      onPressed: () => provider.deleteAssignment(task),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityBadge(String priority, ThemeData theme) {
    Color bg = theme.colorScheme.secondaryContainer;
    Color text = theme.colorScheme.onSecondaryContainer;

    if (priority == 'High') {
      bg = theme.colorScheme.errorContainer;
      text = theme.colorScheme.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // BOTTOM SHEET DIALOG - Cozy Earth styled inputs
  void _showAddAssignmentSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedPriority = 'Medium';
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 36));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final theme = Theme.of(context);
            // 16px radius for etched flat inputs
            final inputBorder = OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3), width: 1),
            );
            final focusedBorder = OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 32,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Assignment',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      filled: true,
                      fillColor: theme.cardColor,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: theme.cardColor,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: focusedBorder,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Due Date:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Priority:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPriority,
                            icon: Icon(Icons.expand_more, color: theme.colorScheme.primary),
                            items: ['Low', 'Medium', 'High']
                                .map((p) => DropdownMenuItem(value: p, child: Text(p, style: TextStyle(color: theme.colorScheme.onSurface))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedPriority = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          final newTask = Assignment(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text,
                            description: descController.text,
                            dueDate: selectedDate,
                            priority: selectedPriority,
                            category: 'Assignment',
                          );
                          Provider.of<AssignmentProvider>(
                            context,
                            listen: false,
                          ).addAssignment(newTask);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Save Task',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}