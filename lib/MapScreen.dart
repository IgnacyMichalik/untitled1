import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'main.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentLocation;
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Map'),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: currentLocation ?? LatLng(0.0, 0.0),
          zoom: 13.0,
          onTap: (tapPosition, latLng) {
            setState(() {
              currentLocation = latLng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              if (currentLocation != null)
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: currentLocation!,
                  builder: (ctx) => Container(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToOtherScreen();
        },
        backgroundColor: Colors.lightGreen,
        child: Icon(Icons.arrow_forward),

      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        mapController.move(currentLocation!, 13.0);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _navigateToOtherScreen() {
    if (currentLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavePage(location: currentLocation!),
        ),
      );
    } else {
      print('Location not available');
    }
  }
}
