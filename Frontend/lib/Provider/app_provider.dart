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
import 'package:app/Services/control_services.dart';
import 'dart:convert';

/// [AppProvider] is a ChangeNotifier that manages the app's logic.
/// It handles image manipulation, data conversion and instantiation of the services
/// for communication with the backend.

class AppProvider extends ChangeNotifier {
  
  /// Indicates whether a process is ongoing.
  bool _processing = false;

  /// Indicates whether an image has been loaded into the app.
  bool _hasImage = false;

  /// Indicates whether a G-code image has been generated.
  bool _hasGCodeImage = false;

  /// The image currently loaded into the app.
  Image _image = Image.asset('assets/input.png');

  /// The image file, used for desktop platforms.
  File? _imageFile;

  /// The URL of the image on the web, used for web platforms.
  String? _webImageUrl;

  /// The image data in JSON format.
  Map _imageData = {};

  /// The image generated from GCode.
  Image _gcodeImage = Image.asset('assets/output.png');

  /// The selected step for moving machine axes.
  String _selectedStep = '1';

  /// List of available steps for axis movement.
  final List<String> _steps = ['0.01', '0.1', '1', '5', '10'];

  /// API services used for interacting with the backend.
  final FullService _apiService = FullService(baseUrl: 'http://localhost:5000');
  final ComplementServices _complementServices = ComplementServices(baseUrl: 'http://localhost:5000');
  final ControlServices _controlService = ControlServices(baseUrl: 'http://localhost:5000');

  /// The current error message, if any.
  String? _errorMessage;

  /// ---- Getters ----
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

  /// ---- Setters (Notify listeners included) ----
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

  /// ---- Methods for processing data and images. -----
  ///
  /// Clears the error message and notifies listeners.
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sends the loaded image to the server for processing.
  /// If the operation fails, an error message is set.
  Future<void> sendImage() async {
    try {
      setProcessing(true);
      setErrorMessage('Process completed');
      
      // Converts the image to a format that can be sent.
      ImageProvider imageProvider = _image.image;
      
      // Uploads the image to the server.
      final temp = await _apiService.loadImageFromProvider(imageProvider);
      await _apiService.uploadImage(temp);
      
      // Retrieves the resulting JSON and g-code preview from the processing.
      final data = await _complementServices.getJson();
      final gcodeImageTemp = await _complementServices.getPreviewImage();

      // Update data
      setGcodeImage(Image.memory(gcodeImageTemp));
      setImageData(data);
      setProcessing(false);

    } catch (e) {
      setErrorMessage('Failed to process image: Could not connect to the server');
      setProcessing(false);
    }
  }

  /// Downloads the processed image from the server.
  /// Handles desktop, mobile, and web platforms.
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

  /// Downloads the image from the web using HTML5 for web platforms.
  void downloadImageWeb(String url) {
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "downloaded_image.png")
      ..click();
  }

  /// Downloads a JSON file from the server.
  /// If there is no data, an error message is set.
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

   /// Downloads a GCode file from the server.
  /// If no GCode has been generated, an error message is set.
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

  /// Converts JSON data to GCode using the backend service.
  /// Updates the generated GCode image and JSON data.
  void jsonToGcode() async {
    if (_imageData.isEmpty) {
      setErrorMessage('No data to convert');
      return;
    }
    
    try {
      setProcessing(true);
      await _complementServices.jsonToGcode(dataToUint8List(imageData));
      final data = await _complementServices.getJson();
      final gcodeImageTemp = await _complementServices.getPreviewImage();
      
      setGcodeImage(Image.memory(gcodeImageTemp));
      setImageData(data);
      setProcessing(false);
      
    } catch (e) {
      setErrorMessage('Failed to convert JSON to GCode: $e');
      setProcessing(false);
    }
    
  }

  /// Converts a data map to a byte list (Uint8List).
  Uint8List dataToUint8List(Map<dynamic, dynamic> map) {
    String jsonString = jsonEncode(map);
    Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
    return bytes;
  }

  /// Updates the JSON data on the server and retrieves the updated data.
  void updateJson(Map<String, dynamic> newData) async {
    try {
      setProcessing(true);
      await _complementServices.updateJson(dataToUint8List(newData));
      final data = await _complementServices.getJson();
      setImageData(data);
      setProcessing(false);
    } catch (e) {
      setErrorMessage('Failed to update information: $e');
      setProcessing(false);
    }
  }

  /// Uploads a JSON file from the local filesystem and processes it.
  /// Only available on web platforms.
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
  }

  /// Clears all image data and resets the app to its initial state.
  void clearData() {
    _image = Image.asset('assets/input.png');
    _imageFile = null;
    _webImageUrl = null;
    _imageData = {};
    _gcodeImage = Image.asset('assets/output.png');
    _selectedStep = '1';
    _hasImage = false;
    _hasGCodeImage = false;
    notifyListeners();
  }

  /// ---- Methods for controlling the cnc machine. ----
  ///
  /// Sends a move command to the server for a specific axis and direction.
  /// If the operation fails, an error message is set.
  Future<void> sendMoveCommand(String axis, String direction) async {
    try {
      final response = await _controlService.sendMoveCommand(axis, direction, selectedStep);
      setErrorMessage(response);
    } catch (e) {
      setErrorMessage('Error: $e');
    }
  }

  /// Sends a spindle command (start/stop) to the server.
  /// If the operation fails, an error message is set.
  Future<void> sendSpindleCommand(String action) async {
    try {
      final response = await _controlService.sendSpindleCommand(action);
      setErrorMessage(response);
    } catch (e) {
      setErrorMessage('Error: $e');
    }
  }

  /// Sends a command to run the generated GCode.
  /// If no GCode has been generated, an error message is set.
  Future<void> runGCode() async {
    if (_hasGCodeImage == false) {
      setErrorMessage('No G-code to run');
      return;
    }
    try {
      final response = await _controlService.runGCode();
      setErrorMessage(response);
    } catch (e) {
      setErrorMessage('Error: $e');
    }
  }

  /// Sends a command to safely stop the spindle.
  /// If the operation fails, an error message is set.
  Future<void> terminate() async {
    try {
      final response = await _controlService.terminate();
      setErrorMessage(response);
    } catch (e) {
      setErrorMessage('Error: $e');
    }
  }

}
