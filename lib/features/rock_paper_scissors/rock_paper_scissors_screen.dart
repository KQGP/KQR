import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';

class RockPaperScissorsScreen extends ConsumerStatefulWidget {
  const RockPaperScissorsScreen({super.key});

  @override
  ConsumerState<RockPaperScissorsScreen> createState() => _RockPaperScissorsScreenState();
}

class _RockPaperScissorsScreenState extends ConsumerState<RockPaperScissorsScreen> with SingleTickerProviderStateMixin {
  String? _playerChoice;
  String? _computerChoice;
  String _result = '';
  int _playerScore = 0;
  int _computerScore = 0;
  int _ties = 0;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final List<String> _choices = ['Rock', 'Paper', 'Scissors'];
  final Map<String, String> _beats = {
    'Rock': 'Scissors',
    'Paper': 'Rock',
    'Scissors': 'Paper',
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _play(String playerChoice) {
    final rng = Random();
    final computerChoice = _choices[rng.nextInt(_choices.length)];
    
    setState(() {
      _playerChoice = playerChoice;
      _computerChoice = computerChoice;
      _result = _determineWinner(playerChoice, computerChoice);
      _animController.forward(from: 0);
    });
  }

  String _determineWinner(String player, String computer) {
    if (player == computer) {
      _ties++;
      return 'Tie!';
    } else if (_beats[player] == computer) {
      _playerScore++;
      return 'You Win!';
    } else {
      _computerScore++;
      return 'Computer Wins!';
    }
  }

  void _reset() {
    setState(() {
      _playerChoice = null;
      _computerChoice = null;
      _result = '';
      _playerScore = 0;
      _computerScore = 0;
      _ties = 0;
    });
  }

  IconData _getChoiceIcon(String choice) {
    switch (choice) {
      case 'Rock':
        return Icons.radio_button_unchecked;
      case 'Paper':
        return Icons.rectangle;
      case 'Scissors':
        return Icons.content_cut;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Rock Paper Scissors');
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Rock, Paper, Scissors',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.isColorfulMode ? featureColor : null,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.isColorfulMode ? featureColor : null),
            onPressed: _reset,
            tooltip: 'Reset Score',
          ),
        ],
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
        child: Column(
          children: [
            // Score Board
              Container(
                padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('You', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$_playerScore', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: theme.isColorfulMode ? featureColor : null)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Ties', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$_ties', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: theme.isColorfulMode ? featureColor : null)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Computer', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('$_computerScore', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: theme.isColorfulMode ? featureColor : null)),
                      ],
                    ),
                  ],
                    ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Game Area
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Computer Choice
                    Text('Computer', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: theme.isColorfulMode ? featureColor : null)),
                  const SizedBox(height: 16),
                  if (_computerChoice != null)
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                            color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(16),
                            border: theme.isColorfulMode ? Border.all(color: featureColor.withOpacity(0.3)) : null,
                        ),
                        child: Icon(
                          _getChoiceIcon(_computerChoice!),
                          size: 64,
                            color: theme.isColorfulMode ? featureColor : Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Result
                  if (_result.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                          color: theme.isColorfulMode
                              ? (_result == 'You Win!'
                                  ? featureColor.withOpacity(0.2)
                                  : _result == 'Computer Wins!'
                                      ? featureColor.withOpacity(0.1)
                                      : featureColor.withOpacity(0.05))
                              : _result == 'You Win!'
                                  ? Colors.green.shade100
                                  : _result == 'Computer Wins!'
                                      ? Colors.red.shade100
                                      : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                          border: theme.isColorfulMode ? Border.all(color: featureColor.withOpacity(0.3)) : null,
                      ),
                      child: Text(
                        _result,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                            color: theme.isColorfulMode ? featureColor : _result == 'You Win!'
                                ? Colors.green.shade800
                                : _result == 'Computer Wins!'
                                    ? Colors.red.shade800
                                    : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Player Choice
                    Text('Your Choice', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: theme.isColorfulMode ? featureColor : null)),
                  const SizedBox(height: 16),
                  if (_playerChoice != null)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                          color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                          border: theme.isColorfulMode ? Border.all(color: featureColor.withOpacity(0.3)) : null,
                      ),
                      child: Icon(
                        _getChoiceIcon(_playerChoice!),
                        size: 64,
                          color: theme.isColorfulMode ? featureColor : Colors.blue,
                      ),
                    ),
                ],
              ),
            ),
            // Choice Buttons
            Wrap(
              spacing: 16,
              runSpacing: 16,
                children: _choices.map((choice) => Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: theme.isColorfulMode ? LinearGradient(
                      colors: [featureColor, featureColor.withOpacity(0.8)],
                    ) : null,
                    boxShadow: theme.isColorfulMode ? [
                      BoxShadow(
                        color: featureColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: ElevatedButton.icon(
                onPressed: () => _play(choice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                      foregroundColor: theme.isColorfulMode ? Colors.white : null,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                icon: Icon(_getChoiceIcon(choice)),
                label: Text(choice),
                ),
              )).toList(),
            ),
          ],
          ),
        ),
      ),
    );
  }
} 