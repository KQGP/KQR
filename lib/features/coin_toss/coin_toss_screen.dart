import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';

class CoinTossScreen extends ConsumerStatefulWidget {
  const CoinTossScreen({super.key});

  @override
  ConsumerState<CoinTossScreen> createState() => _CoinTossScreenState();
}

class _CoinTossScreenState extends ConsumerState<CoinTossScreen> with SingleTickerProviderStateMixin {
  int _coinCount = 1;
  List<bool> _results = [];
  int _totalHeads = 0;
  int _totalTails = 0;
  int _totalFlips = 0;
  late AnimationController _animController;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _flipCoins() {
    final rng = Random();
    setState(() {
      _results = List.generate(_coinCount, (_) => rng.nextBool());
      _totalHeads += _results.where((r) => r).length;
      _totalTails += _results.where((r) => !r).length;
      _totalFlips += _results.length;
      _animController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Coin Toss');
    
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Coin Toss',
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Number of Coins',
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
                                  value: _coinCount,
                                  underline: const SizedBox(),
                                  items: List.generate(9, (i) => i + 1)
                                      .map((q) => DropdownMenuItem(value: q, child: Text('$q')))
                                      .toList(),
                                  onChanged: (v) => setState(() => _coinCount = v ?? 1),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
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
                          child: ElevatedButton(
                              onPressed: _flipCoins,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                                foregroundColor: theme.isColorfulMode ? Colors.white : null,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Flip Coins',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              
              // Results Section
              if (_results.isNotEmpty)
                ScaleTransition(
                  scale: _flipAnim,
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
                              'Flip Results',
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
                                    .map((isHeads) => _CoinFace(
                                      isHeads: isHeads,
                                      featureColor: featureColor,
                                      isColorfulMode: theme.isColorfulMode,
                                    ))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: theme.isColorfulMode ? featureColor.withOpacity(0.1) : null,
                                border: theme.isColorfulMode ? Border.all(
                                  color: featureColor.withOpacity(0.3),
                                ) : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _ResultStat(
                                    label: 'Heads',
                                    count: _totalHeads,
                                    total: _totalFlips,
                                    color: theme.isColorfulMode ? featureColor : null,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: theme.isColorfulMode ? featureColor.withOpacity(0.3) : Colors.grey,
                                  ),
                                  _ResultStat(
                                    label: 'Tails',
                                    count: _totalTails,
                                    total: _totalFlips,
                                    color: theme.isColorfulMode ? featureColor : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_totalFlips > 0) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _totalHeads = 0;
                      _totalTails = 0;
                      _totalFlips = 0;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Stats'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.isColorfulMode ? featureColor : null,
                    foregroundColor: theme.isColorfulMode ? Colors.white : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinFace extends StatelessWidget {
  final bool isHeads;
  final Color featureColor;
  final bool isColorfulMode;
  
  const _CoinFace({
    required this.isHeads,
    required this.featureColor,
    required this.isColorfulMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isColorfulMode ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHeads 
              ? [Colors.amber.shade400, Colors.amber.shade600]
              : [Colors.grey.shade400, Colors.grey.shade600],
        ) : null,
        color: !isColorfulMode 
            ? (isHeads ? Colors.amber : Colors.grey[400])
            : null,
        border: Border.all(
          color: isColorfulMode ? featureColor.withOpacity(0.5) : Colors.brown, 
          width: 3,
        ),
        boxShadow: isColorfulMode ? [
          BoxShadow(
            color: featureColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isHeads ? Icons.monetization_on : Icons.monetization_on_outlined,
            color: isColorfulMode ? Colors.white : Colors.brown,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
        isHeads ? 'Heads' : 'Tails',
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold,
              color: isColorfulMode ? Colors.white : Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color? color;
  
  const _ResultStat({
    required this.label,
    required this.count,
    required this.total,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '($percentage%)',
          style: TextStyle(
            fontSize: 12,
            color: color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
} 