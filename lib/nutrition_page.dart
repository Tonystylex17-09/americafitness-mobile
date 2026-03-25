import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NutritionPage extends StatefulWidget {
  final String token;

  NutritionPage({required this.token});

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final _formKey = GlobalKey<FormState>();
  String selectedSex = 'male';
  String selectedGoal = 'volume';
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  Map<String, dynamic>? nutritionData;
  bool isLoading = false;

  Future<void> calcularNutricion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/calculate-nutrition'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sex': selectedSex,
        'weight': double.parse(weightController.text),
        'height': double.parse(heightController.text),
        'age': int.parse(ageController.text),
        'goal': selectedGoal,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        nutritionData = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al calcular')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Color(0xFF1A1A1A),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Calculadora Nutricional',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedSex,
                        dropdownColor: Color(0xFF1A1A1A),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Sexo',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'male', child: Text('Hombre')),
                          DropdownMenuItem(value: 'female', child: Text('Mujer')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSex = value!;
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedGoal,
                        dropdownColor: Color(0xFF1A1A1A),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Objetivo',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(value: 'volume', child: Text('Volumen (ganar músculo)')),
                          DropdownMenuItem(value: 'definition', child: Text('Definición (perder grasa)')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGoal = value!;
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: weightController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Peso (kg)',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: heightController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Altura (cm)',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: ageController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Edad',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : calcularNutricion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Calcular Plan Nutricional'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (nutritionData != null) ...[
              SizedBox(height: 20),
              Card(
                color: Color(0xFF1A1A1A),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 Resultados',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      _buildInfoRow('IMC', '${nutritionData!['imc']}'),
                      _buildInfoRow('Metabolismo Base', '${nutritionData!['tmb']} kcal'),
                      _buildInfoRow('Calorías Base', '${nutritionData!['calorias_base']} kcal'),
                      _buildInfoRow('Calorías Objetivo', '${nutritionData!['calorias_objetivo']} kcal'),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade800),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🎯 Rango flexible',
                              style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${nutritionData!['rango_calorias']['min']} - ${nutritionData!['rango_calorias']['max']} kcal',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(height: 5),
                            Text(
                              nutritionData!['rango_calorias']['mensaje'],
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Card(
                color: Color(0xFF1A1A1A),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🍽️ Plan de Comidas',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        nutritionData!['plan']['nombre'],
                        style: TextStyle(color: Colors.red.shade800, fontSize: 16),
                      ),
                      Text(
                        nutritionData!['plan']['descripcion'],
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      SizedBox(height: 15),
                      ...(nutritionData!['plan']['comidas'] as List).map((comida) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comida['nombre'],
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            ...(comida['opciones'] as List).map((opcion) {
                              return Padding(
                                padding: EdgeInsets.only(left: 16, top: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.restaurant, size: 14, color: Colors.red.shade800),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        opcion,
                                        style: TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            SizedBox(height: 12),
                          ],
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      Text(
                        '💡 Tips:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      ...(nutritionData!['plan']['tips'] as List).map((tip) {
                        return Padding(
                          padding: EdgeInsets.only(left: 16, top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb, size: 14, color: Colors.yellow),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(tip, style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}