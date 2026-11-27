import 'package:flutter/material.dart';

void main() {
  runApp(const PayomApp());
}

class PayomApp extends StatelessWidget {
  const PayomApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF071426);
    const blue = Color(0xFF258BFF);

    return MaterialApp(
      title: 'PAYOM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: Brightness.dark,
          surface: const Color(0xFF10243D),
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF10243D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF258BFF);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF39B8FF), Color(0xFF176BEB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: blue.withValues(alpha: 0.28),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.forum_rounded,
                      size: 54,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'PAYOM',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Общение без границ',
                    style: TextStyle(color: Color(0xFF9CB3CE), fontSize: 16),
                  ),
                  const SizedBox(height: 42),
                  const _FeatureTile(
                    icon: Icons.lock_rounded,
                    title: 'Приватность',
                    subtitle: 'Твои разговоры — под твоим контролем',
                  ),
                  const SizedBox(height: 14),
                  const _FeatureTile(
                    icon: Icons.bolt_rounded,
                    title: 'Быстро и удобно',
                    subtitle: 'Современный мессенджер в синем стиле',
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Экран регистрации добавим следующим этапом.'),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Начать',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Первая версия • 0.1.0',
                    style: TextStyle(color: Color(0xFF68809C), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10243D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1D3B5D)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF39B8FF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF9CB3CE), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
