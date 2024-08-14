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

/// Main Screen of the app with the scafold for all the widgets.
class HomeScreen extends StatelessWidget {
  
  /// Constructor for [HomeScreen].
  const HomeScreen({super.key});

  /// Help message displayed when using the button on the right side of the app bar.
  final String help = 'This application converts images to G-code, a language used to control CNC machines. '
                      'Upload an image, process it to generate G-code, and preview the result. The G-code '
                      'can then be used with compatible CNC machines to imprint text extracted from the uploaded image.\n\n'
                      'To use this app, click the "Upload Image" button to upload an image. Tesseract OCR will '
                      'process the image to extract text information, which will be classified into different '
                      'categories for generating G-code. You can edit the extracted information and save it '
                      'to generate new G-code.\n\n'
                      'You can download the image, a JSON file with the information extracted, and G-code from '
                      'the Drawer menu. Alternatively, you can upload a JSON file with the information to generate the G-code.\n\n'
                      'Once the G-code is generated, preview it in the "G-code Preview" tab. To execute the G-code '
                      'on a compatible CNC machine, click the "Run G-code" button to send the G-code for execution.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      /// [AppBar] is a widget located at the top of the app that displays the title,
      /// the help button with information about the app and the button to open the appdrawer. 
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
      /// Main widget of the app.
      body: const QuadrantsWidget(),
      /// AppDrawer localized in the left.
      drawer: const AppDrawer(),
    );
  }
}

/// [QuadrantsWidget] is a widget divided into quadrants with the different functionalities of the application.
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
                child: FirstQuadrantWidget(), // To upload the image.
              ),
              Expanded(
                child: SecondQuadrantWidget(), // To visualize the preview of the generated g-code.
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: ThirdQuadrantWidget(), // To modify extracted, uploaded or typed information.
              ),
              Expanded(
                child: FourthQuadrantWidget(), // To control the cnc machine.
              ),
            ],
          ),
        ),
      ],
    );
  }
}
