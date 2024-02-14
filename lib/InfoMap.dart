import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:geolocator/geolocator.dart';
class MapScreenv2 extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenv2> {
  List<Marker> markers = [];
  LocationData? currentLocation;
  LatLng? initialCenter;
  Map<Marker, List<Map<String, dynamic>>> groupData = {};

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
    fetchDataFromBack4App();
  }

  Future<void> fetchCurrentLocation() async {
    var location = Location();
    try {
      currentLocation = await location.getLocation();
      setState(() {
        initialCenter = LatLng(currentLocation?.latitude ?? 0, currentLocation?.longitude ?? 0);
      });
    } catch (e) {
      print('Błąd podczas pobierania aktualnej lokalizacji: $e');
    }
  }

  Future<void> fetchDataFromBack4App() async {
    final query = QueryBuilder(ParseObject('Zgloszenie'));
    final response = await query.query();

    if (response.success && response.results != null) {
      final List<dynamic> data = response.results!;

      final List<Map<String, double>> validCoordinates = [];
      for (var item in data) {
        final newCoordinate = {
          'latitude': (item['latitude'] as num).toDouble(),
          'longitude': (item['longitude'] as num).toDouble(),
        };

        bool shouldAdd = true;

        for (var existingCoordinate in validCoordinates) {
          final distance = Geolocator.distanceBetween(
            newCoordinate['latitude']!,
            newCoordinate['longitude']!,
            existingCoordinate['latitude']!,
            existingCoordinate['longitude']!,
          );


        }

        if (shouldAdd) {
          validCoordinates.add(newCoordinate);
        }
      }

      if (validCoordinates.isNotEmpty) {
        final groupedMarkers = groupMarkers(validCoordinates, data);

        groupedMarkers.forEach((key, value) {
          createAverageMarker(value, data);
        });
      } else {
        setState(() {
          markers = data.map((item) {
            return Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(
                (item['latitude'] as num).toDouble(),
                (item['longitude'] as num).toDouble(),
              ),
              builder: (ctx) {
                return GestureDetector(
                  onTap: () {
                    showMarkerPopup(context, item);
                  },
                  child: Icon(Icons.place),
                );
              },
            );
          }).toList();
        });
      }
    } else {
      print('Błąd podczas pobierania danych: ${response.error!.message}');
    }
  }

  Map<int, List<Map<String, double>>> groupMarkers(
      List<Map<String, double>> validCoordinates,
      List<dynamic> data,
      ) {
    Map<int, List<Map<String, double>>> groupedMarkers = {};
    Set<int> usedIndexes = {};

    for (int i = 0; i < validCoordinates.length; i++) {
      if (usedIndexes.contains(i)) {
        continue;
      }

      List<Map<String, double>> group = [];
      group.add(validCoordinates[i]);
      usedIndexes.add(i);

      for (int j = i + 1; j < validCoordinates.length; j++) {
        double distance = Geolocator.distanceBetween(
          validCoordinates[i]['latitude']!,
          validCoordinates[i]['longitude']!,
          validCoordinates[j]['latitude']!,
          validCoordinates[j]['longitude']!,
        );

        if (distance <= 20 && !usedIndexes.contains(j)) {
          group.add(validCoordinates[j]);
          usedIndexes.add(j);
        }
      }

      if (group.isNotEmpty) {
        groupedMarkers[i] = group;
      }
    }

    return groupedMarkers;
  }

  void createAverageMarker(List<Map<String, double>> group, List<dynamic> data) {
    double sumLatitude = 0;
    double sumLongitude = 0;

    for (var coordinate in group) {
      sumLatitude += coordinate['latitude']!;
      sumLongitude += coordinate['longitude']!;
    }

    final avgLatitude = sumLatitude / group.length;
    final avgLongitude = sumLongitude / group.length;

    final reportsData = data
        .where((item) =>
        group.any((coordinate) =>
        (coordinate['latitude'] == item['latitude'] &&
            coordinate['longitude'] == item['longitude'])))
        .map((item) => {
      'Kategoria': item['Kategoria'],
      'Opis': item['Opis'],
      'createdAt': item['createdAt'],
      'file': item['file'],
    })
        .toList();

    final avgMarker = Marker(
      width: 40.0,
      height: 40.0,
      point: LatLng(avgLatitude, avgLongitude),
      builder: (ctx) {
        return GestureDetector(
          onTap: () {
            showMarkerListPopup(context, reportsData, group);
          },
          child: Icon(Icons.place),
        );
      },
    );

    setState(() {
      markers.add(avgMarker);
      groupData[avgMarker] = reportsData;
    });
  }

  void showMarkerPopup(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isImageLoading = true; // Dodaj zmienną boolowską, aby śledzić stan ładowania zdjęcia

            return AlertDialog(
              title: Text('Zgłoszenie'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kategoria: ${item['Kategoria']}'),
                  Text('Opis: ${item['Opis']}'),
                  Text('Utworzono: ${item['createdAt']}'),
                  item['file'] != null
                      ? GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                backgroundColor: Colors.lightGreen,
                                title: Text('Powiększone zdjęcie'),
                              ),
                              body: Center(
                                child: isImageLoading // Wyświetl animację tylko wtedy, gdy zdjęcie jest w trakcie ładowania
                                    ? CircularProgressIndicator() // Tutaj można użyć innego rodzaju animacji, jeśli jest to lepsze dla interfejsu
                                    : Hero(
                                  tag: 'imageHero',
                                  child: Image.network(
                                    item['file']['url'],
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'imageHero',
                      child: Image.network(
                        item['file']['url'],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            isImageLoading = false; // Zmiana stanu na 'false', gdy zdjęcie zostało załadowane
                            return child;
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
                  )
                      : Container(),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreen, // Kolor tła przycisku
                    onPrimary: Colors.black, // Kolor tekstu na przycisku
                    // Inne opcje stylizacji, takie jak padding, shape, etc.
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Zamknij'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showMarkerListPopup(
      BuildContext context, List<Map<String, dynamic>> reportsData, List<Map<String, double>> coordinates) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Zgłoszenia'),
          content: SizedBox(
            height: 200,
            width: 200,
            child: ListView.builder(
              itemCount: reportsData.length,
              itemBuilder: (BuildContext context, int index) {
                final reportData = reportsData[index];

                return ListTile(
                  title: Text('Zgłoszenie ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kategoria: ${reportData['Kategoria']}'),
                      Text('Opis: ${reportData['Opis']}'),
                      Text('Utworzono: ${reportData['createdAt']}'),
                    ],
                  ),
                  onTap: () {
                    showMarkerPopup(context, reportData);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, // Kolor tła przycisku
                onPrimary: Colors.black, // Kolor tekstu na przycisku
                // Inne opcje stylizacji, takie jak padding, shape, etc.
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Zamknij'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Zgłoszenia w twojej okolicy'),
      ),
      body: initialCenter == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          center: initialCenter!,
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
    );
  }
}