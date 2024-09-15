import 'package:flutter/material.dart';

class NewRecipeScreen extends StatefulWidget {
  @override
  _NewRecipeScreenState createState() => _NewRecipeScreenState();
}

class _NewRecipeScreenState extends State<NewRecipeScreen> {
  bool isRegistered = false;
  String recipeName = '';
  int difficulty = 1; // 1: Basic, 2: Intermediate, 3: Advanced

  void onSaveRecipe() {
    setState(() {
      isRegistered = true;
    });

    // Navigate to home screen if recipe is registered
    if (isRegistered) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Recipe'),
        backgroundColor: Color(0xFFB685E8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(),
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
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 1, child: Text('Basic')),
                DropdownMenuItem(value: 2, child: Text('Intermediate')),
                DropdownMenuItem(value: 3, child: Text('Advanced')),
              ],
              onChanged: (value) {
                setState(() {
                  difficulty = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            NewRowSection(),
            const Spacer(),
            ElevatedButton(
              onPressed: onSaveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF84CE),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}

class NewRowSection extends StatefulWidget {
  @override
  _NewRowSectionState createState() => _NewRowSectionState();
}

class _NewRowSectionState extends State<NewRowSection> {
  List<String> stitchRows = [];
  String instructions = '';
  int stitches = 0;
  String error = '';

  void onAddRow() {
    if (instructions.isEmpty || stitches == 0) {
      setState(() {
        error = 'Please enter valid instructions and stitches';
      });
    } else {
      setState(() {
        stitchRows.add('$instructions, $stitches stitches');
        instructions = '';
        stitches = 0;
        error = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var row in stitchRows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(row,
                style: TextStyle(fontSize: 18, color: Color(0xFF5941A9))),
          ),
        TextField(
          decoration: InputDecoration(
            labelText: 'Instructions',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              instructions = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Number of Stitches',
            border: OutlineInputBorder(),
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
            backgroundColor: Color(0xFFFF84CE),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text('Add Row'),
        ),
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(error, style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}
