import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge,
                children: [
                  const TextSpan(text: 'Prepared With Love by\n'),
                  const TextSpan(
                    text: 'KHALIL ANES ALQISY ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '('),
                  TextSpan(
                    text: 'K',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Q',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'G',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ') '),
                  const TextSpan(text: '<3', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.favorite, color: Colors.pink, size: 40),
          ],
        ),
      ),
    );
  }
} 