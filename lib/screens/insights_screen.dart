import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assignment_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AssignmentProvider>(context);

    final allAssignments = provider.assignments;
    final totalTasksCount = allAssignments.length;
    final completedTasksCount = allAssignments.where((a) => a.isCompleted).toList().length;

    int efficiencyRate = 0;
    if (totalTasksCount > 0) {
      efficiencyRate = ((completedTasksCount / totalTasksCount) * 100).round();
    }

    int totalFocusSessionsAccumulated = 0;
    for (var assignment in allAssignments) {
      totalFocusSessionsAccumulated += assignment.completedFocusSessions;
    }
    int totalMinutes = totalFocusSessionsAccumulated * 25;
    int displayedHours = totalMinutes ~/ 60;
    int displayedMinutes = totalMinutes % 60;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'EduCalm Insights',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Insights',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Synthesizing your academic progress through organic rhythms.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16),
            ),
            const SizedBox(height: 32),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 650) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 6, child: _buildDonutGaugeCard(theme, efficiencyRate)),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildMetricSidebarCard(
                              theme,
                              title: 'Total Focused Hours',
                              value: '${displayedHours}h ${displayedMinutes}m',
                              subtitle: 'Accumulated flow metric',
                              icon: Icons.timer_outlined,
                              borderColor: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            _buildMetricSidebarCard(
                              theme,
                              title: 'Deadlines Defeated',
                              value: '$completedTasksCount / $totalTasksCount',
                              subtitle: totalTasksCount > 0 ? 'Keep dropping your pending queue!' : 'No tasks assigned yet.',
                              icon: Icons.emoji_events_outlined,
                              borderColor: theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDonutGaugeCard(theme, efficiencyRate),
                      const SizedBox(height: 24),
                      _buildMetricSidebarCard(
                        theme,
                        title: 'Total Focused Hours',
                        value: '${displayedHours}h ${displayedMinutes}m',
                        subtitle: 'Accumulated flow metric',
                        icon: Icons.timer_outlined,
                        borderColor: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      _buildMetricSidebarCard(
                        theme,
                        title: 'Deadlines Defeated',
                        value: '$completedTasksCount / $totalTasksCount',
                        subtitle: totalTasksCount > 0 ? 'Keep dropping your pending queue!' : 'No tasks assigned yet.',
                        icon: Icons.emoji_events_outlined,
                        borderColor: theme.colorScheme.secondary,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            _buildWeeklyHistogramSection(theme, totalFocusSessionsAccumulated),
            const SizedBox(height: 24),

            // DECORATIVE FOOTER
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32), // Deep corner radius
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1506784983877-45594efa4cbe?w=800'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '"The rhythm of the work is the work itself."',
                  style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 18, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 48), // Bottom safe area space
          ],
        ),
      ),
    );
  }

  // FLAT CARD COMPONENT
  Widget _buildDonutGaugeCard(ThemeData theme, int efficiency) {
    double progressArcSweepFraction = efficiency / 100;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: progressArcSweepFraction == 0 ? 0.01 : progressArcSweepFraction,
                  strokeWidth: 16,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  strokeCap: StrokeCap.round, // Softer aesthetics
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EFFICIENCY',
                    style: TextStyle(fontSize: 12, letterSpacing: 2.0, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$efficiency%',
                    style: TextStyle(fontSize: 56, fontWeight: FontWeight.w300, color: theme.colorScheme.primary, letterSpacing: -2.0),
                  ),
                  Text(
                    efficiency >= 75 ? 'Flow State Active' : 'Building Rhythm',
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24, // Horizontal space between the two items
            runSpacing: 12, // Vertical space if it drops to a new line
            children: [
              Row(
                mainAxisSize: MainAxisSize.min, // Keep icon and text tightly together
                children: [
                  Icon(Icons.lens, size: 12, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Productive Hours', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min, // Keep icon and text tightly together
                children: [
                  Icon(Icons.lens, size: 12, color: theme.colorScheme.primary.withOpacity(0.1)),
                  const SizedBox(width: 8),
                  Text('Reflection Time', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  // FLAT SIDEBAR METRICS
  Widget _buildMetricSidebarCard(
      ThemeData theme, {
        required String title,
        required String value,
        required String subtitle,
        required IconData icon,
        required Color borderColor,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              Icon(icon, color: borderColor, size: 24),
            ],
          ),
          const SizedBox(height: 24),
          Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: -1.0)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }

  // HISTOGRAM
  Widget _buildWeeklyHistogramSection(ThemeData theme, int activeSessionsCount) {
    final List<double> chartHeightPercentages = [0.40, 0.65, 0.85, 0.55, 0.75, 0.30, 0.20];
    final List<String> weekDaysLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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
            crossAxisAlignment: CrossAxisAlignment.start, // Align to top in case text wraps
            children: [
              // 1. ADD EXPANDED HERE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly Session Rhythm', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Completed academic cycles per day',
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12), // Buffer space
              // 2. THE BUTTON STAYS THE SAME
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Text('Last 7 Days', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 40),
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                double scalingMultiplier = chartHeightPercentages[index];
                if (index == 2 && activeSessionsCount > 0) scalingMultiplier = 0.95;
                bool isToday = index == 2; // Mocking wednesday as today

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          heightFactor: scalingMultiplier,
                          widthFactor: 0.6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isToday ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16), // Pill shaped bars
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        weekDaysLabels[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}