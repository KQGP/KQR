import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';

class TimerStopwatchScreen extends ConsumerStatefulWidget {
  const TimerStopwatchScreen({super.key});

  @override
  ConsumerState<TimerStopwatchScreen> createState() => _TimerStopwatchScreenState();
}

class _TimerStopwatchScreenState extends ConsumerState<TimerStopwatchScreen> {
  Timer? _timer;
  int _seconds = 0;
  int _timerSeconds = 0;
  bool _isRunning = false;
  bool _isTimerMode = false;
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  Duration _pickerDuration = const Duration();

  @override
  void initState() {
    super.initState();
    _hoursController.text = '0';
    _minutesController.text = '0';
    _secondsController.text = '0';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    if (!_isRunning) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    }
  }

  void _startTimer() {
    if (!_isRunning) {
      _timerSeconds = _pickerDuration.inSeconds;
      
      if (_timerSeconds > 0) {
        _isRunning = true;
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_timerSeconds > 0) {
              _timerSeconds--;
            } else {
              _isRunning = false;
              timer.cancel();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Timer finished!')),
              );
            }
          });
        });
      }
    }
  }

  void _pause() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _seconds = 0;
      _timerSeconds = 0;
    });
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Timer & Stopwatch');
    
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Timer & Stopwatch',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.isColorfulMode ? featureColor : null,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: theme.isColorfulMode ? BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.light
                ? [
                    const Color(0xFFF8F9FF),
                    featureColor.withOpacity(0.05),
                  ]
                : [
                    const Color(0xFF1A1A2E),
                    featureColor.withOpacity(0.1),
                  ],
          ),
        ) : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Mode Toggle Section
              Container(
                padding: const EdgeInsets.all(8), // was 12
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: theme.isColorfulMode ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      featureColor.withOpacity(0.1),
                      featureColor.withOpacity(0.05),
                    ],
                  ) : null,
                  border: theme.isColorfulMode ? Border.all(
                    color: featureColor.withOpacity(0.3),
                    width: 1,
                  ) : null,
                ),
                child: Card(
                  elevation: theme.isColorfulMode ? 0 : 2,
                  color: theme.isColorfulMode ? Colors.transparent : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6), // was 10
                    child: Column(
                      children: [
                        Text(
                          'Mode',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.isColorfulMode ? featureColor : null,
                          ),
                        ),
                        const SizedBox(height: 10), // was 16
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: false, 
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: theme.isColorfulMode ? featureColor : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Stopwatch'),
                                ],
                              ),
                            ),
                            ButtonSegment(
                              value: true, 
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.alarm,
                                    size: 16,
                                    color: theme.isColorfulMode ? featureColor : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Timer'),
                                ],
                              ),
                            ),
                          ],
                          selected: {_isTimerMode},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() {
                              _isTimerMode = newSelection.first;
                              _reset();
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return theme.isColorfulMode ? featureColor : null;
                                }
                                return null;
                              },
                            ),
                            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return theme.isColorfulMode ? Colors.white : null;
                                }
                                return theme.isColorfulMode ? featureColor : null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // was 16
              // Timer Input Section
              if (_isTimerMode) ...[
                Container(
                  padding: const EdgeInsets.all(8), // was 12
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: theme.isColorfulMode ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        featureColor.withOpacity(0.1),
                        featureColor.withOpacity(0.05),
                      ],
                    ) : null,
                    border: theme.isColorfulMode ? Border.all(
                      color: featureColor.withOpacity(0.3),
                      width: 1,
                    ) : null,
                  ),
                  child: Card(
                    elevation: theme.isColorfulMode ? 0 : 2,
                    color: theme.isColorfulMode ? Colors.transparent : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6), // was 10
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set Timer',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.isColorfulMode ? featureColor : null,
                            ),
                          ),
                          const SizedBox(height: 10), // was 16
                          SizedBox(
                            height: 120,
                            child: CupertinoTimerPicker(
                              mode: CupertinoTimerPickerMode.hms,
                              initialTimerDuration: _pickerDuration,
                              onTimerDurationChanged: (duration) {
                                setState(() {
                                  _pickerDuration = duration;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10), // was 16
              ],
              // Time Display Section
              Container(
                padding: const EdgeInsets.all(12), // was 20
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: theme.isColorfulMode ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      featureColor.withOpacity(0.2),
                      featureColor.withOpacity(0.1),
                    ],
                  ) : null,
                  border: theme.isColorfulMode ? Border.all(
                    color: featureColor.withOpacity(0.4),
                    width: 2,
                  ) : null,
                  boxShadow: theme.isColorfulMode ? [
                    BoxShadow(
                      color: featureColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ] : null,
                ),
                child: Card(
                  elevation: theme.isColorfulMode ? 0 : 2,
                  color: theme.isColorfulMode ? Colors.transparent : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8), // was 14
                    child: Column(
                      children: [
                        Icon(
                          _isTimerMode ? Icons.alarm : Icons.timer,
                          size: 48,
                          color: theme.isColorfulMode ? featureColor : null,
                        ),
                        const SizedBox(height: 6), // was 10
                        Text(
                          _formatTime(_isTimerMode ? _timerSeconds : _seconds),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: theme.isColorfulMode 
                                ? Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF2D3748)
                                    : Colors.white
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2), // was 4
                        Text(
                          _isTimerMode ? 'Timer' : 'Stopwatch',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.isColorfulMode ? featureColor : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // was 18
              // Controls Section
              Container(
                padding: const EdgeInsets.all(8), // was 12
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: theme.isColorfulMode ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      featureColor.withOpacity(0.1),
                      featureColor.withOpacity(0.05),
                    ],
                  ) : null,
                  border: theme.isColorfulMode ? Border.all(
                    color: featureColor.withOpacity(0.3),
                    width: 1,
                  ) : null,
                ),
                child: Card(
                  elevation: theme.isColorfulMode ? 0 : 2,
                  color: theme.isColorfulMode ? Colors.transparent : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6), // was 10
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            height: 58, // was 52
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: theme.isColorfulMode && !_isRunning ? LinearGradient(
                                colors: [featureColor, featureColor.withOpacity(0.8)],
                              ) : null,
                              boxShadow: theme.isColorfulMode && !_isRunning ? [
                                BoxShadow(
                                  color: featureColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: ElevatedButton(
                              onPressed: _isRunning ? null : (_isTimerMode ? _startTimer : _startStopwatch),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                                foregroundColor: theme.isColorfulMode ? Colors.white : null,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.play_arrow, size: 20),
                                  const Spacer(),
                                  Text('Start', style: TextStyle(fontSize: 13)),
                                  const Spacer(flex: 2),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // was 10
                        Expanded(
                          child: Container(
                            height: 58, // was 52
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: theme.isColorfulMode && _isRunning ? LinearGradient(
                                colors: [featureColor, featureColor.withOpacity(0.8)],
                              ) : null,
                              boxShadow: theme.isColorfulMode && _isRunning ? [
                                BoxShadow(
                                  color: featureColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: ElevatedButton(
                              onPressed: _isRunning ? _pause : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                                foregroundColor: theme.isColorfulMode ? Colors.white : null,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.pause, size: 20),
                                  const Spacer(),
                                  Text('Pause', style: TextStyle(fontSize: 13)),
                                  const Spacer(flex: 2),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // was 10
                        Expanded(
                          child: Container(
                            height: 58, // was 52
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: theme.isColorfulMode ? LinearGradient(
                                colors: [featureColor.withOpacity(0.5), featureColor.withOpacity(0.3)],
                              ) : null,
                              boxShadow: theme.isColorfulMode ? [
                                BoxShadow(
                                  color: featureColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: ElevatedButton(
                              onPressed: _reset,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                                foregroundColor: theme.isColorfulMode ? featureColor : null,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.refresh, size: 20),
                                  const Spacer(),
                                  Text('Reset', style: TextStyle(fontSize: 13)),
                                  const Spacer(flex: 2),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 