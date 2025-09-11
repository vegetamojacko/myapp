import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/banking_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/edit_profile_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const EditProfileDialog(),
                    );
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(userProvider.name),
                      subtitle: Text(userProvider.email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(userProvider.contactNumber),
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Banking Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<BankingProvider>(
              builder: (context, bankingProvider, child) {
                if (bankingProvider.bankingInfo == null) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () => context.go('/banking-details'),
                      child: const Text('Add Banking Details'),
                    ),
                  );
                } else {
                  final bankingInfo = bankingProvider.bankingInfo!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bank: ${bankingInfo.bankName}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Account Number: ${bankingInfo.accountNumber}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Account Holder: ${bankingInfo.accountHolder}', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => context.go('/banking-details'),
                                child: const Text('Edit'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  context.read<BankingProvider>().updateBankingInfo(null);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Claims App',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2023 Google LLC',
                  children: <Widget>[
                    const SizedBox(height: 24),
                    const Text(
                        'This is a demo application to showcase Flutter development with Firebase and generative AI.'),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout),
              onTap: () {
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
