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
import './providers/navigation_provider.dart';
import './providers/theme_provider.dart';
import './providers/user_provider.dart';
import './services/storage_service.dart';
import './utils/app_themes.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => BankingProvider()),
        BlocProvider(
          create: (context) => ClaimsBloc(storageService: StorageService()),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;
  late StreamSubscription<User?> _authSubscription;
  late final ClaimsBloc _claimsBloc;
  late final UserProvider _userProvider;
  late final BankingProvider _bankingProvider;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(navigatorKey);
    _claimsBloc = context.read<ClaimsBloc>();
    _userProvider = context.read<UserProvider>();
    _bankingProvider = context.read<BankingProvider>();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userProvider.listenToUserData(user);
        _bankingProvider.listenToBankingInfo(user);
        _claimsBloc.add(LoadClaims());
      } else {
        _userProvider.clearUserData();
        _bankingProvider.clearBankingInfo();
        _claimsBloc.add(ClearClaims());
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
          routerConfig: _appRouter.router,
          title: 'Claims App',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}
