import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIVD Works',
      theme: ThemeData(fontFamily: 'KumbhSans'),
      initialRoute: '/',
      routes: {
        '/':        (_) => const WelcomeScreen(),
        '/login':   (_) => const LoginScreen(),
        '/register':(_) => const RegisterScreen(),
      },
    );
  }
}
