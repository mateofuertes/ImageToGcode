import 'package:http/http.dart' as http;
import 'dart:convert';

/// [ControlServices] manages handles interaction with the backend for controlling the cnc machine.
class ControlServices {

  /// Base URL of the backend server
  final String baseUrl;

  /// Constructor to initialize the [baseUrl] of the server.
  ControlServices({required this.baseUrl});

  /// Communicate with the backend to send a specific move command to the cnc machine.
  Future<String> sendMoveCommand(String axis, String direction, distance) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/move'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'axis': axis,
          'increment': distance,
          'direction': direction
        }),
      );

      if (response.statusCode == 200) {
        return 'Move command successful: ${response.body}';
      } else {
        return 'Failed to send move command: ${response.body}';
      }

    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Communicate with the backend to send an specific spindle action to the cnc machine.
  Future<String> sendSpindleCommand(String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/control'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'command': action}),
    );

    if (response.statusCode == 200) {
      return 'Spindle command successful: ${response.body}';
    } else {
      return 'Failed to send spindle command: ${response.body}';
    }
  }

  /// Communicate with the backend to run the generated g-code in the cnc machine.
  Future<String> runGCode() async {
    final response = await http.post(
      Uri.parse('$baseUrl/runGcode'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return 'G-code run successful: ${response.body}';
    } else {
      return 'Failed to run G-code: ${response.body}';
    }
  }

  /// Communicate with the backend to send the safety stop commands to the cnc machine.
  Future<String> terminate() async {
    final response = await http.post(
      Uri.parse('$baseUrl/safety'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return 'Terminate command successful: ${response.body}';
    } else {
      return 'Failed to terminate: ${response.body}';
    }
  }
}
