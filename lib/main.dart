import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './app_router.dart';
import './blocs/claims/claims_bloc.dart';
import './blocs/claims/claims_event.dart';
import './firebase_options.dart';
import './providers/banking_provider.dart';
import './providers/car_wash_provider.dart';
import './providers/navigation_provider.dart';
import './providers/theme_provider.dart';
import './providers/user_provider.dart';
import './services/storage_service.dart';
import './utils/app_themes.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // This is the correct place for ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up all dependencies before running the app
  final appRouter = AppRouter(navigatorKey);
  final storageService = StorageService();
  final claimsBloc = ClaimsBloc(storageService: storageService);

  runApp(App(appRouter: appRouter, claimsBloc: claimsBloc));
}

class App extends StatelessWidget {
  final AppRouter appRouter;
  final ClaimsBloc claimsBloc;

  const App({super.key, required this.appRouter, required this.claimsBloc});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => BankingProvider()),
        ChangeNotifierProvider(
            create: (_) => CarWashProvider()..loadCarWashes()),
        // Provide the already-created ClaimsBloc instance
        BlocProvider.value(value: claimsBloc),
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

    // It's safer to access providers and blocs within initState like this
    // to avoid issues with context availability.
    final claimsBloc = context.read<ClaimsBloc>();
    final userProvider = context.read<UserProvider>();
    final bankingProvider = context.read<BankingProvider>();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return; // Check if the widget is still in the tree

      if (user != null) {
        userProvider.loadUserData(user);
        bankingProvider.loadBankingInfo(user);
        bankingProvider.listenToUserChanges(user); // Updated to new method
        claimsBloc.add(LoadClaims());
      } else {
        userProvider.clearUserData();
        bankingProvider.clearBankingInfo();
        claimsBloc.add(LoadClaims()); // Consider a specific 'ClearClaimsEvent'
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
