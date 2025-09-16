import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/blocs/claims/claims_bloc.dart';
import 'package:myapp/providers/banking_provider.dart';
import 'package:myapp/providers/navigation_provider.dart';
import 'package:myapp/providers/user_provider.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/services/storage_service.dart';

// A mock GoRouter for testing
final _mockRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
);

void main() {
  testWidgets('HomeScreen renders correctly', (WidgetTester tester) async {
    // Build the HomeScreen widget with all necessary providers.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => BankingProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ClaimsBloc(storageService: StorageService()),
            ),
          ],
          child: MaterialApp.router(routerConfig: _mockRouter),
        ),
      ),
    );

    // Wait for the widget to build.
    await tester.pumpAndSettle();

    // Verify that the welcome message is displayed.
    // The user provider is new, so the name will be an empty string.
    expect(find.text('Welcome Back, !'), findsOneWidget);

    // Verify that the 'Quick Actions' title is displayed.
    expect(find.text('Quick Actions'), findsOneWidget);

    // Verify that the 'Recent Claims' title is displayed.
    expect(find.text('Recent Claims'), findsOneWidget);

    // Verify that the 'No recent claims.' message is shown initially.
    expect(find.text('No recent claims.'), findsOneWidget);
  });
}
