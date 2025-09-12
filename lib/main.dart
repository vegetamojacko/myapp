import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './app_router.dart';
import './blocs/claims/claims_bloc.dart';
import './blocs/claims/claims_event.dart';
import './providers/banking_provider.dart';
import './providers/navigation_provider.dart';
import './providers/theme_provider.dart';
import './providers/user_provider.dart';
import './services/storage_service.dart';
import './utils/app_themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => BankingProvider()),
        BlocProvider(
          create: (_) =>
              ClaimsBloc(storageService: StorageService())..add(LoadClaims()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            title: 'Claims App',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
          );
        },
      ),
    );
  }
}
