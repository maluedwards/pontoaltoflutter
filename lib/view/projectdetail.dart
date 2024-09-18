import 'package:flutter/material.dart';
import 'package:ponto_alto/model/projectrepository.dart';
import 'package:ponto_alto/model/reciperepository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ponto_alto/viewmodel/project_viewmodel.dart';

class ProjectDetail extends StatefulWidget {
  final String projectName;

  const ProjectDetail({super.key, required this.projectName});

  @override
  _ProjectDetailState createState() => _ProjectDetailState();
}

class _ProjectDetailState extends State<ProjectDetail> {
  late Future<Map<String, dynamic>?> projectFuture;
  late Future<List<Map<String, dynamic>>> stitchRowsFuture;
  late Future<String?> recipeNameFuture;

  final ProjectRepository _projectRepository = ProjectRepository();
  final RecipeRepository _recipeRepository = RecipeRepository();

  int currentStitch = 0;
  int doneStitches = 0;
  int totalStitches = 0; // Now fetched from the database

  @override
  void initState() {
    super.initState();
    stitchRowsFuture = Future.value([]);
    recipeNameFuture = Future.value(null);
    _loadProjectDetails();
  }

  void _loadProjectDetails() {
    projectFuture = _projectRepository.getProjectByName(widget.projectName);
    projectFuture.then((project) {
      if (project != null) {
        final recipeId = project['recipe_id'];
        stitchRowsFuture = _recipeRepository.getStitchRowsForRecipe(recipeId);
        recipeNameFuture = _recipeRepository.getRecipeNameById(recipeId);

        setState(() {
          doneStitches = project['done_stitches'];
          currentStitch = project['current_stitch'];
        });

        // Fetch the total stitches from the recipe table
        _recipeRepository.getTotalStitchesById(recipeId).then((total) {
          setState(() {
            totalStitches = total ?? 0; // Handle null in case of missing data
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Project name
        title: Text(
            '${AppLocalizations.of(context)!.projectDetailTitle}: ${widget.projectName}'),
        backgroundColor: const Color(0xFFB685E8),
      ),
      body: FutureBuilder(
        future:
            Future.wait([projectFuture, stitchRowsFuture, recipeNameFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    '${AppLocalizations.of(context)!.errorMessage}: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final project = snapshot.data![0] as Map<String, dynamic>?;
            final stitchRows = snapshot.data![1] as List<Map<String, dynamic>>;
            final recipeName = snapshot.data![2] as String?;

            if (project == null) {
              return Center(
                  child: Text(
                      AppLocalizations.of(context)!.projectNotFoundMessage));
            }

            int currentRow = _calculateCurrentRow(currentStitch, stitchRows);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.projectField}: ${project['project_name']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF84CE),
                    ),
                  ),
                  const SizedBox(height: 8),
                  //recipe name
                  Text(
                    '${AppLocalizations.of(context)!.recipeField}: ${recipeName ?? AppLocalizations.of(context)!.recipeNotFound}',
                    style:
                        const TextStyle(fontSize: 18, color: Color(0xFFFF84CE)),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalizations.of(context)!.stitchRowsLabel,
                    style:
                        const TextStyle(fontSize: 20, color: Color(0xFF5941A9)),
                  ),
                  const SizedBox(height: 10),
                  //Total stitches
                  Text(
                      '${AppLocalizations.of(context)!.totalStitches}: $totalStitches'),
                  //List of stitch rows
                  Expanded(
                    child: ListView.builder(
                      itemCount: stitchRows.length,
                      itemBuilder: (context, index) {
                        final row = stitchRows[index];
                        bool isCurrentRow = currentRow == (index + 1);
                        Color textColor = isCurrentRow
                            ? const Color(0xFFFF84CE)
                            : Colors.black;

                        return ListTile(
                          title: Text(
                            '${AppLocalizations.of(context)!.rowLabel} ${index + 1}: ${row['instructions']}',
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: Text(
                              '${row['stitches']} ${AppLocalizations.of(context)!.stitchesField}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStitchControlButtons(),
                  const SizedBox(height: 20),
                  _buildFinalizeButton(context, project['project_id']),
                ],
              ),
            );
          }
          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }

  int _calculateCurrentRow(
      int currentStitch, List<Map<String, dynamic>> stitchRows) {
    int cumulativeStitches = 0;
    for (int i = 0; i < stitchRows.length; i++) {
      cumulativeStitches += stitchRows[i]['stitches'] as int;

      if (currentStitch <= cumulativeStitches) {
        return i + 1;
      }
    }
    return stitchRows.length;
  }

  //Buttons construction
  Widget _buildStitchControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //- BUTTON
        ElevatedButton(
          onPressed: currentStitch > 0
              ? () {
                  setState(() {
                    //subctract 1 from currentstitch
                    currentStitch--;
                    //update db
                    _projectRepository.updateProjectStitch(
                        currentStitch, widget.projectName);
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB685E8)
                .withOpacity(currentStitch > 0 ? 1 : 0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('-'),
        ),
        //Text of stitches
        const SizedBox(width: 20),
        Text(
          '$currentStitch',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 20),
        //+ BUTTON
        ElevatedButton(
          onPressed: currentStitch < totalStitches
              ? () {
                  setState(() {
                    //add 1 to current stitch
                    currentStitch++;
                    //update db
                    _projectRepository.updateProjectStitch(
                        currentStitch, widget.projectName);
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB685E8)
                .withOpacity(currentStitch < totalStitches ? 1 : 0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('+'),
        ),
      ],
    );
  }

  Widget _buildFinalizeButton(BuildContext context, int projectId) {
    return Center(
      child: ElevatedButton(
        onPressed: currentStitch == totalStitches
            ? () async {
                await _projectRepository.deleteProject(projectId);
                Provider.of<ProjectViewModel>(context, listen: false)
                    .fetchAllProjects();
                Navigator.pop(context);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF84CE)
              .withOpacity(currentStitch == totalStitches ? 1 : 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(AppLocalizations.of(context)!.finalizeProjectButton),
      ),
    );
  }
}
