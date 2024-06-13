import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _location, // Initial map location
              zoom: _zoomLevel,
            ),
          ),
          const Positioned(
            top: 30.0, // Distance from the top edge
            left: 20.0, // Distance from the left edge
            child: CircleButton(icon: Icons.menu), // Custom circle button with menu icon
          ),
          const Positioned(
            top: 30.0, // Distance from the top edge
            right: 20.0, // Distance from the right edge
            child: CircleButton(icon: Icons.person), // Custom circle button with profile icon
          ),
        ],
      ),
      bottomNavigationBar: BottomContainer(setZoomLevel: setZoomLevel), // Passing setZoomLevel method
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

  const BottomContainer({required this.setZoomLevel, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomContainerState createState() => _BottomContainerState();
}

class _BottomContainerState extends State<BottomContainer> {
  String? _selectedCategory;
  String? _selectedTime;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  late GenerativeModel geminiVisionProModel;
  late GenerativeModel geminiProModel;

  Future<void> askGemini() async {
    print("button pressed");
    print(_textController.text);
    geminiVisionProModel = GenerativeModel(
      model: 'gemini-1.0-pro',
      apiKey: 'AIzaSyBvQr96K6rinQ_31BqRD7fGIMdsZ1egUfg',
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

    final content = [Content.text(_textController.text)];
    final response = await geminiVisionProModel.generateContent(content);
    // Assuming `response.text` is the way to get the generated text from the response.
    // Adjust the property name based on the actual API of GenerateContentResponse.
    final String? generatedText = response.text; 
    print(generatedText);
    _textController.text = generatedText!;
    print("bfeore");
    LatLng newLocation = const LatLng(44.42784935487525, 26.08695440652212);
    widget.setZoomLevel(16.0, newLocation);
    print("after");
    Future.delayed(const Duration(seconds: 3), () {
      print("5 seconds passed");
      LatLng secondLocation = const LatLng(44.44223704333257, 26.09763610362667);
      widget.setZoomLevel(16.0, secondLocation);
    });
    
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
    return Container(
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
                                Icons.design_services_outlined, // AI icon
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
          Container(
            margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: SizedBox(
              height: 160, // Fixed height for the container
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Enable vertical scrolling
                child: TextField(
                  controller: _textController,
                  readOnly: true, // Use readOnly instead of enabled for scrollability
                  maxLines: null, // Allow unlimited lines
                  decoration: InputDecoration(
                    hintText: '',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: const TextStyle(height: 2), // Adjust line spacing
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}



