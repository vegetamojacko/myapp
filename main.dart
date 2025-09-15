import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'lib/app_router.dart';
import 'lib/blocs/claims/claims_bloc.dart';
import 'lib/blocs/claims/claims_event.dart';
import 'lib/firebase_options.dart';
import 'lib/providers/banking_provider.dart';
import 'lib/providers/car_wash_provider.dart';
import 'lib/providers/navigation_provider.dart';
import 'lib/providers/theme_provider.dart';
import 'lib/providers/user_provider.dart';
import 'lib/services/storage_service.dart';
import 'lib/utils/app_themes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = AppRouter(navigatorKey);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => BankingProvider()),
        ChangeNotifierProvider(create: (_) => CarWashProvider()),
        BlocProvider(
          create: (context) => ClaimsBloc(storageService: StorageService()),
        ),
      ],
      child: MyApp(appRouter: appRouter),
    );
  }
}

class MyApp extends StatefulWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      final claimsBloc = context.read<ClaimsBloc>();
      final userProvider = context.read<UserProvider>();
      final bankingProvider = context.read<BankingProvider>(); // Get BankingProvider
      final carWashProvider = context.read<CarWashProvider>();

      if (user != null) {
        userProvider.loadUserData(user);
        bankingProvider.loadBankingInfo(user); // Load banking info
        carWashProvider.loadCarWashes();
        claimsBloc.add(LoadClaims());
      } else {
        userProvider.clearUserData();
        bankingProvider.clearBankingInfo(); // Clear banking info
        claimsBloc.add(LoadClaims()); // Or an event that clears the claims
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: widget.appRouter.router,
          title: 'Claims App',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}
