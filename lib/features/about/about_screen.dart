import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final aboutColor = theme.getFeatureColor('About');
    
    return Scaffold(
      backgroundColor: theme.isColorfulMode 
          ? Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF8F9FF)
              : const Color(0xFF1A1A2E)
          : null,
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.isColorfulMode ? aboutColor : null,
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
                    aboutColor.withOpacity(0.05),
                  ]
                : [
                    const Color(0xFF1A1A2E),
                    aboutColor.withOpacity(0.1),
                  ],
          ),
        ) : null,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Colorful Design Toggle
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: theme.isColorfulMode ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      aboutColor.withOpacity(0.1),
                      aboutColor.withOpacity(0.05),
                    ],
                  ) : null,
                  border: theme.isColorfulMode ? Border.all(
                    color: aboutColor.withOpacity(0.3),
                    width: 1,
                  ) : null,
                  boxShadow: theme.isColorfulMode ? [
                    BoxShadow(
                      color: aboutColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: theme.isColorfulMode ? BoxDecoration(
                            color: aboutColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ) : null,
                          child: Icon(
                            Icons.palette,
                            size: 32,
                            color: aboutColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Colorful Design',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.isColorfulMode 
                                      ? Theme.of(context).brightness == Brightness.light
                                          ? const Color(0xFF2D3748)
                                          : Colors.white
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Switch to modern colorful UI',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: theme.isColorfulMode 
                                      ? Theme.of(context).brightness == Brightness.light
                                          ? const Color(0xFF718096)
                                          : Colors.white70
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: theme.isColorfulMode,
                          onChanged: (value) {
                            theme.toggleColorfulMode();
                          },
                          activeColor: aboutColor,
                          activeTrackColor: aboutColor.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // App Logo
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Image.asset(
                  'icon.png',
                  height: 220,
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
              // About Content
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: theme.isColorfulMode ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        aboutColor.withOpacity(0.1),
                        aboutColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: aboutColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ) : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: theme.isColorfulMode ? BoxDecoration(
                          color: aboutColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ) : null,
                        child: Icon(
                          Icons.favorite,
                          color: aboutColor,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 24),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: theme.isColorfulMode 
                                ? Theme.of(context).brightness == Brightness.light
                                    ? const Color(0xFF2D3748)
                                    : Colors.white
                                : null,
                          ),
                          children: [
                            const TextSpan(text: 'Prepared With Love by\n'),
                            const TextSpan(
                              text: 'KHALIL ANES ALQISY ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: '('),
                            TextSpan(
                              text: 'K',
                              style: TextStyle(
                                color: Color(0xFF2196F3), // Blue
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            TextSpan(
                              text: 'Q',
                              style: TextStyle(
                                color: Color(0xFF4CAF50), // Green
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            TextSpan(
                              text: 'G',
                              style: TextStyle(
                                color: Color(0xFFF44336), // Red
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const TextSpan(text: ') '),
                          ],
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