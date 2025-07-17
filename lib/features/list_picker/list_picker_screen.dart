import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';

class ListPickerScreen extends ConsumerStatefulWidget {
  const ListPickerScreen({super.key});

  @override
  ConsumerState<ListPickerScreen> createState() => _ListPickerScreenState();
}

class _ListPickerScreenState extends ConsumerState<ListPickerScreen> {
  final TextEditingController _itemController = TextEditingController();
  final List<String> _items = [];
  final List<String> _results = [];
  int _pickCount = 1;
  List<String> _drawStack = [];

  void _addItem() {
    final text = _itemController.text.trim();
    if (text.isNotEmpty && !_items.contains(text)) {
      setState(() {
        _items.add(text);
        _itemController.clear();
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _pickRandom() {
    if (_items.isEmpty) return;
    final rng = Random();
    final pool = List<String>.from(_items);
    pool.shuffle(rng);
    setState(() {
      _results.clear();
      _results.addAll(pool.take(_pickCount));
    });
  }

  void _shuffleList() {
    setState(() {
      _items.shuffle(Random());
    });
  }

  void _drawSequential() {
    if (_drawStack.isEmpty) {
      _drawStack = List<String>.from(_items);
      _drawStack.shuffle(Random());
    }
    if (_drawStack.isNotEmpty) {
      setState(() {
        _results.clear();
        _results.add(_drawStack.removeLast());
      });
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('List Picker');
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'List Picker',
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
          children: [
              // Add Item Section
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
                  child: TextField(
                    controller: _itemController,
                            decoration: InputDecoration(
                              labelText: 'Add item',
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
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.isColorfulMode ? featureColor : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              color: theme.isColorfulMode ? Colors.white : null,
                            ),
                  onPressed: _addItem,
                          ),
                ),
              ],
                    ),
                  ),
                ),
            ),
              const SizedBox(height: 16),
              // Pick Widget (moved up)
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
                    child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                        Text(
                          'Pick:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.isColorfulMode 
                                ? Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF2D3748)
                                    : Colors.white
                                : null,
                          ),
                        ),
                DropdownButton<int>(
                  value: _pickCount,
                          underline: const SizedBox(),
                  items: List.generate(_items.length.clamp(1, 9), (i) => i + 1)
                      .map((q) => DropdownMenuItem(value: q, child: Text('$q')))
                      .toList(),
                  onChanged: (v) => setState(() => _pickCount = v ?? 1),
                ),
                        Container(
                          height: 40,
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
                          child: ElevatedButton(
                  onPressed: _pickRandom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                              foregroundColor: theme.isColorfulMode ? Colors.white : null,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                  child: const Text('Pick Random'),
                ),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: theme.isColorfulMode ? LinearGradient(
                              colors: [featureColor.withOpacity(0.7), featureColor.withOpacity(0.5)],
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
                  onPressed: _shuffleList,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                              foregroundColor: theme.isColorfulMode ? Colors.white : null,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                  child: const Text('Shuffle'),
                ),
                        ),
                        Container(
                          height: 40,
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
                  onPressed: _drawSequential,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                              foregroundColor: theme.isColorfulMode ? Colors.white : null,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                  child: const Text('Draw'),
                          ),
                ),
              ],
                    ),
                  ),
                ),
            ),
              const SizedBox(height: 16),
              // Items List
            Expanded(
                child: Container(
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
              child: ListView.builder(
                itemCount: _items.length,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.isColorfulMode ? featureColor.withOpacity(0.05) : null,
                          border: theme.isColorfulMode ? Border.all(
                            color: featureColor.withOpacity(0.2),
                          ) : null,
                        ),
                        child: ListTile(
                          title: Text(
                            _items[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: theme.isColorfulMode 
                                  ? Theme.of(context).brightness == Brightness.light
                                      ? const Color(0xFF2D3748)
                                      : Colors.white
                                  : null,
                            ),
                          ),
                  trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: theme.isColorfulMode ? featureColor : null,
                            ),
                    onPressed: () => _removeItem(index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Results
            if (_results.isNotEmpty)
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
                      child: Wrap(
                spacing: 12,
                children: _results
                            .map((item) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : null,
                                    borderRadius: BorderRadius.circular(20),
                                    border: theme.isColorfulMode ? Border.all(
                                      color: featureColor.withOpacity(0.3),
                                    ) : null,
                                  ),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.isColorfulMode ? featureColor : null,
                                    ),
                                  ),
                                ))
                    .toList(),
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