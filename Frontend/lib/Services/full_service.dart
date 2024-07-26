import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class FullService {
  
  final String baseUrl;
  FullService({required this.baseUrl});

  // Process image
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

  // Send image to the server
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
