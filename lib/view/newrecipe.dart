import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ponto_alto/viewmodel/recipe_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ponto_alto/view/recipescreen.dart'; // Importar a tela de receitas

class NewRecipeScreen extends StatefulWidget {
  const NewRecipeScreen({super.key});

  @override
  _NewRecipeScreenState createState() => _NewRecipeScreenState();
}

class _NewRecipeScreenState extends State<NewRecipeScreen> {
  final TextEditingController _recipeNameController = TextEditingController();
  final _newRowSectionKey = GlobalKey<_NewRowSectionState>();
  bool isSaving = false;
  String recipeName = '';
  int difficulty = 1; // 1: Basic, 2: Intermediate, 3: Advanced

  @override
  void dispose() {
    _recipeNameController.dispose();
    super.dispose();
  }

  void onSaveRecipe() async {
    if (recipeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.recipeNameField +
              ' ' +
              AppLocalizations.of(context)!.errorMessage),
        ),
      );
      return;
    }

    final stitchRows = _newRowSectionKey.currentState?.getStitchRows() ?? [];

    if (stitchRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidRowError),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    await Provider.of<RecipeViewModel>(context, listen: false)
        .addRecipe(recipeName, difficulty, stitchRows);

    setState(() {
      isSaving = false;
    });

    // Usar Navigator com MaterialPageRoute para manter a BottomNavigationBar visível
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RecipesScreen(), // Voltando para a tela de receitas
      ),
    );
    Provider.of<RecipeViewModel>(context, listen: false).fetchAllRecipes(); // Atualiza a lista de receitas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newRecipeTitle),
        backgroundColor: const Color(0xFFB685E8),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _recipeNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.recipeNameField,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    recipeName = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: difficulty,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.difficultyField,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: Text(AppLocalizations.of(context)!.difficultyBasic),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text(AppLocalizations.of(context)!.difficultyIntermediate),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text(AppLocalizations.of(context)!.difficultyAdvanced),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    difficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              NewRowSection(key: _newRowSectionKey),
              const SizedBox(height: 20),
              if (isSaving)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                ElevatedButton(
                  onPressed: onSaveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF84CE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(AppLocalizations.of(context)!.saveRecipeButton),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewRowSection extends StatefulWidget {
  const NewRowSection({super.key});

  @override
  _NewRowSectionState createState() => _NewRowSectionState();
}

class _NewRowSectionState extends State<NewRowSection> {
  List<Map<String, dynamic>> stitchRows = [];
  String instructions = '';
  int stitches = 0;
  String error = '';

  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _stitchesController = TextEditingController();

  @override
  void dispose() {
    _instructionsController.dispose();
    _stitchesController.dispose();
    super.dispose();
  }

  void onAddRow() {
    if (instructions.isEmpty || stitches == 0) {
      setState(() {
        error = AppLocalizations.of(context)!.invalidRowError;
      });
    } else {
      setState(() {
        stitchRows.add({
          'instructions': instructions,
          'stitches': stitches,
        });
        instructions = '';
        stitches = 0;

        _instructionsController.clear();
        _stitchesController.clear();
        error = '';
      });
    }
  }

  List<Map<String, dynamic>> getStitchRows() {
    return stitchRows;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var row in stitchRows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${row['instructions']}, ${row['stitches']} ${AppLocalizations.of(context)!.stitchesField}',
              style: const TextStyle(fontSize: 18, color: Color(0xFF5941A9)),
            ),
          ),
        TextField(
          controller: _instructionsController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.instructionsField,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              instructions = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _stitchesController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.numberOfStitchesField,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              stitches = int.tryParse(value) ?? 0;
            });
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onAddRow,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF84CE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(AppLocalizations.of(context)!.addRowButton),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(error, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}
