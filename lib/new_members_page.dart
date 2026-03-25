import 'package:flutter/material.dart';

class NewMembersPage extends StatefulWidget {
  final String token;
  final dynamic user;

  NewMembersPage({required this.token, required this.user});

  @override
  _NewMembersPageState createState() => _NewMembersPageState();
}

class _NewMembersPageState extends State<NewMembersPage> {
  String selectedGender = 'hombre';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenderButton('Hombre', 'hombre'),
                SizedBox(width: 20),
                _buildGenderButton('Mujer', 'mujer'),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildDayCard(
                  day: 'DÍA 1',
                  title: selectedGender == 'hombre' ? 'PUSH' : 'LEGS',
                  exercises: selectedGender == 'hombre'
                      ? [
                          'Press de banca plano: 4x8-10',
                          'Press militar con mancuernas: 3x10-12',
                          'Fondos en paralelas: 3x8-10',
                          'Extensiones de tríceps en polea: 3x12',
                          'Elevaciones laterales: 3x15',
                        ]
                      : [
                          'Sentadilla con barra: 4x8-10',
                          'Prensa de piernas: 3x12',
                          'Zancadas con mancuernas: 3x10 por pierna',
                          'Curl femoral acostado: 3x12',
                          'Elevación de talones: 4x15',
                        ],
                ),
                _buildDayCard(
                  day: 'DÍA 2',
                  title: selectedGender == 'hombre' ? 'PULL' : 'PUSH',
                  exercises: selectedGender == 'hombre'
                      ? [
                          'Dominadas lastradas: 4x6-8',
                          'Remo con barra: 3x8-10',
                          'Jalón al pecho: 3x10-12',
                          'Curl de bíceps con barra: 3x10',
                          'Face pull: 3x15',
                        ]
                      : [
                          'Press de banca con mancuernas: 4x8-10',
                          'Press inclinado: 3x10',
                          'Aperturas en polea: 3x12',
                          'Fondos asistidos: 3x8-10',
                          'Elevaciones frontales: 3x12',
                        ],
                ),
                _buildDayCard(
                  day: 'DÍA 3',
                  title: selectedGender == 'hombre' ? 'LEGS' : 'LEGS',
                  exercises: selectedGender == 'hombre'
                      ? [
                          'Sentadilla profunda: 4x6-8',
                          'Peso muerto rumano: 3x8-10',
                          'Prensa inclinada: 3x12',
                          'Curl femoral sentado: 3x12',
                          'Gemelos en prensa: 4x15',
                        ]
                      : [
                          'Sentadilla con mancuerna: 4x10',
                          'Peso muerto: 3x8',
                          'Hip thrust: 3x12',
                          'Aductores máquina: 3x15',
                          'Gemelos de pie: 4x15',
                        ],
                ),
                _buildDayCard(
                  day: 'DÍA 4',
                  title: selectedGender == 'hombre' ? 'PUSH' : 'PULL',
                  exercises: selectedGender == 'hombre'
                      ? [
                          'Press inclinado con mancuernas: 4x8-10',
                          'Press militar con barra: 3x8-10',
                          'Aperturas en polea: 3x12',
                          'Tríceps en polea: 3x12',
                          'Elevaciones posteriores: 3x15',
                        ]
                      : [
                          'Remo en máquina: 4x10',
                          'Jalón al pecho agarre abierto: 3x10',
                          'Remo con mancuerna: 3x10 por brazo',
                          'Curl con mancuerna: 3x12',
                          'Pájaro en polea: 3x15',
                        ],
                ),
                _buildDayCard(
                  day: 'DÍA 5',
                  title: selectedGender == 'hombre' ? 'PULL' : 'LEGS',
                  exercises: selectedGender == 'hombre'
                      ? [
                          'Remo en máquina: 4x8-10',
                          'Jalón al pecho agarre cerrado: 3x10',
                          'Remo con mancuerna: 3x10',
                          'Curl concentrado: 3x12',
                          'Encogimientos de hombros: 3x15',
                        ]
                      : [
                          'Sentadilla frontal: 4x8',
                          'Desplantes con mancuerna: 3x10 por pierna',
                          'Extensión de cuadriceps: 3x12',
                          'Curl femoral tumbado: 3x12',
                          'Gemelos sentado: 4x15',
                        ],
                ),
                _buildDayCard(
                  day: 'DÍA 6',
                  title: selectedGender == 'hombre' ? 'LEGS' : 'LEGS',
                  exercises: selectedGender == 'hombre'
                      ? [
                          'Peso muerto: 4x5-6',
                          'Sentadilla hack: 3x8-10',
                          'Prensa unilateral: 3x10',
                          'Curl femoral acostado: 3x12',
                          'Gemelos en máquina: 4x15',
                        ]
                      : [
                          'Hip thrust con barra: 4x10',
                          'Peso muerto rumano con mancuerna: 3x10',
                          'Zancadas laterales: 3x10',
                          'Aductores máquina: 3x15',
                          'Gemelos en prensa: 4x15',
                        ],
                ),
                _buildDayCard(
                  day: 'DÍA 7',
                  title: 'DESCANSO',
                  exercises: ['Recuperación activa: caminata 30 min', 'Estiramientos', 'Hidratación'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String label, String gender) {
    bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade800 : Colors.grey[800],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.red.shade800 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard({
    required String day,
    required String title,
    required List<String> exercises,
  }) {
    return Card(
      color: Color(0xFF1A1A1A),
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade800,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    day.substring(4),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: exercises.map((exercise) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 20,
                        color: Colors.red.shade800,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          exercise,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
