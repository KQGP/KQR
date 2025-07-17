import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';

class RandomNumberScreen extends ConsumerStatefulWidget {
  const RandomNumberScreen({super.key});

  @override
  ConsumerState<RandomNumberScreen> createState() => _RandomNumberScreenState();
}

class _RandomNumberScreenState extends ConsumerState<RandomNumberScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(text: '100');
  final TextEditingController _excludeController = TextEditingController();
  int _quantity = 1;
  bool _unique = true;
  List<int> _results = [];
  List<List<int>> _history = [];
  Set<int> _pickedUniques = {};
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _excludeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _generate() {
    final min = int.tryParse(_minController.text) ?? 1;
    final max = int.tryParse(_maxController.text) ?? 100;
    final exclude = _excludeController.text
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet();
    final available = <int>[];
    for (var i = min; i <= max; i++) {
      if (!exclude.contains(i)) available.add(i);
    }
    if (available.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final rng = Random();
    List<int> result = [];
    if (_unique) {
      // Remove already picked uniques
      final uniqueAvailable = available.where((n) => !_pickedUniques.contains(n)).toList();
      if (uniqueAvailable.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All unique numbers have been picked. Please reset.')),
        );
        return;
      }
      if (_quantity > uniqueAvailable.length) {
        result = List.from(uniqueAvailable);
        result.shuffle(rng);
      } else {
        result = List.from(uniqueAvailable);
        result.shuffle(rng);
        result = result.take(_quantity).toList();
      }
      _pickedUniques.addAll(result);
    } else {
      for (int i = 0; i < _quantity; i++) {
        result.add(available[rng.nextInt(available.length)]);
      }
    }
    setState(() {
      _results = result;
      _history.insert(0, List.from(result));
      _animController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Random Number');
    
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Random Number Generator',
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
              // Input Section
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
                    child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Min',
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Max',
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
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                            Text(
                              'Quantity:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.isColorfulMode 
                                    ? Theme.of(context).brightness == Brightness.light
                                        ? const Color(0xFF2D3748)
                                        : Colors.white
                                    : null,
                              ),
                            ),
                const SizedBox(width: 8),
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
                  value: _quantity,
                                underline: const SizedBox(),
                  items: List.generate(9, (i) => i + 1)
                      .map((q) => DropdownMenuItem(value: q, child: Text('$q')))
                      .toList(),
                  onChanged: (v) => setState(() => _quantity = v ?? 1),
                              ),
                ),
                const Spacer(),
                Switch(
                  value: _unique,
                  onChanged: (v) => setState(() => _unique = v),
                              activeColor: featureColor,
                              activeTrackColor: featureColor.withOpacity(0.3),
                ),
                            Text(
                              'Unique',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.isColorfulMode 
                                    ? Theme.of(context).brightness == Brightness.light
                                        ? const Color(0xFF2D3748)
                                        : Colors.white
                                    : null,
                              ),
                            ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _excludeController,
                          decoration: InputDecoration(
                labelText: 'Exclude (comma separated)',
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Generate Button
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
              onPressed: _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                    foregroundColor: theme.isColorfulMode ? Colors.white : null,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Generate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ),
            const SizedBox(height: 32),
              
              // Results Section
            if (_results.isNotEmpty)
              ScaleTransition(
                scale: _scaleAnim,
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
                              'Generated Numbers',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.isColorfulMode ? featureColor : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                  spacing: 12,
                              runSpacing: 8,
                  children: _results
                                  .map((n) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : null,
                                      borderRadius: BorderRadius.circular(20),
                                      border: theme.isColorfulMode ? Border.all(
                                        color: featureColor.withOpacity(0.3),
                                      ) : null,
                                    ),
                                    child: Text(
                                      '$n',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.isColorfulMode ? featureColor : null,
                                      ),
                                    ),
                                  ))
                      .toList(),
                ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ),
            const SizedBox(height: 24),
              
              // History Section
            if (_history.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: theme.isColorfulMode ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        featureColor.withOpacity(0.05),
                        featureColor.withOpacity(0.02),
                      ],
                    ) : null,
                    border: theme.isColorfulMode ? Border.all(
                      color: featureColor.withOpacity(0.2),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                              Text(
                                'History',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.isColorfulMode ? featureColor : null,
                                ),
                              ),
                  TextButton(
                    onPressed: () => setState(() {
                      _pickedUniques.clear();
                      _history.clear();
                    }),
                                style: TextButton.styleFrom(
                                  foregroundColor: featureColor,
                                ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
                          const SizedBox(height: 16),
              Column(
                children: _history
                    .map((h) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Wrap(
                            spacing: 8,
                                        runSpacing: 4,
                                        children: h.map((n) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: theme.isColorfulMode ? featureColor.withOpacity(0.05) : null,
                                            borderRadius: BorderRadius.circular(16),
                                            border: theme.isColorfulMode ? Border.all(
                                              color: featureColor.withOpacity(0.2),
                                            ) : null,
                                          ),
                                          child: Text(
                                            '$n',
                                            style: TextStyle(
                                              color: theme.isColorfulMode ? featureColor.withOpacity(0.8) : null,
                                            ),
                                          ),
                                        )).toList(),
                          ),
                        ))
                    .toList(),
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