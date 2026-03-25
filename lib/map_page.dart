import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart';

class MapPage extends StatefulWidget {
  final String token;

  MapPage({required this.token});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Gym> gyms = [];
  bool isLoading = true;
  GoogleMapController? mapController;
  final Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    fetchGyms();
  }

  Future<void> fetchGyms() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/gyms'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        gyms = data.map((json) => Gym.fromJson(json)).toList();
        isLoading = false;
        _addMarkers();
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addMarkers() {
    for (var gym in gyms) {
      if (gym.latitude != null && gym.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(gym.id.toString()),
            position: LatLng(gym.latitude!, gym.longitude!),
            infoWindow: InfoWindow(
              title: gym.name,
              snippet: gym.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Sedes'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(-12.0464, -77.0428),
                zoom: 11,
              ),
              markers: markers,
              onMapCreated: (controller) {
                mapController = controller;
              },
            ),
    );
  }
}