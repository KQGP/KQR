import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';

class Magic8BallScreen extends ConsumerStatefulWidget {
  const Magic8BallScreen({super.key});

  @override
  ConsumerState<Magic8BallScreen> createState() => _Magic8BallScreenState();
}

class _Magic8BallScreenState extends ConsumerState<Magic8BallScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  String _answer = '';
  bool _isShaking = false;
  late AnimationController _animController;
  late Animation<double> _shakeAnim;

  final List<String> _answers = [
    'It is certain',
    'It is decidedly so',
    'Without a doubt',
    'Yes, definitely',
    'You may rely on it',
    'As I see it, yes',
    'Most likely',
    'Outlook good',
    'Yes',
    'Signs point to yes',
    'Reply hazy, try again',
    'Ask again later',
    'Better not tell you now',
    'Cannot predict now',
    'Concentrate and ask again',
    'Don\'t count on it',
    'My reply is no',
    'My sources say no',
    'Outlook not so good',
    'Very doubtful',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _questionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _shake() {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ask a question first!')),
      );
      return;
    }

    setState(() {
      _isShaking = true;
      _answer = '';
    });

    _animController.forward(from: 0).then((_) {
      final rng = Random();
      setState(() {
        _answer = _answers[rng.nextInt(_answers.length)];
        _isShaking = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Magic 8 Ball');
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Magic 8 Ball',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Question Input
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
                  padding: const EdgeInsets.all(16),
                  child: TextField(
              controller: _questionController,
                    decoration: InputDecoration(
                labelText: 'Ask your question...',
                hintText: 'Will I succeed?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelStyle: TextStyle(
                        color: theme.isColorfulMode ? featureColor : null,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.isColorfulMode ? featureColor : Colors.blue,
                          width: 2,
                        ),
                      ),
              ),
              maxLines: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Magic 8 Ball
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _shake,
                  child: AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _isShaking ? sin(_shakeAnim.value * 4 * pi) * 0.1 : 0,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.isColorfulMode ? featureColor : Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: theme.isColorfulMode ? featureColor.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.isColorfulMode ? Colors.white : Colors.black,
                              ),
                              child: Center(
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : Colors.white,
                                    border: Border.all(color: theme.isColorfulMode ? featureColor : Colors.black, width: 2),
                                  ),
                                  child: Center(
                                    child: _isShaking
                                        ? Text(
                                            '8',
                                            style: TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: theme.isColorfulMode ? featureColor : Colors.black,
                                            ),
                                          )
                                        : _answer.isNotEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  _answer,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.isColorfulMode ? featureColor : Colors.black,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                '8',
                                                style: TextStyle(
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.isColorfulMode ? featureColor : Colors.black,
                                                ),
                                              ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Instructions
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
                child: Column(
                  children: [
                      Text(
                      'Tap the 8 ball to shake it!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.isColorfulMode ? featureColor : null),
                    ),
                    const SizedBox(height: 8),
                      Container(
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
                      onPressed: _shake,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                            foregroundColor: theme.isColorfulMode ? Colors.white : null,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                      icon: const Icon(Icons.casino),
                      label: const Text('Shake 8 Ball'),
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
    );
  }
} 