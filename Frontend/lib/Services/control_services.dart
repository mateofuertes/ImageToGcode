import 'package:http/http.dart' as http;
import 'dart:convert';

class ControlServices {
  
  final String baseUrl;
  ControlServices({required this.baseUrl});

  String selectedDistance = '0.1';
  List<String> distances = ['0.01', '0.1', '1', '5', '10'];

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