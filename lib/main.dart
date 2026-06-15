import 'package:flutter/material.dart';
import 'features/auth/views/welcome_screen.dart';
import 'features/doctor_portal/doctor_screen.dart';
import 'features/home/views/home_screen.dart';
import 'features/home/views/search_screen.dart';
import 'features/appointment/views/schedule_list_screen.dart';
import 'features/profile/views/profile_screen.dart';
import 'widgets/bottom_navigation_bar_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

// Khai báo biến toàn cục để gọi ở mọi nơi trong app
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SereneHealth',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF111827)),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      try {
        final data = await supabase
            .from('users')
            .select('role')
            .eq('authid', session.user.id)
            .single();
        final role = data['role'] ?? 'patient';
        if (!mounted) return;
        if (role == 'doctor') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainApp()),
            (route) => false,
          );
        }
        return;
      } catch (_) {}
    }
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const WelcomeScreen();
  }
}

class MainApp extends StatefulWidget {
  final int initialIndex;
  const MainApp({super.key, this.initialIndex = 0});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _buildPage(_currentIndex),
          ),
        ),
        bottomNavigationBar: BottomNavigationBarApp(
          initialIndex: _currentIndex,
          onItemTapped: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onSearchTap: () => setState(() => _currentIndex = 1),
          onScheduleTap: () => setState(() => _currentIndex = 2),
        );
      case 1:
        return const SearchScreen();
      case 2:
        return const ScheduleListScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
