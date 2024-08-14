import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:app/Provider/app_provider.dart';

/// [FirstQuadrantWidget] is a widget that allows the user to upload an image 
/// and displays it within the UI. It has two states:
/// - No image uploaded: Shows a button to upload an image.
/// - Image uploaded: Displays the selected image.
class FirstQuadrantWidget extends StatefulWidget {

  const FirstQuadrantWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FirstQuadrantWidgetState createState() => _FirstQuadrantWidgetState();
}

/// Creates the widget's state.
class _FirstQuadrantWidgetState extends State<FirstQuadrantWidget> {
  
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Container(
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: const Color.fromARGB(255, 0, 71, 104),
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Original Image',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: appProvider.imageFile == null && appProvider.webImageUrl == null
                ? Center(
                    child: ElevatedButton(
                      onPressed: () => _pickImage(appProvider), // Calls the method to pick an image.
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 71, 104)),
                      ),
                      child: const Text('Upload Image', style: TextStyle(color: Colors.white)),
                    ),
                  )
                : kIsWeb
                    ? Image.network(appProvider.webImageUrl!)
                    : Image.file(appProvider.imageFile!),
          ),
        ],
      ),
    );
  }

  /// [_pickImage] allows the user to select an image from their device.
  /// It then updates the app state with the selected image and triggers processing.
  Future<void> _pickImage(AppProvider appProvider) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        appProvider.clearErrorMessage();
        // Handling the image differently based on the platform (web or mobile/desktop).
        if (kIsWeb) {
          appProvider.setWebImageUrl(pickedFile.path);
          appProvider.setImage(Image.network(appProvider.webImageUrl!));
        } else {
          final file = File(pickedFile.path);
          appProvider.setImageFile(File(pickedFile.path));
          appProvider.setImage(Image.file(file));
        }
        appProvider.setHasImage(true);
        await appProvider.sendImage();
        if (appProvider.errorMessage != null) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(appProvider.errorMessage!)),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image processed successfully')),
          );
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

}
