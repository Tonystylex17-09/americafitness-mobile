import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart';
import 'gyms_page.dart';
import 'training_page.dart';
import 'progress_page.dart';
import 'attendance_page.dart';
import 'shop_page.dart';
import 'cart_page.dart';
import 'rewards_page.dart';
import 'new_members_page.dart';
import 'orders_page.dart';
import 'challenges_page.dart';
import 'ranking_page.dart';
import 'badges_page.dart';
import 'map_page.dart';
import 'nutrition_page.dart';
import 'background.dart';
import 'notification_service.dart';

class HomePage extends StatefulWidget {
  final String token;
  final User user;

  HomePage({required this.token, required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userPoints = 0;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 13, vsync: this);
    fetchPoints();
    fetchCartCount();
    NotificationService().init();
  }

  Future<void> fetchPoints() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/my-points'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _userPoints = data['total_points'];
      });
    }
  }

  Future<void> fetchCartCount() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/cart'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _cartItemCount = (data['items'] as List).length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 55,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.fitness_center,
                size: 24,
                color: Colors.red.shade800,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'AMÉRICA FITNESS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: 'Sedes'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Entrenamiento'),
            Tab(icon: Icon(Icons.trending_up), text: 'Progreso'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Asistencia'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Tienda'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Premios'),
            Tab(icon: Icon(Icons.favorite), text: 'Only New'),
            Tab(icon: Icon(Icons.history), text: 'Pedidos'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Desafíos'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Ranking'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Insignias'),
            Tab(icon: Icon(Icons.map), text: 'Mapa'),
            Tab(icon: Icon(Icons.restaurant), text: 'Nutrición'),
          ],
          labelColor: Colors.red.shade800,
          unselectedLabelColor: Colors.grey,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.yellow),
                SizedBox(width: 5),
                Text(
                  '$_userPoints',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(width: 15),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.red.shade800),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartPage(token: widget.token)),
                        );
                        fetchCartCount();
                        fetchPoints();
                      },
                    ),
                    if (_cartItemCount > 0)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$_cartItemCount',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            GymsPage(token: widget.token),
            TrainingPage(token: widget.token, user: widget.user),
            ProgressPage(token: widget.token, user: widget.user, points: _userPoints),
            AttendancePage(token: widget.token, user: widget.user),
            ShopPage(token: widget.token),
            RewardsPage(
              token: widget.token,
              currentPoints: _userPoints,
              onPointsUpdated: (newPoints) {
                setState(() {
                  _userPoints = newPoints;
                });
              },
            ),
            NewMembersPage(token: widget.token, user: widget.user),
            OrdersPage(token: widget.token),
            ChallengesPage(token: widget.token),
            RankingPage(token: widget.token),
            BadgesPage(token: widget.token),
            MapPage(token: widget.token),
            NutritionPage(token: widget.token),
          ],
        ),
      ),
    );
  }
}