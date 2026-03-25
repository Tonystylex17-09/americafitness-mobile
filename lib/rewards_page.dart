import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RewardsPage extends StatefulWidget {
  final String token;
  final int currentPoints;
  final Function onPointsUpdated;

  RewardsPage({
    required this.token,
    required this.currentPoints,
    required this.onPointsUpdated,
  });

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  List<Reward> rewards = [
    Reward(
      id: 1,
      name: '10% de descuento',
      description: '10% de descuento en cualquier membresía',
      pointsRequired: 900,
      icon: Icons.card_giftcard,
    ),
    Reward(
      id: 2,
      name: '15% de descuento',
      description: '15% de descuento en cualquier membresía',
      pointsRequired: 1800,
      icon: Icons.card_giftcard,
    ),
    Reward(
      id: 3,
      name: '25% de descuento + Galleta proteica',
      description: '25% de descuento en membresía + galleta proteica de regalo',
      pointsRequired: 3600,
      icon: Icons.card_giftcard,
    ),
  ];

  Future<void> redeemReward(Reward reward) async {
    if (widget.currentPoints >= reward.pointsRequired) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Premio canjeado'),
          content: Text(
            '¡Felicidades! Has canjeado ${reward.name} por ${reward.pointsRequired} puntos.\n\n'
            'Presenta este código en recepción: ${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onPointsUpdated(widget.currentPoints - reward.pointsRequired);
              },
              child: Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Necesitas ${reward.pointsRequired - widget.currentPoints} puntos más'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Tus Puntos',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  '${widget.currentPoints}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Gana 10 puntos por cada check-in',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                final canRedeem = widget.currentPoints >= reward.pointsRequired;

                return Card(
                  color: Color(0xFF1A1A1A),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: canRedeem ? Colors.red.shade800 : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        reward.icon,
                        color: canRedeem ? Colors.white : Colors.grey,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      reward.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.description,
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${reward.pointsRequired} puntos',
                          style: TextStyle(
                            color: canRedeem ? Colors.red.shade800 : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: canRedeem ? () => redeemReward(reward) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canRedeem ? Colors.red.shade800 : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        canRedeem ? 'Canjear' : 'Bloqueado',
                        style: TextStyle(color: Colors.white),
                      ),
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

class Reward {
  final int id;
  final String name;
  final String description;
  final int pointsRequired;
  final IconData icon;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.icon,
  });
}
