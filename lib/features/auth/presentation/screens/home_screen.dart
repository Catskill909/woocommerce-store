import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woocommerce_app/features/auth/domain/entities/user.dart';
import 'package:woocommerce_app/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildUserAvatar(user),
            const SizedBox(height: 16),
            _buildWelcomeMessage(context, user),
            if (user?.email != null)
              _buildEmailText(context, user!.email),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to products screen
                Navigator.pushNamed(context, '/products');
              },
              child: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(User? user) {
    if (user?.avatarUrl != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(user!.avatarUrl!),
      );
    }
    return const CircleAvatar(
      radius: 50,
      child: Icon(Icons.person, size: 50),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context, User? user) {
    final displayName = user?.displayName ?? user?.email ?? 'User';
    return Text(
      'Welcome, $displayName',
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildEmailText(BuildContext context, String email) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          email,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
