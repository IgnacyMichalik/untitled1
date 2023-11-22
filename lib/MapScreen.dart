import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class LocationData {
  double latitude;
  double longitude;

  LocationData({required this.latitude, required this.longitude});
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LocationData? currentLocation;
  late Position currentPosition;
  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    getLocationPermission();
  }

  Future<void> getLocationPermission() async {
    // Check if location permissions are already granted
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      // If permissions are granted, get the location
      await getLocation();
    } else {
      // If permissions are not granted, request them from the user
      PermissionStatus newStatus = await Permission.locationWhenInUse.request();
      if (newStatus.isGranted) {
        // If the user grants permissions, get the location
        await getLocation();
      }
    }
  }

  Future<void> getLocation() async {
    try {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = LocationData(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude,
        );
      });
      mapController.move(
        LatLng(
          currentLocation!.latitude,
          currentLocation!.longitude,
        ),
        13.0,
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> saveLocation(LocationData locationData) async {
    final ParseObject newLocation = ParseObject('Location')
      ..set('latitude', locationData.latitude)
      ..set('longitude', locationData.longitude);

    try {
      await newLocation.save();
      print('Location saved successfully!');
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(
            currentLocation?.latitude ?? 0.0,
            currentLocation?.longitude ?? 0.0,
          ),
          zoom: 13.0,
          onTap: (tapPosition, latLng) {
            setState(() {
              currentLocation = LocationData(
                latitude: latLng.latitude,
                longitude: latLng.longitude,
              );
            });
          },
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (hasGesture) {
              currentLocation = null;
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(
                  currentLocation?.latitude ?? 0.0,
                  currentLocation?.longitude ?? 0.0,
                ),
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
        mapController: mapController, // Set the mapController
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentLocation != null) {
            saveLocation(currentLocation!);
          } else {
            print('Location data is null');
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SavePage()),
          );
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
