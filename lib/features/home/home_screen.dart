import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import '../random_number/random_number_screen.dart';
import '../team_creator/team_creator_screen.dart';
import '../wheel_spinner/wheel_spinner_screen.dart';
import '../timer_stopwatch/timer_stopwatch_screen.dart';
import '../list_picker/list_picker_screen.dart';
import '../dice_roller/dice_roller_screen.dart';
import '../coin_toss/coin_toss_screen.dart';
import '../password_generator/password_generator_screen.dart';
import '../qr_generator/qr_generator_screen.dart';
import '../rock_paper_scissors/rock_paper_scissors_screen.dart';
import '../magic_8_ball/magic_8_ball_screen.dart';
import '../about/about_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    final features = [
      {'icon': Icons.confirmation_number, 'label': 'Random Number'},
      {'icon': Icons.group, 'label': 'Team Creator'},
      {'icon': Icons.sync, 'label': 'Wheel Spinner'},
      {'icon': Icons.timer, 'label': 'Timer & Stopwatch'},
      {'icon': Icons.list, 'label': 'List Picker'},
      {'icon': Icons.casino_outlined, 'label': 'Dice Roller'},
      {'icon': Icons.monetization_on, 'label': 'Coin Toss'},
      {'icon': Icons.lock, 'label': 'Password Generator'},
      {'icon': Icons.qr_code, 'label': 'QR Generator'},
      {'icon': Icons.gesture, 'label': 'Rock Paper Scissors'},
      {'icon': Icons.circle, 'label': 'Magic 8 Ball'},
      {'icon': Icons.info_outline, 'label': 'About'},
    ];
    
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'KQR',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.isColorfulMode 
                ? Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFF2D3748)
                    : Colors.white
                : null,
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
                    const Color(0xFFE8EAF6),
                  ]
                : [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ],
          ),
        ) : null,
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
              final featureColor = theme.getFeatureColor(feature['label'] as String);
              
            return GestureDetector(
              onTap: () {
                if (index == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RandomNumberScreen()),
                  );
                }
                else if (index == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TeamCreatorScreen()),
                  );
                }
                else if (index == 2) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WheelSpinnerScreen()),
                  );
                }
                else if (index == 3) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TimerStopwatchScreen()),
                  );
                }
                else if (index == 4) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ListPickerScreen()),
                  );
                }
                else if (index == 5) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DiceRollerScreen()),
                  );
                }
                else if (index == 6) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CoinTossScreen()),
                  );
                }
                else if (index == 7) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PasswordGeneratorScreen()),
                  );
                }
                else if (index == 8) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const QrGeneratorScreen()),
                  );
                }
                else if (index == 9) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RockPaperScissorsScreen()),
                  );
                }
                else if (index == 10) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Magic8BallScreen()),
                  );
                }
                else if (index == 11) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                }
                },
                child: Container(
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
                    boxShadow: theme.isColorfulMode ? [
                      BoxShadow(
                        color: featureColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
              child: Card(
                    elevation: theme.isColorfulMode ? 0 : 2,
                    color: theme.isColorfulMode ? Colors.transparent : null,
                shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: theme.isColorfulMode ? BoxDecoration(
                            color: featureColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ) : null,
                          child: Icon(
                            feature['icon'] as IconData, 
                            size: 48,
                            color: featureColor,
                          ),
                        ),
                    const SizedBox(height: 12),
                    Text(
                      feature['label'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.isColorfulMode 
                                ? Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF2D3748)
                                    : Colors.white
                                : null,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                    ),
                ),
              ),
            );
          },
          ),
        ),
      ),
    );
  }
} 