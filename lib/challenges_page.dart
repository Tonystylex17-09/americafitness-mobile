import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChallengesPage extends StatefulWidget {
  final String token;

  ChallengesPage({required this.token});

  @override
  _ChallengesPageState createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  List challenges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChallenges();
  }

  Future<void> fetchChallenges() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/active-challenges'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        challenges = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProgress(int challengeId, int progress) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/update-challenge-progress/$challengeId?progress_value=$progress'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      fetchChallenges();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Progreso actualizado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : challenges.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No hay desafíos activos',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Nuevos desafíos cada semana',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: challenges.length,
                  itemBuilder: (context, index) {
                    final challenge = challenges[index];
                    final progressPercent = (challenge['progress'] / challenge['goal_value']) * 100;

                    return Card(
                      color: Color(0xFF1A1A1A),
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade800,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIconForGoal(challenge['goal_type']),
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    challenge['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (challenge['completed'])
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'COMPLETADO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              challenge['description'] ?? 'Completa el desafío para ganar puntos',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progreso: ${challenge['progress']}/${challenge['goal_value']}',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                Text(
                                  '🏆 ${challenge['reward_points']} pts',
                                  style: TextStyle(color: Colors.yellow, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progressPercent / 100,
                                backgroundColor: Colors.grey[800],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade800),
                                minHeight: 8,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Vence: ${_formatDate(challenge['end_date'])}',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                            if (!challenge['completed'])
                              SizedBox(height: 12),
                            if (!challenge['completed'])
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _showUpdateDialog(challenge['id'], challenge['goal_type']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade800,
                                      ),
                                      child: Text('Actualizar progreso'),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showUpdateDialog(int challengeId, String goalType) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar progreso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Cuántos ${_getGoalLabel(goalType)} has completado?'),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              int value = int.tryParse(controller.text) ?? 0;
              if (value > 0) {
                updateProgress(challengeId, value);
              }
              Navigator.pop(context);
            },
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  String _getGoalLabel(String goalType) {
    switch (goalType) {
      case 'checkins':
        return 'check-ins';
      case 'workouts':
        return 'entrenamientos';
      case 'points':
        return 'puntos';
      default:
        return 'actividades';
    }
  }

  IconData _getIconForGoal(String goalType) {
    switch (goalType) {
      case 'checkins':
        return Icons.check_circle;
      case 'workouts':
        return Icons.fitness_center;
      case 'points':
        return Icons.star;
      default:
        return Icons.emoji_events;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
