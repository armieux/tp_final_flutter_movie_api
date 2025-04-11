import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_data.dart';
import '../../providers/user_data_provider.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsView extends StatefulWidget {
  const ThemeSettingsView({super.key});

  static const routeName = '/theme-settings';

  @override
  State<ThemeSettingsView> createState() => _ThemeSettingsViewState();
}

class _ThemeSettingsViewState extends State<ThemeSettingsView> {
  bool _isCreatingTheme = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _primaryColor = Colors.deepPurple;
  Color _secondaryColor = Colors.teal;
  bool _isDarkTheme = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thèmes et apparence'),
      ),
      body: Consumer2<UserDataProvider, ThemeProvider>(
        builder: (context, userDataProvider, themeProvider, child) {
          final themes = userDataProvider.themes;
          final activeTheme = themeProvider.customTheme;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mode du thème
                _buildThemeModeSection(themeProvider),

                const SizedBox(height: 32),

                // Thèmes personnalisés
                _buildCustomThemesSection(context, themes, activeTheme, userDataProvider, themeProvider),

                const SizedBox(height: 24),

                // Formulaire de création de thème
                if (_isCreatingTheme)
                  _buildThemeCreationForm(context, userDataProvider, themeProvider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _isCreatingTheme
          ? null
          : FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCreatingTheme = true;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildThemeModeSection(ThemeProvider themeProvider) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mode du thème',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<ThemeMode>(
              title: const Text('Clair'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  themeProvider.setCustomTheme(null);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sombre'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  themeProvider.setCustomTheme(null);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Système'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  themeProvider.setCustomTheme(null);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomThemesSection(
      BuildContext context,
      List<UserTheme> themes,
      UserTheme? activeTheme,
      UserDataProvider userDataProvider,
      ThemeProvider themeProvider,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes thèmes personnalisés',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        if (themes.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Vous n\'avez pas encore créé de thème personnalisé. Appuyez sur le bouton + pour en créer un.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              final isActive = activeTheme?.name == theme.name;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isActive
                      ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(theme.primaryColorValue),
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Color(theme.secondaryColorValue),
                    ),
                  ),
                  title: Text(theme.name),
                  subtitle: Text(theme.isDark ? 'Thème sombre' : 'Thème clair'),
                  trailing: isActive
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : const Icon(Icons.circle_outlined),
                  onTap: () {
                    userDataProvider.setActiveTheme(theme);
                    themeProvider.setCustomTheme(theme);
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildThemeCreationForm(
      BuildContext context,
      UserDataProvider userDataProvider,
      ThemeProvider themeProvider,
      ) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Créer un nouveau thème',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du thème',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom pour le thème';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Sélection des couleurs
              Row(
                children: [
                  Expanded(
                    child: _buildColorSelector(
                      context,
                      'Couleur primaire',
                      _primaryColor,
                          (color) {
                        setState(() {
                          _primaryColor = color;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildColorSelector(
                      context,
                      'Couleur secondaire',
                      _secondaryColor,
                          (color) {
                        setState(() {
                          _secondaryColor = color;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Mode du thème
              SwitchListTile(
                title: const Text('Thème sombre'),
                subtitle: const Text('Activer le mode sombre pour ce thème'),
                value: _isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _isDarkTheme = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isCreatingTheme = false;
                      });
                    },
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final newTheme = UserTheme(
                          name: _nameController.text.trim(),
                          primaryColorValue: _primaryColor.value,
                          secondaryColorValue: _secondaryColor.value,
                          isDark: _isDarkTheme,
                        );

                        await userDataProvider.addTheme(newTheme);
                        await userDataProvider.setActiveTheme(newTheme);
                        themeProvider.setCustomTheme(newTheme);

                        setState(() {
                          _isCreatingTheme = false;
                          _nameController.clear();
                        });
                      }
                    },
                    child: const Text('Créer le thème'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector(
      BuildContext context,
      String label,
      Color selectedColor,
      Function(Color) onColorSelected,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showColorPicker(context, selectedColor, onColorSelected);
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'Changer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(
      BuildContext context,
      Color initialColor,
      Function(Color) onColorSelected,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir une couleur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorGrid(
                  [
                    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
                    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
                    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
                    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
                    Colors.brown, Colors.grey, Colors.blueGrey,  // Replace Colors.black
                  ],
                  initialColor,
                  onColorSelected,
                ),
              ],
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

  Widget _buildColorGrid(
      List<MaterialColor> colors,
      Color selectedColor,
      Function(Color) onColorSelected,
      ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        final isSelected = color.value == selectedColor.value;

        return InkWell(
          onTap: () {
            onColorSelected(color);
            Navigator.of(context).pop();
          },
          child: CircleAvatar(
            backgroundColor: color,
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      },
    );
  }
}