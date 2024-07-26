import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Provider/app_provider.dart';
import 'package:app/View/first_quadrant_widget.dart';
import 'package:app/View/second_quadrant_widget.dart';
import 'package:app/View/third_quadrant_widget.dart';
import 'package:app/View/fourth_quadrant_widget.dart';
import 'package:app/View/app_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MaterialApp(
        title: 'Image to G-code',
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final String help = 'This application allows you to convert images to G-code, which is a language '
                      'used to control CNC machines. You can upload an image, process it to generate '
                      'G-code, and preview the result. The G-code can then be used with compatible '
                      'CNC machines to produce physical objects based on the uploaded image.\n\n'
                      'To use this app, simply upload an image by clicking the "Upload Image" button. '
                      'Tesseract OCR will then process the image to extract text information. '
                      'This information will be classified in different categories for generating G-code. '
                      'You can also edit the extracted information and save it to generate new G-code.\n\n'
                      'The image, JSON file and the G-code can be downloaded in the Drawer menu.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to G-code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('About this App'),
                    content: Text(help),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                    backgroundColor: Colors.white,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: const QuadrantsWidget(),
      drawer: const AppDrawer(),
    );
  }
}

class QuadrantsWidget extends StatelessWidget {
  const QuadrantsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: FirstQuadrantWidget(),
              ),
              Expanded(
                child: SecondQuadrantWidget(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ThirdQuadrantWidget(),
              ),
              Expanded(
                child: FourthQuadrantWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}