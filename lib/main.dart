import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ponto_alto/view/homescreen.dart';
import 'package:ponto_alto/view/newrecipe.dart';
import 'package:ponto_alto/view/recipescreen.dart';
import 'package:ponto_alto/view/recipedetail.dart';
import 'package:ponto_alto/view/newproject.dart';
import 'package:ponto_alto/view/projectdetail.dart'; // Importa a tela de detalhe do projeto
import 'package:ponto_alto/viewmodel/recipe_viewmodel.dart';
import 'package:ponto_alto/viewmodel/project_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void logError(String error) {
  debugPrint('App Error: $error');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(SettingsService());

  try {
    await settingsController.loadSettings();
    logError('Settings loaded successfully.');
  } catch (e) {
    logError('Failed to load settings: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecipeViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectViewModel()..fetchAllProjects(), // Garante o carregamento dos projetos ao inicializar
          //..deleteAllProjects(), // Comentei a linha que exclui todos os projetos
        ),
      ],
      child: PontoAltoApp(settingsController: settingsController),
    ),
  );
}

class PontoAltoApp extends StatelessWidget {
  const PontoAltoApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Ponto Alto',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // Inglês
            Locale('pt', ''), // Português
          ],
          home: const NavigationExample(),
          // Adiciona a rota do ProjectDetail
          onGenerateRoute: (settings) {
            if (settings.name == '/recipe-detail') {
              final recipeName = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => RecipeDetails(recipeName: recipeName),
              );
            } else if (settings.name == '/new-project') {
              final recipeName = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => NewProjectScreen(recipeName: recipeName),
              );
            } else if (settings.name == '/project-detail') {
              final projectName = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => ProjectDetail(projectName: projectName),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 1; // Inicializa a tela principal como a HomeScreen
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _selectPage(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _selectPage,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.book),
            label: AppLocalizations.of(context)!.recipesTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.create),
            label: AppLocalizations.of(context)!.newRecipeTitle,
          ),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          _buildNestedNavigator(), // Navigator para a lista de receitas e detalhes
          Consumer<ProjectViewModel>(
            builder: (context, projectViewModel, child) {
              return const HomeScreen(); // A HomeScreen consome os projetos do ProjectViewModel
            },
          ),
          const NewRecipeScreen(),
        ],
      ),
    );
  }

  Widget _buildNestedNavigator() {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/recipe-detail':
            final recipeName = settings.arguments as String;
            builder = (BuildContext _) => RecipeDetails(recipeName: recipeName);
            break;
          case '/new-project':
            final recipeName = settings.arguments as String;
            builder = (BuildContext _) => NewProjectScreen(recipeName: recipeName);
            break;
          case '/project-detail': // Adiciona o tratamento da rota project-detail no Navigator
            final projectName = settings.arguments as String;
            builder = (BuildContext _) => ProjectDetail(projectName: projectName);
            break;
          case '/':
          default:
            builder = (BuildContext _) => const RecipesScreen();
            break;
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
