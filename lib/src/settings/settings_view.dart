import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

/// Displays the various settings that can be customized by the user.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section "Apparence"
              _buildSection(
                context,
                'Apparence',
                [
                  ListTile(
                    title: const Text('Thème'),
                    subtitle: Text(_getThemeModeName(themeProvider.themeMode)),
                    leading: const Icon(Icons.color_lens),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/theme-settings');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section "Données personnelles"
              _buildSection(
                context,
                'Données personnelles',
                [
                  ListTile(
                    title: const Text('Mes favoris'),
                    leading: const Icon(Icons.favorite),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/favorites');
                    },
                  ),
                  ListTile(
                    title: const Text('Statistiques'),
                    leading: const Icon(Icons.analytics),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/statistics');
                    },
                  ),
                  ListTile(
                    title: const Text('Exporter mes données'),
                    subtitle: const Text('Télécharger toutes vos données'),
                    leading: const Icon(Icons.download),
                    onTap: () {
                      _showExportDialog(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section "À propos"
              _buildSection(
                context,
                'À propos',
                [
                  ListTile(
                    title: const Text('Version de l\'application'),
                    subtitle: const Text('1.0.0'),
                    leading: const Icon(Icons.info),
                  ),
                  ListTile(
                    title: const Text('Conditions d\'utilisation'),
                    leading: const Icon(Icons.description),
                    onTap: () {
                      _showTermsDialog(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Politique de confidentialité'),
                    leading: const Icon(Icons.privacy_tip),
                    onTap: () {
                      _showPrivacyDialog(context);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
      BuildContext context,
      String title,
      List<Widget> children,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  String _getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'Système';
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exporter mes données'),
          content: const Text('Cette fonctionnalité n\'est pas encore disponible. Elle vous permettra de télécharger toutes vos données personnelles (favoris, épisodes vus, etc.) dans un fichier.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Conditions d\'utilisation'),
          content: const SingleChildScrollView(
            child: Text(
              'Cette application utilise l\'API Episodate pour fournir des informations sur les séries TV. '
                  'Les données affichées sont la propriété de leurs détenteurs respectifs.\n\n'
                  'L\'utilisation de cette application est soumise aux conditions suivantes:\n'
                  '- Cette application est fournie "telle quelle", sans garantie d\'aucune sorte.\n'
                  '- Les données utilisateur sont stockées localement sur votre appareil.\n'
                  '- Nous ne sommes pas responsables des inexactitudes dans les données fournies par l\'API.\n\n'
                  'En utilisant cette application, vous acceptez ces conditions.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Politique de confidentialité'),
          content: const SingleChildScrollView(
            child: Text(
              'Protection de vos données:\n\n'
                  '- Toutes vos données personnelles (favoris, épisodes vus, notes) sont stockées localement sur votre appareil.\n'
                  '- Nous ne collectons aucune donnée personnelle.\n'
                  '- Aucune information n\'est partagée avec des tiers.\n'
                  '- L\'application accède à Internet uniquement pour récupérer des informations sur les séries via l\'API Episodate.\n\n'
                  'Si vous avez des questions concernant notre politique de confidentialité, n\'hésitez pas à nous contacter.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}