import 'package:flutter/material.dart';
import 'package:ponto_alto/view/homescreen.dart';
import 'package:ponto_alto/view/newrecipe.dart';
import 'package:ponto_alto/view/recipescreen.dart';

import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(const PontoAltoApp());
}

class PontoAltoApp extends StatelessWidget {
  const PontoAltoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ponto Alto',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const NavigationExample(),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.purple,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.book),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.home)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(
              label: Text('2'),
              child: Icon(Icons.create),
            ),
            label: 'New Recipe',
          ),
        ],
      ),
      body: <Widget>[
        /// Notifications page
        RecipesScreen(),

        /// Home page
        HomeScreen(projects: []),

        /// Messages page
        NewRecipeScreen(),
      ][currentPageIndex],
    );
  }
}
