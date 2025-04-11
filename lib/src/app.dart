import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

import 'main_screen.dart';
import 'features/shows/show_details_view.dart';
import 'features/user/statistics_view.dart';
import 'features/user/theme_settings_view.dart';
import 'settings/settings_view.dart';
import 'providers/theme_provider.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDarkMode = themeProvider.isDarkMode;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          // Utiliser une chaîne statique au lieu de AppLocalizations qui n'est pas encore initialisé
          onGenerateTitle: (BuildContext context) => 'TV Shows Explorer',
          theme: themeProvider.getTheme(false),
          darkTheme: themeProvider.getTheme(true),
          themeMode: themeProvider.themeMode,
          home: const MainScreen(),
          onGenerateRoute: (RouteSettings routeSettings) {
            return PageRouteBuilder(
              settings: routeSettings,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                Widget page;

                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    page = const SettingsView();
                  case ShowDetailsView.routeName:
                    page = const ShowDetailsView();
                  case StatisticsView.routeName:
                    page = const StatisticsView();
                  case ThemeSettingsView.routeName:
                    page = const ThemeSettingsView();
                  default:
                    page = const MainScreen(); // Default route goes to MainScreen
                }

                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: page,
                );
              },
            );
          },
        );
      },
    );
  }
}