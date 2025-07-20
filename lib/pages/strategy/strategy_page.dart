import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login/login_page.dart';

class StrategyPage extends StatelessWidget {
  const StrategyPage({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Center(
        child: auth.isLoggedIn
            ? const Text('🧠 Strategy Page')
            : ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  // After returning, refresh login status
                  auth.checkLoginStatus();
                },
                child: const Text('Login to access Strategy'),
              ),
      ),
    );
  }
}
