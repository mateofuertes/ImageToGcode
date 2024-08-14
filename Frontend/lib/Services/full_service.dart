import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// [FullService] handles interaction with the backend server for executing
/// the entire functions to process an image and obtain g-code.
class FullService {

  /// Base URL of the backend server.
  final String baseUrl;

  /// Constructor to initialize the [baseUrl] of the server.
  FullService({required this.baseUrl});

  /// Process image avaiable in the frontend for converting it to a correct format to send it to the backend.
  Future<ui.Image> loadImageFromProvider(ImageProvider imageProvider) async {
    final completer = Completer<ui.Image>();
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    });
    stream.addListener(listener);
    final ui.Image image = await completer.future;
    stream.removeListener(listener);
    return image;
  }

  /// Sends image to the server.
  Future<void> uploadImage(ui.Image image) async {
    final completer = Completer<Uint8List>();

    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes = byteData!.buffer.asUint8List();
    completer.complete(imageBytes);
    
    final bytes = await completer.future;
    
    final uri = Uri.parse('$baseUrl/process');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('image', bytes, filename: 'image.png'));
    
    // ignore: unused_local_variable
    final response = await request.send();    
      
  }
}
