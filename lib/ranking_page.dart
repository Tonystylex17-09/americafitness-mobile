import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RankingPage extends StatefulWidget {
  final String token;

  RankingPage({required this.token});

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List ranking = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRanking();
  }

  Future<void> fetchRanking() async {
    final response = await http.get(
      Uri.parse('https://americafitness-production.up.railway.app/ranking'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      setState(() {
        ranking = jsonDecode(response.body);
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
          : ranking.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.leaderboard, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'No hay datos de ranking',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: ranking.length,
                  itemBuilder: (context, index) {
                    final user = ranking[index];
                    final isFirst = index == 0;
                    final isSecond = index == 1;
                    final isThird = index == 2;

                    return Card(
                      color: Color(0xFF1A1A1A),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isFirst
                                ? Colors.amber
                                : isSecond
                                    ? Colors.grey[400]
                                    : isThird
                                        ? Colors.brown
                                        : Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isFirst || isSecond || isThird
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          user['full_name'] ?? user['username'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.yellow),
                            SizedBox(width: 4),
                            Text(
                              '${user['points']} pts',
                              style: TextStyle(color: Colors.yellow),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              'Racha: ${user['streak']}',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                        trailing: isFirst
                            ? Icon(Icons.emoji_events, color: Colors.amber)
                            : isSecond
                                ? Icon(Icons.emoji_events, color: Colors.grey[400])
                                : isThird
                                    ? Icon(Icons.emoji_events, color: Colors.brown)
                                    : null,
                      ),
                    );
                  },
                ),
    );
  }
}
