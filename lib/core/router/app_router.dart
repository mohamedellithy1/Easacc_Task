import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/webview/presentation/pages/webview_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/webview',
      builder: (context, state) {
        final url = state.extra as String; 
        return WebViewScreen(url: url);
      },
    ),
  ],
);

