import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GoogleMapPage extends StatelessWidget {
  const GoogleMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.4223, -122.0849), // Initial map location
              zoom: 14.0,
            ),
          ),
          Positioned(
            top: 30.0, // Distance from the top edge
            left: 20.0, // Distance from the left edge
            child: CircleButton(Icons.menu), // Custom circle button with menu icon
          ),
          Positioned(
            top: 30.0, // Distance from the top edge
            right: 20.0, // Distance from the right edge
            child: CircleButton(Icons.person), // Custom circle button with profile icon
          ),
        ],
      ),
      bottomNavigationBar: BottomContainer(), // Adding bottom container
    );
  }
}

class CircleButton extends StatelessWidget {
  final IconData icon;

  const CircleButton(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Add functionality for the circle button here
      },
      child: Container(
        margin: const EdgeInsets.only(),
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, // Icon passed as parameter
          color: Colors.black,
        ),
      ),
    );
  }
}

class BottomContainer extends StatefulWidget {
  const BottomContainer({super.key});

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
        SafetySetting( HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ]
    );

    final content = [Content.text(_textController.text)];
    final response = await geminiVisionProModel.generateContent(content);
    // Assuming `response.text` is the way to get the generated text from the response.
    // Adjust the property name based on the actual API of GenerateContentResponse.
    final String? generatedText = response.text; 
    print(generatedText);
    _textController.text = generatedText!;
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
                                  ElevatedButton(
                                    onPressed: () {
                                      askGemini();
                                    },
                                    child: const Text('Ask Gemini'),
                                  )
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
              height: 160,
              child: TextField(
                controller: _textController,
                enabled: false,
                maxLines: 5, // Increase this value to increase the height of the TextField
                decoration: InputDecoration(
                  hintText: '',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(height: 2), // Increase this value to increase line spacing
              ),
            ),
          )
        ],
      ),
    );
  }
}



