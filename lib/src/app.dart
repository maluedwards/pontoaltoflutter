import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ponto_alto/view/homescreen.dart';
import 'package:ponto_alto/view/newrecipe.dart';
import 'package:ponto_alto/view/recipescreen.dart';
import 'package:ponto_alto/view/recipedetail.dart';
import 'package:ponto_alto/view/projectdetail.dart';
import 'package:ponto_alto/view/newproject.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('pt', ''), // Portuguese
          ],
          onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(), // Página inicial sem o parâmetro 'projects'
            '/recipes': (context) => RecipesScreen(),
            '/new-recipe': (context) => const NewRecipeScreen(),
            '/recipe-detail': (context) => RecipeDetails(
              recipeName: ModalRoute.of(context)!.settings.arguments as String,
            ),
            '/new-project': (context) => const NewProjectScreen(recipeName: ''),
            '/project-detail': (context) => ProjectDetail(
              projectName: ModalRoute.of(context)!.settings.arguments as String,
            ),
            SettingsView.routeName: (context) =>
                SettingsView(controller: settingsController),
          },
          // Adicionando o onUnknownRoute para lidar com erros de rota desconhecida
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                  child: Text('Page not found!'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
