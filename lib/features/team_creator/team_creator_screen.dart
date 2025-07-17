import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';
import 'package:hive/hive.dart';
import 'team_set.dart';

class TeamCreatorScreen extends ConsumerStatefulWidget {
  const TeamCreatorScreen({super.key});

  @override
  ConsumerState<TeamCreatorScreen> createState() => _TeamCreatorScreenState();
}

class _TeamCreatorScreenState extends ConsumerState<TeamCreatorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _names = [];
  int _teamCount = 2;
  bool _balance = true;
  List<List<String>> _teams = [];
  List<TeamSet> _savedSets = [];
  late Box<TeamSet> _box;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TeamSetAdapter());
    }
    _box = await Hive.openBox<TeamSet>('team_sets');
    setState(() {
      _savedSets = _box.values.toList();
    });
  }

  void _addName() {
    final text = _nameController.text.trim();
    if (text.isNotEmpty && !_names.contains(text)) {
      setState(() {
        _names.add(text);
        _nameController.clear();
      });
    }
  }

  void _removeName(int index) {
    setState(() {
      _names.removeAt(index);
    });
  }

  void _createTeams() {
    if (_names.isEmpty || _teamCount < 1) return;
    final rng = Random();
    final shuffled = List<String>.from(_names)..shuffle(rng);
    final teams = List.generate(_teamCount, (_) => <String>[]);
    if (_balance) {
      for (int i = 0; i < shuffled.length; i++) {
        teams[i % _teamCount].add(shuffled[i]);
      }
    } else {
      for (final name in shuffled) {
        teams[rng.nextInt(_teamCount)].add(name);
      }
    }
    setState(() {
      _teams = teams;
    });
    _showSaveDialog();
  }

  void _showSaveDialog() {
    final controller = TextEditingController();
    final theme = ref.read(themeProvider);
    final featureColor = theme.getFeatureColor('Team Creator');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.isColorfulMode 
            ? Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF8F9FF)
                : const Color(0xFF1A1A2E)
            : null,
        title: Text(
          'Save Team Set',
          style: TextStyle(
            color: theme.isColorfulMode ? featureColor : null,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Set name',
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
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty && _teams.isNotEmpty) {
                if (_box.containsKey(name)) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('A set with this name already exists.')),
                  );
                  return;
                }
                final set = TeamSet(
                  name: name,
                  names: List<String>.from(_names),
                  teams: _teams.map((t) => List<String>.from(t)).toList(),
                );
                await _box.put(name, set);
                setState(() {
                  _savedSets = _box.values.toList();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Team set "$name" saved.')),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: featureColor,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _loadSet(TeamSet set) {
    setState(() {
      _names.clear();
      _names.addAll(set.names);
      _teams = set.teams.map((t) => List<String>.from(t)).toList();
    });
  }

  void _deleteSet(TeamSet set) async {
    await set.delete();
    setState(() {
      _savedSets = _box.values.toList();
    });
  }

  void _showSavedSetsDialog() async {
    final theme = ref.read(themeProvider);
    final featureColor = theme.getFeatureColor('Team Creator');
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: theme.isColorfulMode 
              ? Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFF8F9FF)
                  : const Color(0xFF1A1A2E)
              : null,
          title: Text(
            'Saved Sets',
            style: TextStyle(
              color: theme.isColorfulMode ? featureColor : null,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: _savedSets.isEmpty
                ? Text(
                    'No saved sets.',
                    style: TextStyle(
                      color: theme.isColorfulMode 
                          ? Theme.of(context).brightness == Brightness.light
                              ? const Color(0xFF718096)
                              : Colors.white70
                          : null,
                    ),
                  )
                : ListView(
                    shrinkWrap: true,
                    children: _savedSets.map((set) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.isColorfulMode ? featureColor.withOpacity(0.05) : null,
                        border: theme.isColorfulMode ? Border.all(
                          color: featureColor.withOpacity(0.2),
                        ) : null,
                      ),
                      child: ListTile(
                        title: Text(
                          set.name, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.isColorfulMode 
                                ? Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF2D3748)
                                    : Colors.white
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          'Teams: ${set.teams.length}, Names: ${set.names.length}', 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.isColorfulMode 
                                ? Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF718096)
                                    : Colors.white70
                                : null,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _loadSet(set);
                        },
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: theme.isColorfulMode ? featureColor : null,
                          ),
                          onPressed: () {
                            _deleteSet(set);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    )).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: featureColor,
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
    setState(() {
      _savedSets = _box.values.toList();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Team Creator');
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Team Creator',
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
            icon: Icon(
              Icons.list,
              color: theme.isColorfulMode ? featureColor : null,
            ),
            tooltip: 'Show Saved Sets',
            onPressed: () => _showSavedSetsDialog(),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView(
            children: [
              // Add Names Section
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
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Add name',
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
                            onSubmitted: (_) => _addName(),
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
                            onPressed: _addName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Settings Section (Create Team)
              Container(
                padding: const EdgeInsets.all(10), // was 20
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
                    padding: const EdgeInsets.all(8), // was 16
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Teams:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: theme.isColorfulMode 
                                      ? Theme.of(context).brightness == Brightness.light
                                          ? const Color(0xFF2D3748)
                                          : Colors.white
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : null,
                                  borderRadius: BorderRadius.circular(8),
                                  border: theme.isColorfulMode ? Border.all(
                                    color: featureColor.withOpacity(0.3),
                                  ) : null,
                                ),
                                child: DropdownButton<int>(
                                  value: _teamCount,
                                  underline: const SizedBox(),
                                  isExpanded: true,
                                  items: List.generate(9, (i) => i + 2)
                                      .map((q) => DropdownMenuItem(value: q, child: Text('$q')))
                                      .toList(),
                                  onChanged: (v) => setState(() => _teamCount = v ?? 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: theme.isColorfulMode 
                                    ? Theme.of(context).brightness == Brightness.light
                                        ? const Color(0xFF2D3748)
                                        : Colors.white
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Switch(
                              value: _balance,
                              onChanged: (v) => setState(() => _balance = v),
                              activeColor: featureColor,
                              activeTrackColor: featureColor.withOpacity(0.3),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 90,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _createTeams,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                              foregroundColor: theme.isColorfulMode ? Colors.white : null,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Create',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // was 16
              // Teams Results (move up)
              if (_teams.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10), // was 20
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8), // was 16
                          child: Text(
                            'Generated Teams',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: theme.isColorfulMode ? featureColor : null,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _teams.length,
                          itemBuilder: (context, i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // was 16,4
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: theme.isColorfulMode ? featureColor.withOpacity(0.05) : null,
                              border: theme.isColorfulMode ? Border.all(
                                color: featureColor.withOpacity(0.2),
                              ) : null,
                            ),
                            child: ListTile(
                              title: Text(
                                'Team ${i + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: theme.isColorfulMode ? featureColor : null,
                                ),
                              ),
                              subtitle: Text(
                                _teams[i].join(', '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.isColorfulMode 
                                      ? Theme.of(context).brightness == Brightness.light
                                          ? const Color(0xFF718096)
                                          : Colors.white70
                                      : null,
                                ),
                              ),
                              isThreeLine: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10), // was 16
              // Participants List (move down)
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Participants (${_names.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.isColorfulMode ? featureColor : null,
                          ),
                        ),
                      ),
                      _names.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Add participants to get started',
                                  style: TextStyle(
                                    color: theme.isColorfulMode 
                                        ? Theme.of(context).brightness == Brightness.light
                                            ? const Color(0xFF718096)
                                            : Colors.white70
                                        : null,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _names.length,
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
                                    _names[index],
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
                                    onPressed: () => _removeName(index),
                                  ),
                                ),
                              ),
                            ),
                    ],
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