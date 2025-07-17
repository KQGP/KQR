import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';

class DiceRollerScreen extends ConsumerStatefulWidget {
  const DiceRollerScreen({super.key});

  @override
  ConsumerState<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends ConsumerState<DiceRollerScreen> with SingleTickerProviderStateMixin {
  int _diceCount = 1;
  int _sides = 6;
  final List<int> _diceTypes = [6, 12, 20];
  List<int> _results = [];
  late AnimationController _animController;
  late Animation<double> _rollAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _rollAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _rollDice() {
    final rng = Random();
    setState(() {
      _results = List.generate(_diceCount, (_) => rng.nextInt(_sides) + 1);
      _animController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Dice Roller');
    
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Dice Roller',
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
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03 + 8,
            vertical: MediaQuery.of(context).size.height * 0.01 + 8,
          ),
          child: ListView(
            children: [
              // Settings Section
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dice Count:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.isColorfulMode 
                                      ? Theme.of(context).brightness == Brightness.light
                                          ? const Color(0xFF2D3748)
                                          : Colors.white
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: theme.isColorfulMode ? Border.all(
                                    color: featureColor.withOpacity(0.3),
                                  ) : null,
                                ),
                                child: DropdownButton<int>(
                                  value: _diceCount,
                                  underline: const SizedBox(),
                                  items: List.generate(9, (i) => i + 1)
                                      .map((q) => DropdownMenuItem(value: q, child: Text('$q')))
                                      .toList(),
                                  onChanged: (v) => setState(() => _diceCount = v ?? 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dice Type:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.isColorfulMode 
                                      ? Theme.of(context).brightness == Brightness.light
                                          ? const Color(0xFF2D3748)
                                          : Colors.white
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: theme.isColorfulMode ? Border.all(
                                    color: featureColor.withOpacity(0.3),
                                  ) : null,
                                ),
                                child: DropdownButton<int>(
                                  value: _sides,
                                  underline: const SizedBox(),
                                  items: [6, 12, 20]
                                      .map((s) => DropdownMenuItem(value: s, child: Text('D$s')))
                                      .toList()
                                    ..add(DropdownMenuItem(value: -1, child: const Text('Custom'))),
                                  onChanged: (v) {
                                    if (v == -1) {
                                      _showCustomSidesDialog();
                                    } else {
                                      setState(() => _sides = v ?? 6);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              
              // Roll Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
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
                child: ElevatedButton(
                  onPressed: _rollDice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                    foregroundColor: theme.isColorfulMode ? Colors.white : null,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Roll Dice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              
              // Results Section
              if (_results.isNotEmpty)
                ScaleTransition(
                  scale: _rollAnim,
                  child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Roll Results',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.isColorfulMode ? featureColor : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                alignment: WrapAlignment.center,
                                children: _results
                                    .map((n) => _DiceFace(
                                      number: n, 
                                      sides: _sides,
                                      featureColor: featureColor,
                                      isColorfulMode: theme.isColorfulMode,
                                    ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
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

  void _showCustomSidesDialog() async {
    final controller = TextEditingController(text: '6');
    final theme = ref.read(themeProvider);
    final featureColor = theme.getFeatureColor('Dice Roller');
    
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.isColorfulMode 
            ? Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF8F9FF)
                : const Color(0xFF1A1A2E)
            : null,
        title: Text(
          'Custom Dice Sides',
          style: TextStyle(
            color: theme.isColorfulMode ? featureColor : null,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Number of sides',
            labelStyle: TextStyle(
              color: theme.isColorfulMode ? featureColor : null,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.isColorfulMode ? featureColor : Colors.blue,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: featureColor,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final sides = int.tryParse(controller.text) ?? 6;
              Navigator.of(context).pop(sides);
            },
            style: TextButton.styleFrom(
              foregroundColor: featureColor,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null && result > 1) {
      setState(() => _sides = result);
    }
  }
}

class _DiceFace extends StatelessWidget {
  final int number;
  final int sides;
  final Color featureColor;
  final bool isColorfulMode;
  
  const _DiceFace({
    required this.number, 
    required this.sides,
    required this.featureColor,
    required this.isColorfulMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isColorfulMode 
            ? featureColor.withOpacity(0.1)
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isColorfulMode ? featureColor : Theme.of(context).colorScheme.primary, 
          width: 2,
        ),
        boxShadow: isColorfulMode ? [
          BoxShadow(
            color: featureColor.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 24, 
          fontWeight: FontWeight.bold,
          color: isColorfulMode ? featureColor : null,
        ),
      ),
    );
  }
} 