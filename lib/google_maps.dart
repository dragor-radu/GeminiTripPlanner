import 'package:flutter/material.dart';
import 'package:gemini_app/profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_place/google_place.dart';
import 'dart:convert';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GoogleMapPageState createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  late GoogleMapController _mapController;
  double _zoomLevel = 14.0; // Initial zoom level
  LatLng _location = const LatLng(44.44593474461629, 26.092247495861677); // Initial location
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void setZoomLevel(double zoomLevel, LatLng location) {
    setState(() {
      _zoomLevel = zoomLevel;
      _location = location;
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _location,
            zoom: _zoomLevel,
          ),
        ),
      );
    });
  }

  void drawPolyline(List<LatLng> points) {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route_${DateTime.now().millisecondsSinceEpoch}'),
          points: points,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  void addMarker(LatLng location) {
    try{
      setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(location.toString()),
          position: location,
        )
      );
    });
    } catch (e) {
      print("Error adding marker: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure the scaffold resizes when the keyboard is shown
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _location, // Initial map location
              zoom: _zoomLevel,
            ),
            markers: _markers,
            polylines: _polylines, // Include the polylines in the GoogleMap widget
          ),
          const Positioned(
            top: 30.0, // Distance from the top edge
            left: 20.0, // Distance from the left edge
            child: CircleButton(icon: Icons.menu), // Custom circle button with menu icon
          ),
            Positioned(
            top: 30.0, // Distance from the top edge
            right: 20.0, // Distance from the right edge
            child: CircleButton(
              icon: Icons.person,
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              },
            ), // Custom circle button with profile icon
            ),
        ],
      ),
      bottomNavigationBar: BottomContainer(setZoomLevel: setZoomLevel, addMarker: addMarker, drawPolyline: drawPolyline), // Passing setZoomLevel method
    );
  }
}

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const CircleButton({required this.icon, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

class BottomContainer extends StatefulWidget {
  final Function(double, LatLng) setZoomLevel;
  final Function(LatLng) addMarker;
  final Function(List<LatLng>) drawPolyline;

  const BottomContainer({required this.setZoomLevel, super.key, required this.addMarker, required this.drawPolyline});

  @override
  // ignore: library_private_types_in_public_api
  _BottomContainerState createState() => _BottomContainerState();
}

class TravelPlan {
  final String time;
  final String location;

  TravelPlan({
    required this.time,
    required this.location,
  });

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      time: json['time'],
      location: json['location'],
    );
  }
}

class _BottomContainerState extends State<BottomContainer> {
  String? _selectedCategory;
  String? _selectedTime;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  late GenerativeModel geminiVisionProModel;
  late GenerativeModel geminiProModel;
  LatLng currentLoc = const LatLng(44.43361315183571, 26.078571568160005);

  final googlePlace = GooglePlace('AIzaSyAGMCybMYeFmciGpwkCg633OHTMqsXbsCk');
  List<AutocompletePrediction> predictions = [];

  List<TravelPlan> travelPlans = []; // List to hold generated travel plans

  Future<void> fetchLocationDetails(String location) async {
    try {
      var result = await googlePlace.autocomplete.get(location);

      if (result != null &&
          result.predictions != null &&
          result.predictions!.isNotEmpty) {
        var placeId = result.predictions![0].placeId;
        var details = await googlePlace.details.get(placeId.toString());

        if (details != null && details.result != null) {
          var location = details.result!.geometry?.location;
          if (location != null) {
            var lat = location.lat;
            var lng = location.lng;

            print("Latitude: $lat, Longitude: $lng");
            LatLng secondLocation = LatLng(lat!, lng!);
            widget.setZoomLevel(16.0, secondLocation);

            // Check if addMarker and drawPolyline are called properly
            widget.addMarker(LatLng(lat, lng));
            print("Marker added.");

            widget.drawPolyline([
              currentLoc,
              secondLocation,
            ]);
            currentLoc = secondLocation;
            print("Polyline drawn.");
            // Use await to wait for the delay to complete
            await Future.delayed(const Duration(seconds: 4));
          }
        } else {
          print("Details or result is null.");
        }
      } else {
        print("No predictions found.");
      }
    } catch (e) {
      print("Error retrieving location details: $e");
    }
  }

  Future<void> askGemini() async {
    print("button pressed");
    print(_textController.text);
    RegExp locationRegex = RegExp(r'Location:\s*(.*)', caseSensitive: false);
    Match? match = locationRegex.firstMatch(_textController.text);
    String city = "";
    if (match != null) {
      city = match.group(1)!;
      print('Extracted Locationa: $city');
    } else {
      print('Location not found in text.');
    }
    geminiVisionProModel = GenerativeModel(
      model: 'gemini-1.0-pro',
      apiKey: 'AIzaSyBvQr96K6rinQ_31BqRD7fGIMdsZ1egUfg', // Replace with your actual API key
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );
    final response = await geminiVisionProModel.generateContent([
      Content.multi([
        TextPart(_textController.text),
        TextPart("With the location, time, and category provided, create an itinerary with the most popular locations to visit based only on the category."),
        TextPart("Return the output just as JSON without any 'json' text used in the following format with Capital letters:"),
        TextPart(" '1': {'time1 like day 1 or day2 or Morning and Midnight', 'location': 'location' for every location }} "),
        TextPart("here are some examples"),
        TextPart(" { '1': { time: Day 1 Morning, location: 'Museum1}, '2': { time: Day 1 Noon, location: 'Museum2}, '3': { time: Day 1 Evening, location: 'Museum3} }"),
        TextPart('and use "" for JSON'),
        TextPart("also return only places from the input city, if there are few, create just for that few")
      ]),
    ]);

    final String generatedText = response.text!;
    print(generatedText);

    // Parse the generated JSON response
    Map<String, dynamic> jsonMap = jsonDecode(generatedText);
    List<TravelPlan> generatedTravelPlans = jsonMap.entries.map((entry) {
      Map<String, dynamic> value = entry.value; // e.g., {"time": "evening", "location": "Romanian Athenaeum"}
      print(TravelPlan.fromJson(value));
      return TravelPlan.fromJson(value);
    }).toList();

    setState(() {
      travelPlans = generatedTravelPlans;
    });

    List<String> locations = [];
    jsonMap.forEach((key, value) {
      locations.add(value['location'] + city);
    });

    for (String location in locations){
      await fetchLocationDetails(location);
    }
    widget.setZoomLevel(14.0, currentLoc);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _updateTextField() {
    String location = _locationController.text.isNotEmpty ? _locationController.text : 'Location';
    String category = _selectedCategory ?? 'Category';
    String time = _selectedTime ?? 'Time';
    _textController.text = 'Location: $location\nCategory: $category\nTime: $time';
  }

  @override
  Widget build(BuildContext context) {
    double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height / 3, // Height of bottom container
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 5, // Spread radius
              blurRadius: 7, // Blur radius
              offset: const Offset(0, 3), // Offset
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Row(
                children: [
                  SizedBox(
                    width: 70.0,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20.0, // Distance from the top edge
                          left: 20.0, // Distance from the left edge
                          child: GestureDetector(
                            onTap: () {
                              askGemini();
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5), // Shadow color
                                    spreadRadius: 2, // Spread radius
                                    blurRadius: 3, // Blur radius
                                    offset: const Offset(0, 2), // Offset
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.waving_hand, // AI icon
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10.0,
                          left: 20,
                          child: Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller: _locationController,
                                        decoration: InputDecoration(
                                          hintText: 'Location',
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onChanged: (text) {
                                          _updateTextField();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    DropdownButton<String>(
                                      isDense: true,
                                      value: _selectedCategory,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Historical',
                                          child: Text('Historical'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Cultural',
                                          child: Text('Cultural'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Art',
                                          child: Text('Art'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCategory = value;
                                          _updateTextField();
                                        });
                                      },
                                      hint: const Text('Category'),
                                    ),
                                    const SizedBox(width: 10),
                                    DropdownButton<String>(
                                      isDense: true,
                                      value: _selectedTime,
                                      items: const [
                                        DropdownMenuItem(
                                          value: '1 Day',
                                          child: Text('1 Day'),
                                        ),
                                        DropdownMenuItem(
                                          value: '2 Days',
                                          child: Text('2 Days'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTime = value;
                                          _updateTextField();
                                        });
                                      },
                                      hint: const Text('Time'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: travelPlans.length,
                itemBuilder: (context, index) {
                  return ClipRRect( // Ensures clipping outside the card
                    borderRadius: BorderRadius.circular(15.0), // Match the Card's borderRadius
                    child: Card(
                      elevation: 4.0, // Adds shadow beneath the card
                      shadowColor: Colors.grey.withOpacity(0.5), // Shadow color with some transparency
                      margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Rounded corners
                        side: const BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      clipBehavior: Clip.antiAlias, // Ensures content inside the card is clipped
                      child: ListTile(
                        title: Text(travelPlans[index].time, style: const TextStyle(fontWeight: FontWeight.bold)), // Bold text for title
                        subtitle: Text(travelPlans[index].location),
                        tileColor: Colors.white, // Background color of the ListTile
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Padding inside the ListTile
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

