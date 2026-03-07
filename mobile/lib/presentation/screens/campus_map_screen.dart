import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Concordia SGW campus centre
const _campusCentre = LatLng(45.4972, -73.5788);

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: _campusCentre,
          initialZoom: 16.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.concordia.campuscompass',
          ),
          // Placeholder marker layers — replaced by data-driven layers in later sprints
          MarkerLayer(
            markers: [
              Marker(
                point: _campusCentre,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.my_location),
        label: const Text('My Location'),
        onPressed: () {
          // TODO: animate map to device location
        },
      ),
    );
  }
}
