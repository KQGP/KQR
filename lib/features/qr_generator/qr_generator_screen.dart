import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;

class QrGeneratorScreen extends ConsumerStatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  ConsumerState<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends ConsumerState<QrGeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  String _qrData = '';
  int _qrSize = 200;
  bool _hasData = false;
  final GlobalKey _qrKey = GlobalKey();

  void _generateQR() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _qrData = text;
        _hasData = true;
      });
    }
  }

  Future<void> _shareQRImage() async {
    if (!_hasData) return;
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR Code: $_qrData',
        subject: 'QR Code',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR Code: $e')),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final featureColor = theme.getFeatureColor('QR Generator');
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'QR Code Generator',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            TextField(
              controller: _textController,
                        decoration: InputDecoration(
                labelText: 'Enter text or URL',
                hintText: 'https://example.com or any text',
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
              maxLines: 3,
              onSubmitted: (_) => _generateQR(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                          Text(
                            'Size:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.isColorfulMode ? featureColor : null,
                            ),
                          ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _qrSize,
                            underline: const SizedBox(),
                  items: [150, 200, 250, 300]
                      .map((s) => DropdownMenuItem(value: s, child: Text('$s')))
                      .toList(),
                  onChanged: (v) => setState(() => _qrSize = v ?? 200),
                ),
                const Spacer(),
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
                  onPressed: _generateQR,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                                foregroundColor: theme.isColorfulMode ? Colors.white : null,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                  child: const Text('Generate QR'),
                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_hasData) ...[
              Text('Generated QR for: $_qrData', style: TextStyle(fontSize: 12, color: theme.isColorfulMode ? featureColor : null)),
              const SizedBox(height: 8),
              // QR code display
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
                  child: RepaintBoundary(
                key: _qrKey,
                child: Center(
                  child: Container(
                    width: _qrSize.toDouble(),
                    height: _qrSize.toDouble(),
                    decoration: BoxDecoration(
                          border: Border.all(color: theme.isColorfulMode ? featureColor : Colors.black, width: 2),
                      color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: _qrData,
                      version: QrVersions.auto,
                      size: _qrSize.toDouble(),
                      backgroundColor: Colors.white,
                          foregroundColor: theme.isColorfulMode ? featureColor : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
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
                  onPressed: _shareQRImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.isColorfulMode ? Colors.transparent : null,
                      foregroundColor: theme.isColorfulMode ? Colors.white : null,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  icon: const Icon(Icons.share),
                  label: const Text('Share QR Code'),
                  ),
                ),
              ),
            ] else ...[
              Center(
                child: Container(
                  width: _qrSize.toDouble(),
                  height: _qrSize.toDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.isColorfulMode ? featureColor.withOpacity(0.2) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                    color: theme.isColorfulMode ? featureColor.withOpacity(0.03) : Colors.grey.shade50,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 64,
                          color: theme.isColorfulMode ? featureColor.withOpacity(0.3) : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter text and generate\nQR Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.isColorfulMode ? featureColor.withOpacity(0.7) : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 