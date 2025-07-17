import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'dart:math';

class WheelSpinnerScreen extends ConsumerStatefulWidget {
  const WheelSpinnerScreen({super.key});

  @override
  ConsumerState<WheelSpinnerScreen> createState() => _WheelSpinnerScreenState();
}

class _WheelSpinnerScreenState extends ConsumerState<WheelSpinnerScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _optionController = TextEditingController();
  final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];
  int? _selectedIndex;
  late AnimationController _animController;
  late Animation<double> _spinAnim;
  double _currentAngle = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _spinAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onSpinEnd();
        }
      });
  }

  @override
  void dispose() {
    _optionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _addOption() {
    final text = _optionController.text.trim();
    if (text.isNotEmpty && !_options.contains(text)) {
      setState(() {
        _options.add(text);
        _optionController.clear();
      });
    }
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      if (_options.isEmpty) {
        _selectedIndex = null;
      } else if (_selectedIndex != null && _selectedIndex! >= _options.length) {
        _selectedIndex = null;
      }
    });
  }

  void _spinWheel() {
    if (_options.isEmpty) return;
    final rng = Random();
    final spins = rng.nextInt(4) + 4; // 4-7 full spins
    final randomAngle = rng.nextDouble() * 2 * pi;
    final targetAngle = (spins * 2 * pi) + randomAngle;
    _animController.reset();
    _spinAnim = Tween<double>(begin: _currentAngle, end: targetAngle).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutQuart))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onSpinEnd();
        }
      });
    _animController.forward();
  }

  void _onSpinEnd() {
    // Normalize angle to [0, 2pi)
    _currentAngle = _spinAnim.value % (2 * pi);
    final anglePerSlice = 2 * pi / (_options.isEmpty ? 1 : _options.length);
    // The pointer is at -pi/2 (top)
    final pointerAngle = (-pi / 2 - _currentAngle) % (2 * pi);
    int? selected = (_options.isEmpty)
        ? null
        : (pointerAngle / anglePerSlice).floor() % _options.length;
    setState(() {
      _selectedIndex = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('Wheel Spinner');
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'Wheel Spinner',
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03 + 8,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add Options Section
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _optionController,
                        decoration: InputDecoration(
                          labelText: 'Add option',
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
                        onSubmitted: (_) => _addOption(),
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
                        onPressed: _addOption,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedIndex != null && _options.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.isColorfulMode ? featureColor.withOpacity(0.12) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: featureColor.withOpacity(0.4),
                          width: 1.5,
                        ),
                        boxShadow: theme.isColorfulMode ? [
                          BoxShadow(
                            color: featureColor.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.celebration, color: featureColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _options[_selectedIndex!],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: theme.isColorfulMode
                                  ? Theme.of(context).brightness == Brightness.light
                                      ? const Color(0xFF2D3748)
                                      : Colors.white
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Spinner Section
              Container(
                padding: const EdgeInsets.all(12),
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
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: 180,
                      child: Center(
                        child: _options.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.casino,
                                    size: 64,
                                    color: theme.isColorfulMode ? featureColor.withOpacity(0.5) : null,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Add options to spin the wheel',
                                    style: TextStyle(
                                      color: theme.isColorfulMode 
                                          ? Theme.of(context).brightness == Brightness.light
                                              ? const Color(0xFF718096)
                                              : Colors.white70
                                          : null,
                                    ),
                                  ),
                                ],
                              )
                            : GestureDetector(
                                onTap: _spinWheel,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CustomPaint(
                                      painter: _WheelPainter(
                                        options: _options,
                                        angle: _spinAnim.value,
                                        selectedIndex: _selectedIndex,
                                        featureColor: featureColor,
                                        isColorfulMode: theme.isColorfulMode,
                                      ),
                                      child: Container(
                                        width: 180,
                                        height: 180,
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: theme.isColorfulMode ? Colors.white : Colors.grey[200],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: featureColor,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: featureColor.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Pointer
                                    Positioned(
                                      top: 0,
                                      child: Container(
                                        width: 0,
                                        height: 0,
                                        decoration: const BoxDecoration(),
                                        child: CustomPaint(
                                          painter: _PointerPainter(
                                            color: featureColor,
                                            isDarkMode: Theme.of(context).brightness == Brightness.dark,
                                          ),
                                          size: const Size(20, 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              // Padding between spinner and options list
              const SizedBox(height: 16),
              // Stretchable Options List (always visible)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                            'Options (${_options.length})',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.isColorfulMode ? featureColor : null,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _options.isEmpty
                              ? Center(
                                  child: Text(
                                    'No options added yet',
                                    style: TextStyle(
                                      color: theme.isColorfulMode 
                                          ? Theme.of(context).brightness == Brightness.light
                                              ? const Color(0xFF718096)
                                              : Colors.white70
                                          : null,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _options.length,
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
                                        _options[index],
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
                                        onPressed: () => _removeOption(index),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> options;
  final double angle;
  final int? selectedIndex;
  final Color featureColor;
  final bool isColorfulMode;
  
  _WheelPainter({
    required this.options, 
    required this.angle, 
    this.selectedIndex,
    required this.featureColor,
    required this.isColorfulMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final anglePerSlice = 2 * pi / options.length;
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (int i = 0; i < options.length; i++) {
      if (isColorfulMode) {
        // Create gradient colors based on feature color
        final hue = featureColor.computeLuminance() > 0.5 ? 0.0 : 60.0;
        final saturation = 0.7;
        final lightness = 0.6 + (i * 0.1) % 0.3;
        paint.color = HSLColor.fromAHSL(1.0, (hue + i * 30) % 360, saturation, lightness).toColor();
      } else {
      paint.color = Colors.primaries[i % Colors.primaries.length].shade300;
      }
      
      final startAngle = angle + i * anglePerSlice;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerSlice,
        true,
        paint,
      );
      
      // Draw borders
      final borderPaint = Paint()
        ..color = isColorfulMode ? featureColor.withOpacity(0.3) : Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerSlice,
        true,
        borderPaint,
      );

      // Draw option text
      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i],
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: radius * 0.8);
      final textAngle = startAngle + anglePerSlice / 2;
      final textRadius = radius * 0.65;
      final textOffset = Offset(
        center.dx + textRadius * cos(textAngle),
        center.dy + textRadius * sin(textAngle),
      );
      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.angle != angle || 
           oldDelegate.options != options || 
           oldDelegate.featureColor != featureColor ||
           oldDelegate.isColorfulMode != isColorfulMode;
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;
  final bool isDarkMode;
  
  _PointerPainter({required this.color, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw shadow for extra visibility
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width / 2, 4);
    path.lineTo(4, size.height);
    path.lineTo(size.width - 4, size.height);
    path.close();
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

    // Draw main pointer
    final pointerPaint = Paint()
      ..color = isDarkMode ? Colors.yellow : Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, pointerPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = isDarkMode ? Colors.black : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDarkMode != isDarkMode;
  }
} 