import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../blocs/claims/claims_bloc.dart';
import '../blocs/claims/claims_event.dart';
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
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(userProvider.name),
                  subtitle: Text(userProvider.email),
                );
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
            ListTile(
              title: const Text('Clear Claims Data'),
              trailing: const Icon(Icons.delete, color: Colors.red),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Clear'),
                      content: const Text(
                          'Are you sure you want to delete all claims data? This action cannot be undone.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Clear', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            context.read<ClaimsBloc>().add(ClearClaims());
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All claims data has been cleared.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
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
          ],
        ),
      ),
    );
  }
}
