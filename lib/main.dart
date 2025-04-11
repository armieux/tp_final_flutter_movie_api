import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/services/user_data_service.dart';
import 'src/providers/user_data_provider.dart';
import 'src/providers/theme_provider.dart';

void main() async {
  // Ensure that Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local data storage
  await UserDataService.init();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Create UserDataProvider instance and load initial data
  final userDataProvider = UserDataProvider();
  await userDataProvider.init();

  // Create ThemeProvider instance
  final themeProvider = ThemeProvider();
  if (userDataProvider.activeTheme != null) {
    themeProvider.setCustomTheme(userDataProvider.activeTheme);
  }

  // Run the app and pass in providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userDataProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: settingsController), // Correction ici: Provider → ChangeNotifierProvider
      ],
      child: const MyApp(),
    ),
  );
}