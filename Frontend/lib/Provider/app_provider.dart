import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:app/Services/full_service.dart';
import 'package:app/Services/complement_services.dart';
import 'dart:convert';

class AppProvider extends ChangeNotifier {
  
  // Variables
  bool _processing = false;
  bool _hasImage = false;
  bool _hasGCodeImage = false;
  Image _image = Image.asset('assets/input.png');
  File? _imageFile;
  String? _webImageUrl;
  Map _imageData = {};
  Image _gcodeImage = Image.asset('assets/output.png');
  String _selectedStep = '1mm';
  final List<String> _steps = ['0.01mm', '0.1mm', '1mm', '5mm', '10mm'];
  final FullService _apiService = FullService(baseUrl: 'http://localhost:5000');
  final ComplementServices _complementServices = ComplementServices(baseUrl: 'http://localhost:5000');
  String? _errorMessage;

  // Getters
  bool get processing => _processing;
  bool get hasImage => _hasImage;
  bool get hasGCodeImage => _hasGCodeImage;
  String get selectedStep => _selectedStep;
  List<String> get steps => _steps;
  Image get image => _image;
  File? get imageFile => _imageFile;
  String? get webImageUrl => _webImageUrl;
  Map get imageData => _imageData;
  Image get gcodeImage => _gcodeImage;
  String? get errorMessage => _errorMessage;

  // Setters
  void setProcessing(bool processing) {
    _processing = processing;
    notifyListeners();
  }

  void setHasImage(bool hasImage) {
    _hasImage = hasImage;
    notifyListeners();
  }

  void setHasGCodeImage(bool hasGCodeImage) {
    _hasGCodeImage = hasGCodeImage;
    notifyListeners();
  }

  void setImage(Image image) {
    _image = image;
    notifyListeners();
  }

  void setImageFile(File imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }

  void setWebImageUrl(String url) {
    _webImageUrl = url;
    notifyListeners();
  }

  void setImageData(Map data) {
    _imageData = data;
    notifyListeners();
  }

  void setGcodeImage(Image image) {
    _gcodeImage = image;
    setHasGCodeImage(true);
    notifyListeners();
  }

  void setSelectedStep(String step) {
    _selectedStep = step;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /* -- Methods -- */

  // Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // Send image to the server
  Future<void> sendImage() async {
    try {
      _processing = true;
      setErrorMessage('Process completed');
      notifyListeners();
      ImageProvider imageProvider = _image.image;
      final temp = await _apiService.loadImageFromProvider(imageProvider);
      await _apiService.uploadImage(temp);
      final data = await _complementServices.getJson();
      final gcodeImageTemp = await _complementServices.getPreviewImage();
      setGcodeImage(Image.memory(gcodeImageTemp));
      setImageData(data);
      _processing = false;
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to process image: Could not connect to the server');
      _processing = false;
      notifyListeners();
    }
  }

  // Download images
  Future<void> downloadImage() async {
    if (!_hasImage) {
      setErrorMessage('No image to download');
      return;
    }
    
    if (imageFile != null) {
      // Desktop platforms
      File file = imageFile!;
      final directory = await getExternalStorageDirectory();
      final downloadPath = '${directory?.path}/downloaded_image.png';
      await file.copy(downloadPath);
    } else if (webImageUrl != null) {
      if (kIsWeb) {
        // Web platforms
        downloadImageWeb(webImageUrl!);
      } else {
        // Mobile platforms
        String url = webImageUrl!;
        Dio dio = Dio();
        final directory = await getExternalStorageDirectory();
        final downloadPath = '${directory?.path}/downloaded_image.png';
        await dio.download(url, downloadPath);
      }
    }
  }

  void downloadImageWeb(String url) {
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "downloaded_image.png")
      ..click();
  }

  // Download JSON files
  Future<void> downloadJsonFile() async {
    if (_imageData.isEmpty) {
      setErrorMessage('No data to download');
      return;
    }
    try {
      await _complementServices.downloadJson();
    } catch (e) {
      setErrorMessage('Failed to download JSON file: $e');
    }
  }

  // Download GCode files
  Future<void> downloadGCodeFile() async {
    if (_imageData.isEmpty) {
      setErrorMessage('No gcode has been generated');
      return;
    }
    try {
      await _complementServices.downloadFile('nc');
    }
    catch (e) {
      setErrorMessage('Failed to download GCode file: $e');
    }
  }

  // Convert JSON to GCode
  void jsonToGcode() async {
    if (_imageData.isEmpty) {
      setErrorMessage('No data to convert');
      return;
    }
    setProcessing(true);
    notifyListeners();
    try {
      await _complementServices.jsonToGcode(dataToUint8List(imageData));
      final data = await _complementServices.getJson();
      final gcodeImageTemp = await _complementServices.getPreviewImage();
      setGcodeImage(Image.memory(gcodeImageTemp));
      setImageData(data);

    } catch (e) {
      setErrorMessage('Failed to convert JSON to GCode: $e');
    }
    setProcessing(false);
    notifyListeners();
  }

  Uint8List dataToUint8List(Map<dynamic, dynamic> map) {
    String jsonString = jsonEncode(map);
    Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
    return bytes;
  }

  // Update data (Json) in the server
  void updateJson(Map<String, dynamic> newData) async {
    await _complementServices.updateJson(dataToUint8List(newData));
    final data = await _complementServices.getJson();
    _imageData = data;
    notifyListeners();
  }

  // Upload a JSON file
  Future<void> selectAndProcessJsonFile() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.json';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final html.File file = files.first;
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          final String jsonString = reader.result as String;
          final Map<String, dynamic> jsonData = json.decode(jsonString);
          setImageData(jsonData);
        });
        reader.readAsText(file);
      }
    });
    setErrorMessage('JSON file uploaded successfully');
    notifyListeners();
  }

  // Clear data
  void clearData() {
    _image = Image.asset('assets/input.png');
    _imageFile = null;
    _webImageUrl = null;
    _imageData = {};
    _gcodeImage = Image.asset('assets/output.png');
    _selectedStep = '1mm';
    _hasImage = false;
    _hasGCodeImage = false;
    notifyListeners();
  }
}
