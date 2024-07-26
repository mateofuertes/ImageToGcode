import 'package:flutter/material.dart';

class FourthQuadrantWidget extends StatefulWidget {
  const FourthQuadrantWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FourthQuadrantWidgetState createState() => _FourthQuadrantWidgetState();
}

class _FourthQuadrantWidgetState extends State<FourthQuadrantWidget> {
  String _selectedStep = '1mm';
  final List<String> _steps = ['0.01mm', '0.1mm', '1mm', '5mm', '10mm'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(246, 233, 233, 239),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: const Color.fromARGB(255, 0, 71, 104),
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Control Buttons',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                            ),
                            child: const Icon(Icons.arrow_upward, color: Colors.white)
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                                ),
                                child: const Icon(Icons.arrow_back, color: Colors.white)
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                                ),
                                child: const Icon(Icons.arrow_downward, color: Colors.white)
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                                ),
                                child: const Icon(Icons.arrow_forward, color: Colors.white)
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                            ),
                            child: const Icon(Icons.arrow_circle_up, color: Colors.white)
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                            ),
                            child: const Icon(Icons.arrow_circle_down, color: Colors.white)
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Align(
                      alignment: Alignment.center,
                      child:DropdownButton<String>(
                        value: _selectedStep,
                        items: _steps.map((String step) {
                          return DropdownMenuItem<String>(
                            value: step,
                            child: Text(step),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStep = newValue!;
                          });
                        },
                        hint: const Text('Step size'),
                      ),
                    ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                  ),
                  child: const Text('Start', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                  ),
                  child: const Text('Stop', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                  ),
                  child: const Text('Reset', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 164, 0, 0)),
                  ),
                  child: const Text('Abort', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}