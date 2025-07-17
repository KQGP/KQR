import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class PasswordGeneratorScreen extends ConsumerStatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  ConsumerState<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends ConsumerState<PasswordGeneratorScreen> {
  int _length = 12;
  bool _upper = true;
  bool _lower = true;
  bool _digits = true;
  bool _special = true;
  String _password = '';
  final TextEditingController _specialController = TextEditingController(text: '!@#%&*?');

  void _generate() {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    String special = _specialController.text;
    String chars = '';
    if (_upper) chars += upper;
    if (_lower) chars += lower;
    if (_digits) chars += digits;
    if (_special && special.isNotEmpty) chars += special;
    if (chars.isEmpty) {
      setState(() => _password = '');
      return;
    }
    final rng = Random.secure();
    setState(() {
      _password = List.generate(_length, (_) => chars[rng.nextInt(chars.length)]).join();
    });
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: _password));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
  }

  @override
  void dispose() {
    _specialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Password Generator');
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Password Generator',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                            Text(
                              'Length:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.isColorfulMode ? featureColor : null,
                              ),
                            ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _length,
                              underline: const SizedBox(),
                  items: List.generate(29, (i) => i + 4)
                      .map((l) => DropdownMenuItem(value: l, child: Text('$l')))
                      .toList(),
                  onChanged: (v) => setState(() => _length = v ?? 12),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(value: _upper, onChanged: (v) => setState(() => _upper = v ?? true)),
                const Text('Uppercase'),
                Checkbox(value: _lower, onChanged: (v) => setState(() => _lower = v ?? true)),
                const Text('Lowercase'),
              ],
            ),
            Row(
              children: [
                Checkbox(value: _digits, onChanged: (v) => setState(() => _digits = v ?? true)),
                const Text('Digits'),
                Checkbox(value: _special, onChanged: (v) => setState(() => _special = v ?? true)),
                const Text('Special'),
              ],
            ),
            if (_special)
              TextField(
                controller: _specialController,
                            decoration: InputDecoration(
                              labelText: 'Special characters',
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
              // Result
            if (_password.isNotEmpty)
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
                    child: SelectableText(
                      _password,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.isColorfulMode ? featureColor : null,
                              ),
                    ),
                  ),
                  IconButton(
                            icon: Icon(Icons.copy, color: theme.isColorfulMode ? featureColor : null),
                    onPressed: _copy,
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