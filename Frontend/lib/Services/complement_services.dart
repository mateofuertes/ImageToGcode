import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class ComplementServices {
  
  final String baseUrl;
  ComplementServices({required this.baseUrl});

  // Get JSON data
  Future<dynamic> getJson() async {
    final response = await http.get(Uri.parse('$baseUrl/json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load JSON');
    }
  }

  // Get G-code plotted preview image
  Future<Uint8List> getPreviewImage() async {
    final response = await http.get(Uri.parse('$baseUrl/preview'));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  // Download JSON file
  Future<void> downloadJson() async {
    final response = await http.get(Uri.parse('$baseUrl/json'));
    if (response.statusCode == 200) {
      if (kIsWeb) {
        _downloadJsonWeb(response.body, 'temp.json');
      } else {
        await _saveJsonMobile(response.body, 'temp.json');
      }
    } else {
      throw Exception('Failed to download JSON');
    }
  }

  // Manage Json download for web apps
  void _downloadJsonWeb(String content, String fileName) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // Manage Json download for mobile apps
  Future<void> _saveJsonMobile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = io.File(path);
    await file.writeAsString(content);
  }

  // Download G-code file
  Future<void> downloadFile(String fileType) async {
    final response = await http.get(Uri.parse('$baseUrl/$fileType'));

    if (response.statusCode == 200) {
      if (kIsWeb) {
        _downloadFileWeb(response.bodyBytes, 'file.$fileType');
      } else {
        await _saveFileMobile(response.bodyBytes, 'file.$fileType');
      }
    } else {
      throw Exception('Failed to download file');
    }
  }

  // Manage web downloads for files
  void _downloadFileWeb(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // Manage mobile app downloads for files
  Future<void> _saveFileMobile(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = io.File(path);
    await file.writeAsBytes(bytes);
  }

  // Upload JSON file to get G-code
  Future<void> jsonToGcode(Uint8List jsonBytes) async {
    final uri = Uri.parse('$baseUrl/processJson');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('json', jsonBytes, filename: 'data.json'));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);
      return result;
    } else {
      throw Exception('Failed to upload JSON file');
    }
  }

  // Update JSON file in the server
  Future<void> updateJson(Uint8List jsonBytes) async {
    final uri = Uri.parse('$baseUrl/updateJson');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('json', jsonBytes, filename: 'data.json'));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final result = json.decode(responseData);
      
      return result;
    } else {
      throw Exception('Failed to upload JSON file');
    }
  }

}
