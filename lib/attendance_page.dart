import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'models.dart';

class AttendancePage extends StatefulWidget {
  final String token;
  final User user;

  AttendancePage({required this.token, required this.user});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<CheckIn> checkIns = [];
  bool isLoading = true;
  bool isCheckedIn = false;
  int? activeCheckInId;
  bool showQR = false;

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/my-attendance'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        checkIns = data.map((json) => CheckIn.fromJson(json)).toList();
        activeCheckInId = checkIns.firstWhere(
          (c) => c.checkOutTime == null,
          orElse: () => CheckIn(id: -1, gymId: 0, checkInTime: DateTime.now()),
        ).id;
        isCheckedIn = activeCheckInId != -1;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> doCheckIn() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/check-in'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Check-in exitoso! +10 puntos'),
            ],
          ),
          backgroundColor: Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      fetchAttendance();
      setState(() {
        showQR = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en check-in')),
      );
    }
  }

  Future<void> doCheckOut() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/check-out'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      fetchAttendance();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-out exitoso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en check-out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isCheckedIn ? null : () {
                            setState(() {
                              showQR = !showQR;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text('ASISTENCIA', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isCheckedIn ? doCheckOut : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text('Check-out', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),

                if (showQR && !isCheckedIn)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Tu código QR para check-in',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: QrImageView(
                            data: 'CHECKIN|${widget.user.id}',
                            version: QrVersions.auto,
                            size: 200,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Muestra este código al personal del gimnasio',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showQR = false;
                            });
                          },
                          child: Text('Cerrar', style: TextStyle(color: Colors.red.shade800)),
                        ),
                      ],
                    ),
                  ),

                if (!showQR)
                  Expanded(
                    child: ListView.builder(
                      itemCount: checkIns.length,
                      itemBuilder: (context, index) {
                        final checkIn = checkIns[index];
                        return Card(
                          color: Color(0xFF1A1A1A),
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                          child: ListTile(
                            leading: Icon(
                              checkIn.checkOutTime == null ? Icons.login : Icons.logout,
                              color: checkIn.checkOutTime == null ? Colors.red.shade800 : Colors.grey,
                            ),
                            title: Text(
                              '${checkIn.checkInTime.day}/${checkIn.checkInTime.month}/${checkIn.checkInTime.year}',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Entrada: ${checkIn.checkInTime.hour}:${checkIn.checkInTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: checkIn.checkOutTime != null
                                ? Text(
                                    'Salida: ${checkIn.checkOutTime!.hour}:${checkIn.checkOutTime!.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : Chip(
                                    label: Text('Activo', style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.red.shade800,
                                  ),
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
