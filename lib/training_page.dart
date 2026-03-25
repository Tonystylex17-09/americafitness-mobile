import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart';

class TrainingPage extends StatefulWidget {
  final String token;
  final User user;

  TrainingPage({required this.token, required this.user});

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  List<Exercise> exercises = [];
  bool isLoading = true;
  int selectedDay = 1;
  List<int> availableDays = [1, 2, 3, 4, 5, 6];
  Map<int, List<ExerciseRecord>> records = {};

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/my-exercises'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        exercises = data.map((json) => Exercise.fromJson(json)).toList();
        isLoading = false;
      });
      for (var exercise in exercises) {
        fetchRecords(exercise.id);
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRecords(int exerciseId) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/exercise-records/$exerciseId'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        records[exerciseId] = data.map((json) => ExerciseRecord.fromJson(json)).toList();
      });
    }
  }

  Future<void> addNewExercise() async {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nuevo Ejercicio'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: 'Nombre del ejercicio'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = await http.post(
                Uri.parse('http://127.0.0.1:8000/exercises'),
                headers: {
                  'Authorization': 'Bearer ${widget.token}',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({'name': nameController.text}),
              );
              if (response.statusCode == 200) {
                fetchExercises();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ejercicio agregado')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${response.body}')),
                );
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteExercise(int exerciseId, String exerciseName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar ejercicio'),
        content: Text('¿Estás seguro de eliminar "$exerciseName"? Se perderán todos sus registros.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = await http.delete(
                Uri.parse('http://127.0.0.1:8000/exercises/$exerciseId'),
                headers: {'Authorization': 'Bearer ${widget.token}'},
              );
              if (response.statusCode == 200) {
                fetchExercises();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ejercicio eliminado')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al eliminar')),
                );
              }
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> addNewDay() async {
    int newDay = availableDays.length + 1;
    setState(() {
      availableDays.add(newDay);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Día $newDay agregado')),
    );
  }

  Future<void> addRecord(int exerciseId) async {
    TextEditingController setsController = TextEditingController();
    TextEditingController weightController = TextEditingController();
    TextEditingController dayController = TextEditingController(text: selectedDay.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar registro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dayController,
              decoration: InputDecoration(labelText: 'Día'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: setsController,
              decoration: InputDecoration(labelText: 'Series (ej: 3x8)'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final response = await http.post(
                Uri.parse('http://127.0.0.1:8000/exercise-record'),
                headers: {
                  'Authorization': 'Bearer ${widget.token}',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'exercise_id': exerciseId,
                  'day_number': int.parse(dayController.text),
                  'sets': int.parse(setsController.text.split('x')[0]),
                  'weight': double.parse(weightController.text),
                  'notes': setsController.text,
                }),
              );
              if (response.statusCode == 200) {
                fetchRecords(exerciseId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registro agregado')),
                );
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector de días con botón +
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...availableDays.map((day) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDay = day;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: selectedDay == day ? Colors.red.shade800 : Colors.grey[800],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Día $day',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.red.shade800),
                          onPressed: addNewDay,
                          tooltip: 'Agregar día',
                        ),
                      ],
                    ),
                  ),
                ),

                // Botón para agregar ejercicio
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    onPressed: addNewExercise,
                    icon: Icon(Icons.add),
                    label: Text('Agregar ejercicio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                    ),
                  ),
                ),

                // Lista de ejercicios
                Expanded(
                  child: exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fitness_center, size: 80, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'No tienes ejercicios aún',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: addNewExercise,
                                child: Text('Agregar primer ejercicio'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            final exerciseRecords = records[exercise.id] ?? [];
                            final dayRecord = exerciseRecords.firstWhere(
                              (r) => r.dayNumber == selectedDay,
                              orElse: () => ExerciseRecord(id: -1, exerciseId: exercise.id, dayNumber: selectedDay, sets: 0, weight: 0, notes: '', createdAt: DateTime.now()),
                            );

                            return Card(
                              color: Color(0xFF1A1A1A),
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: ExpansionTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        exercise.name,
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () => deleteExercise(exercise.id, exercise.name),
                                    ),
                                  ],
                                ),
                                subtitle: dayRecord.id != -1
                                    ? Text(
                                        'Día $selectedDay: ${dayRecord.notes} x ${dayRecord.weight} kg',
                                        style: TextStyle(color: Colors.red.shade800),
                                      )
                                    : Text('Sin registro', style: TextStyle(color: Colors.grey)),
                                trailing: IconButton(
                                  icon: Icon(Icons.add, color: Colors.red.shade800),
                                  onPressed: () => addRecord(exercise.id),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: exerciseRecords.map((record) {
                                        return ListTile(
                                          title: Text(
                                            'Día ${record.dayNumber}',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            '${record.notes} x ${record.weight} kg',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                          trailing: Text(
                                            '${record.createdAt.day}/${record.createdAt.month}',
                                            style: TextStyle(color: Colors.red.shade800),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class Exercise {
  final int id;
  final String name;

  Exercise({required this.id, required this.name});

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ExerciseRecord {
  final int id;
  final int exerciseId;
  final int dayNumber;
  final int sets;
  final double weight;
  final String notes;
  final DateTime createdAt;

  ExerciseRecord({
    required this.id,
    required this.exerciseId,
    required this.dayNumber,
    required this.sets,
    required this.weight,
    required this.notes,
    required this.createdAt,
  });

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) {
    return ExerciseRecord(
      id: json['id'],
      exerciseId: json['exercise_id'],
      dayNumber: json['day_number'],
      sets: json['sets'],
      weight: json['weight'].toDouble(),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}