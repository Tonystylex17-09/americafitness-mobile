import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart';

class GymsPage extends StatefulWidget {
  final String token;

  GymsPage({required this.token});

  @override
  _GymsPageState createState() => _GymsPageState();
}

class _GymsPageState extends State<GymsPage> {
  List<Gym> gyms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGyms();
  }

  Future<void> fetchGyms() async {
    final response = await http.get(
      Uri.parse('https://americafitness-production.up.railway.app/gyms'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        gyms = data.map((json) => Gym.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: gyms.length,
              itemBuilder: (context, index) {
                final gym = gyms[index];
                return Card(
                  color: Color(0xFF1A1A1A),
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.fitness_center, color: Colors.red.shade800),
                    title: Text(
                      gym.name,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      gym.address,
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.red.shade800),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(gym.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📞 ${gym.phone ?? 'No disponible'}'),
                              SizedBox(height: 5),
                              Text('📧 ${gym.email ?? 'No disponible'}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cerrar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
