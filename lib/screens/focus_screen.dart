import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/assignment_model.dart';
import '../providers/assignment_provider.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Assignment? _selectedAssignment;
  final TextEditingController _subTaskController = TextEditingController();

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _handleSessionCompletion();
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _countdownTimer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() => _secondsRemaining = 25 * 60);
  }

  void _handleSessionCompletion() {
    _countdownTimer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = 25 * 60;
    });

    if (_selectedAssignment != null) {
      Provider.of<AssignmentProvider>(context, listen: false)
          .incrementFocusSession(_selectedAssignment!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🍅 Focus milestone saved for "${_selectedAssignment!.title}"!'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  String _formatTimeDisplay() {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _subTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AssignmentProvider>(context);
    final activeTasks = provider.pendingAssignments;

    bool isValidSelection = activeTasks.any((t) => t.id == _selectedAssignment?.id);
    Assignment? dropdownValue = isValidSelection ? _selectedAssignment : null;

    double progressRatio = _secondsRemaining / (25 * 60);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'EduCalm Focus',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: theme.colorScheme.primary),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            // DYNAMIC PROJECT DROPDOWN
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Assignment>(
                  value: dropdownValue,
                  isExpanded: true,
                  icon: Icon(Icons.expand_more, color: theme.colorScheme.primary),
                  hint: Text('Select assignment to lock focus...', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  dropdownColor: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  items: activeTasks.map((task) {
                    return DropdownMenuItem<Assignment>(
                      value: task,
                      child: Text(task.title, style: TextStyle(color: theme.colorScheme.onSurface)),
                    );
                  }).toList(),
                  onChanged: (Assignment? newSelection) {
                    setState(() {
                      _selectedAssignment = newSelection;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 720) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _buildTimerFrame(theme, progressRatio)),
                      const SizedBox(width: 24),
                      Expanded(flex: 7, child: _buildMicroTaskBreakdown(theme, provider, dropdownValue)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildTimerFrame(theme, progressRatio),
                      const SizedBox(height: 24),
                      _buildMicroTaskBreakdown(theme, provider, dropdownValue),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // CORE MODULE 1: POMODORO CLOCK WRAPPER
  Widget _buildTimerFrame(ThemeData theme, double ratio) {
    int sessionCount = _selectedAssignment?.completedFocusSessions ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Focus Session', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ),
          const SizedBox(height: 32),
          // RADIAL ARC
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 4, // From DESIGN.md
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1), // From DESIGN.md
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimeDisplay(),
                    style: TextStyle(fontSize: 56, fontWeight: FontWeight.w300, color: theme.colorScheme.primary, letterSpacing: -1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRunning ? 'DEEP WORK' : 'READY',
                    style: TextStyle(fontSize: 12, letterSpacing: 2.0, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),
          // ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.restart_alt),
                color: theme.colorScheme.onSurfaceVariant,
                onPressed: _resetTimer,
              ),
              const SizedBox(width: 24),
              FloatingActionButton(
                heroTag: 'focus_timer_fab',
                elevation: 0,
                highlightElevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                backgroundColor: theme.colorScheme.primary,
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // REWARDS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sessions: ', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
              ...List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                      Icons.coffee,
                      size: 18,
                      color: index < sessionCount ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.15)
                  ),
                );
              }),
              if (sessionCount > 5)
                Text(' +${sessionCount - 5}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                ),
            ],
          )
        ],
      ),
    );
  }

  // CORE MODULE 2: SUBTASK INJECTION GENERATOR CONTROL VIEW
  Widget _buildMicroTaskBreakdown(ThemeData theme, AssignmentProvider provider, Assignment? task) {
    if (task == null) {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
        ),
        padding: const EdgeInsets.all(32.0),
        child: Center(
            child: Text(
              'Create an assignment first from the dashboard to enable micro-tasks ☕',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
            )
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Micro-task Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16)
                ),
                child: Text(
                    task.category.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer, letterSpacing: 0.5)
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          task.subTasks.isEmpty
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text('No micro-tasks defined for this object.', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: task.subTasks.length,
            itemBuilder: (context, idx) {
              bool isChecked = task.subTaskStatus[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => provider.toggleSubTask(task, idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: isChecked ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isChecked ? theme.colorScheme.primary : theme.colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        task.subTasks[idx],
                        style: TextStyle(
                          fontSize: 16,
                          color: isChecked ? theme.colorScheme.onSurfaceVariant.withOpacity(0.5) : theme.colorScheme.onSurface,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          decorationColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          // FLAT INPUT FIELD
          TextField(
            controller: _subTaskController,
            decoration: InputDecoration(
              hintText: 'Add a sub-task...',
              hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor, // Creates the etched look inside a card
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.keyboard_return_outlined, size: 20),
                color: theme.colorScheme.primary,
                onPressed: () {
                  if (_subTaskController.text.isNotEmpty) {
                    provider.addSubTask(task, _subTaskController.text);
                    _subTaskController.clear();
                  }
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                provider.addSubTask(task, value);
                _subTaskController.clear();
              }
            },
          ),
          const SizedBox(height: 32),
          // CONTEXT INSIGHT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                left: BorderSide(color: theme.colorScheme.primary, width: 4),
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              '"Break each challenge into tasks so small they feel impossible to fail."',
              style: TextStyle(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5),
            ),
          )
        ],
      ),
    );
  }
}