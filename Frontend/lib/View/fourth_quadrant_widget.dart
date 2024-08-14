import 'package:app/Provider/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/// [FourthQuadrantWidget] is a widget that allows user to control the cnc machine.
/// It has buttons for moving the spindle`s position in different axis (x, y, z),
/// and with different steps/distance (0.01, 0.1, 1, 5, 10)
class FourthQuadrantWidget extends StatefulWidget {
  const FourthQuadrantWidget({super.key});

  @override
  _FourthQuadrantWidgetState createState() => _FourthQuadrantWidgetState();
}

/// Creates the widget state
class _FourthQuadrantWidgetState extends State<FourthQuadrantWidget> {
  @override
  Widget build(BuildContext context) {
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
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
                child: constraints.maxWidth > 600
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _buildControlPanel(appProvider),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _buildControlPanel(appProvider),
                      ),
              ),
              Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 10.0,
                  children: _buildBottomButtons(appProvider, context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Buttons for moving the spindle
  List<Widget> _buildControlPanel(AppProvider appProvider) {
    return [
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => appProvider.sendMoveCommand('Y', '+'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 0, 71, 104)),
              ),
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => appProvider.sendMoveCommand('X', '-'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 0, 71, 104)),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () => appProvider.sendMoveCommand('Y', '-'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 0, 71, 104)),
                  ),
                  child: const Icon(Icons.arrow_downward, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () => appProvider.sendMoveCommand('X', '+'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 0, 71, 104)),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => appProvider.sendMoveCommand('Z', '+'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 0, 71, 104)),
              ),
              child: const Icon(Icons.arrow_circle_up, color: Colors.white),
            ),
            ElevatedButton(
              onPressed: () => appProvider.sendMoveCommand('Z', '-'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 0, 71, 104)),
              ),
              child: const Icon(Icons.arrow_circle_down, color: Colors.white),
            ),
            DropdownButton<String>(
              value: appProvider.selectedStep,
              items: appProvider.steps.map((String step) {
                return DropdownMenuItem<String>(
                  value: step,
                  child: Text(step),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  appProvider.setSelectedStep(newValue!);
                });
              },
              hint: const Text('Step size'),
            ),
          ],
        ),
      ),
    ];
  }

  /// Buttons for sending control commands.
  List<Widget> _buildBottomButtons(AppProvider appProvider, BuildContext context) {
    return [
      ElevatedButton(
          onPressed: () {
            appProvider.runGCode(); // Run generated g-code if exists.
            if (appProvider.errorMessage == 'No G-code to run') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No G-code to run'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 0, 71, 104)),
          ),
          child: const Text('Run',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))),
      ElevatedButton(
          onPressed: () => appProvider.sendSpindleCommand('start'), // Send command to the needle to start spinning.
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 0, 71, 104)),
          ),
          child: const Text('Start',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))),
      ElevatedButton(
          onPressed: () => appProvider.sendSpindleCommand('stop'), // Send command to the needle to stop spinning.
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 0, 71, 104)),
          ),
          child: const Text('Stop',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))),
      ElevatedButton(
          onPressed: () => appProvider.sendSpindleCommand('set'), // Send command to cnc machine to set origin coordinates.
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 0, 71, 104)),
          ),
          child: const Text('Origin',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))),
      ElevatedButton(
          onPressed: () => appProvider.terminate(), // Send command to cnc machine to safety stop the engraving process.
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(const Color.fromARGB(255, 164, 0, 0)),
          ),
          child: const Text('Safety',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))),
    ];
  }
}
