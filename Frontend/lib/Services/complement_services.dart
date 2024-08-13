import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

/// [ComplementServices] handles interaction with the backend server for processing images,
/// downloading files (JSON, G-code), and uploading data.
/// It abstracts away platform-specific file handling to work seamlessly across mobile, desktop, and web.
class ComplementServices {
  
  /// Base URL of the backend server.
  final String baseUrl;

  /// Constructor to initialize the [baseUrl] of the server.
  ComplementServices({required this.baseUrl});

  /// Retrieves JSON data from the server.
  Future<dynamic> getJson() async {
    final response = await http.get(Uri.parse('$baseUrl/json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load JSON');
    }
  }

  /// Retrieves a preview image of the G-code plotted image from the server.
  /// Returns the image as [Uint8List] (byte data).
  Future<Uint8List> getPreviewImage() async {
    final response = await http.get(Uri.parse('$baseUrl/preview'));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  /// Downloads a JSON file from the server.
  /// Handles the file differently depending on whether the app is running on web or mobile.
  Future<void> downloadJson() async {
    final response = await http.get(Uri.parse('$baseUrl/json'));
    if (response.statusCode == 200) {
      if (kIsWeb) {
        _downloadJsonWeb(response.body, 'temp.json'); // Web Platforms
      } else {
        await _saveJsonMobile(response.body, 'temp.json'); // Mobiles/Desktop Platforms
      }
    } else {
      throw Exception('Failed to download JSON');
    }
  }

  /// Helper method to download JSON files on web platforms.
  /// [content] is the file content, and [fileName] is the name under which the file is saved.
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

  /// Helper method to save JSON files on mobile/desktop platforms.
  Future<void> _saveJsonMobile(String content, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = io.File(path);
    await file.writeAsString(content);
  }

  /// Downloads a G-code file from the server.
  /// Handles the file differently depending on whether the app is running on web or mobile.
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

  /// Helper method to download files on web platforms.
  /// [bytes] are the file's raw bytes, and [fileName] is the name under which the file is saved.
  void _downloadFileWeb(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  /// Helper method to save files on mobile/desktop platforms.
  Future<void> _saveFileMobile(Uint8List bytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = io.File(path);
    await file.writeAsBytes(bytes);
  }

  /// Uploads a JSON file to the server to generate G-code.
  /// [jsonBytes] are the raw bytes of the JSON data.
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

  /// Updates an existing JSON file on the server.
  /// [jsonBytes] are the raw bytes of the JSON data.
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
