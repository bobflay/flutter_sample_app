import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardTab(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final employee = provider.currentEmployee;
    final activeCheckIn = provider.activeCheckIn;
    final isCheckedIn = provider.isCheckedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          employee?.name.substring(0, 1).toUpperCase() ?? '?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome, ${employee?.name ?? 'Employee'}!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee?.department ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Current date/time
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy')
                                .format(DateTime.now()),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            DateFormat('h:mm a').format(DateTime.now()),
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status card
              Card(
                color: isCheckedIn
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        isCheckedIn
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 48,
                        color: isCheckedIn ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isCheckedIn ? 'Checked In' : 'Not Checked In',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isCheckedIn ? Colors.green : Colors.orange,
                                ),
                      ),
                      if (isCheckedIn && activeCheckIn != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Since ${DateFormat('h:mm a').format(activeCheckIn.checkInTime)}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        _DurationDisplay(startTime: activeCheckIn.checkInTime),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Check-in/out button
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          if (isCheckedIn) {
                            _showCheckOutDialog(context);
                          } else {
                            _showCheckInDialog(context);
                          }
                        },
                  icon: Icon(
                    isCheckedIn ? Icons.logout : Icons.login,
                  ),
                  label: Text(
                    isCheckedIn ? 'Check Out' : 'Check In',
                    style: const TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isCheckedIn ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              // Today's activity
              if (provider.checkInHistory.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Today\'s Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...provider.checkInHistory
                    .where((r) {
                      final today = DateTime.now();
                      return r.checkInTime.year == today.year &&
                          r.checkInTime.month == today.month &&
                          r.checkInTime.day == today.day;
                    })
                    .take(3)
                    .map((record) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              record.isCheckedOut
                                  ? Icons.check_circle_outline
                                  : Icons.access_time,
                              color: record.isCheckedOut
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            title: Text(
                              'Check-in: ${DateFormat('h:mm a').format(record.checkInTime)}',
                            ),
                            subtitle: record.isCheckedOut
                                ? Text(
                                    'Check-out: ${DateFormat('h:mm a').format(record.checkOutTime!)}')
                                : const Text('Currently checked in'),
                            trailing: record.duration != null
                                ? Text(
                                    _formatDuration(record.duration!),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckInDialog(BuildContext context) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Check In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ready to start your day?'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g., Working from office',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppProvider>().checkIn(
                    notes: notesController.text.isNotEmpty
                        ? notesController.text
                        : null,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Check In'),
          ),
        ],
      ),
    );
  }

  void _showCheckOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Check Out'),
        content: const Text('Are you sure you want to check out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppProvider>().checkOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _DurationDisplay extends StatefulWidget {
  final DateTime startTime;

  const _DurationDisplay({required this.startTime});

  @override
  State<_DurationDisplay> createState() => _DurationDisplayState();
}

class _DurationDisplayState extends State<_DurationDisplay> {
  late Duration _duration;

  @override
  void initState() {
    super.initState();
    _updateDuration();
    // Update every minute
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (mounted) {
        _updateDuration();
        return true;
      }
      return false;
    });
  }

  void _updateDuration() {
    setState(() {
      _duration = DateTime.now().difference(widget.startTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hours = _duration.inHours;
    final minutes = _duration.inMinutes.remainder(60);
    return Text(
      'Duration: ${hours}h ${minutes}m',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
    );
  }
}
