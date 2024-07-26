import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Provider/app_provider.dart';

class SecondQuadrantWidget extends StatefulWidget {
  const SecondQuadrantWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SecondQuadrantWidgetState createState() => _SecondQuadrantWidgetState();
}

class _SecondQuadrantWidgetState extends State<SecondQuadrantWidget> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
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
                  'Preview of G-code',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: _buildContent(appProvider),
                    ),
                    Positioned(
                      bottom: 16.0,
                      right: 16.0,
                      child: FloatingActionButton(
                        onPressed: () => _generateImage(appProvider),
                        backgroundColor: const Color.fromARGB(255, 0, 71, 104),
                        child: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(AppProvider appProvider) {
    if (appProvider.processing) {
      return const CircularProgressIndicator();
    } else if (!appProvider.hasGCodeImage) {
      return const Text(
        'No information available.',
        style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      );
    } else {
      return appProvider.gcodeImage;
    }
  }

  void _generateImage(AppProvider appProvider) {
    if (appProvider.imageData.isEmpty && !appProvider.hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No information avaiable.')),
      );
    } else {
      appProvider.jsonToGcode();
    }
  }
}

