import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/session_state.dart';
import 'auth/login_screen.dart';
import 'home/home_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionState>(
      builder: (context, session, _) {
        if (session.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return session.profile == null ? const LoginScreen() : const HomeShell();
      },
    );
  }
}
