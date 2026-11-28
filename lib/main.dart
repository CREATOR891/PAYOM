import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey =
    String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

const _navy = Color(0xFF071426);
const _panel = Color(0xFF10243D);
const _blue = Color(0xFF258BFF);
const _muted = Color(0xFF9CB3CE);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configured =
      _supabaseUrl.startsWith('https://') && _supabasePublishableKey.isNotEmpty;

  if (configured) {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabasePublishableKey,
    );
  }
  runApp(PayomApp(isConfigured: configured));
}

class PayomApp extends StatelessWidget {
  const PayomApp({super.key, required this.isConfigured});
  final bool isConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAYOM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          brightness: Brightness.dark,
          surface: _panel,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _panel,
          hintStyle: const TextStyle(color: _muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1D3B5D)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
      ),
      home: isConfigured
          ? const AuthGate()
          : const ConfigurationScreen(),
    );
  }
}

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BrandMark(),
                  SizedBox(height: 24),
                  Text('PAYOM', style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  )),
                  SizedBox(height: 14),
                  Text(
                    'Приложение собрано, но Supabase ещё не настроен. '
                    'Добавь SUPABASE_URL и SUPABASE_PUBLISHABLE_KEY '
                    'в GitHub Actions Secrets и запусти сборку снова.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, height: 1.5),
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        auth.currentSession,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _LoadingScreen();
        }
        final session = snapshot.data?.session ?? auth.currentSession;
        return session == null ? const AuthScreen() : const MainShell();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  bool _hidePassword = true;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      if (_isRegister) {
        final response = await auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (response.session == null && mounted) {
          setState(() {
            _message = 'Аккаунт создан. Проверь почту и подтверди адрес, '
                'если подтверждение включено в Supabase.';
            _isError = false;
          });
        }
      } else {
        await auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _message = error.message;
          _isError = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Не удалось выполнить запрос. Проверь интернет '
              'и настройки Supabase.';
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _BrandMark()),
                    const SizedBox(height: 26),
                    const Center(child: Text('PAYOM', style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ))),
                    const SizedBox(height: 8),
                    Text(
                      _isRegister ? 'Создай свой аккаунт' : 'Рады снова тебя видеть',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted),
                    ),
                    const SizedBox(height: 34),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (!text.contains('@') || !text.contains('.')) {
                          return 'Введи корректный Email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      autofillHints: _isRegister
                          ? const [AutofillHints.newPassword]
                          : const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(_hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Минимум 6 символов';
                        }
                        return null;
                      },
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _message!,
                        style: TextStyle(
                          color: _isError
                              ? const Color(0xFFFF8585)
                              : const Color(0xFF75D6A2),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isRegister ? 'Создать аккаунт' : 'Войти',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() {
                                _isRegister = !_isRegister;
                                _message = null;
                              }),
                      child: Text(_isRegister
                          ? 'Уже есть аккаунт? Войти'
                          : 'Нет аккаунта? Зарегистрироваться'),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Используя PAYOM, не публикуй пароли и коды подтверждения.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF68809C), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _PlaceholderPage(
        icon: Icons.forum_outlined,
        title: 'Чаты',
        description: 'Здесь появятся твои личные и групповые переписки.',
      ),
      const _PlaceholderPage(
        icon: Icons.circle_outlined,
        title: 'Статусы',
        description: 'Здесь будут статусы контактов.',
      ),
      const _PlaceholderPage(
        icon: Icons.call_outlined,
        title: 'Звонки',
        description: 'Здесь будет история звонков PAYOM.',
      ),
      const SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PAYOM', style: TextStyle(
          fontWeight: FontWeight.w800, letterSpacing: 2,
        )),
        backgroundColor: _navy,
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.forum_outlined),
              selectedIcon: Icon(Icons.forum), label: 'Чаты'),
          NavigationDestination(icon: Icon(Icons.circle_outlined),
              selectedIcon: Icon(Icons.circle), label: 'Статусы'),
          NavigationDestination(icon: Icon(Icons.call_outlined),
              selectedIcon: Icon(Icons.call), label: 'Звонки'),
          NavigationDestination(icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text('Настройки', style: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w800,
        )),
        const SizedBox(height: 22),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: _blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(user?.email ?? 'Пользователь PAYOM'),
          subtitle: const Text('Аккаунт Supabase'),
        ),
        const Divider(height: 30),
        ListTile(
          leading: const Icon(Icons.logout, color: Color(0xFFFF8585)),
          title: const Text('Выйти из аккаунта'),
          onTap: () async {
            await Supabase.instance.client.auth.signOut();
          },
        ),
      ],
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 58, color: _blue),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 10),
            Text(description, textAlign: TextAlign.center,
                style: const TextStyle(color: _muted)),
            const SizedBox(height: 16),
            const Text('Этот модуль будет подключён следующим этапом.',
                style: TextStyle(color: Color(0xFF68809C), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF39B8FF), Color(0xFF176BEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.forum_rounded, size: 48, color: Colors.white),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: _blue)),
    );
  }
}
