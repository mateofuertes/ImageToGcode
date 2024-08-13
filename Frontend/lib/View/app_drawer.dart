import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Provider/app_provider.dart';

/// [AppDrawer] allows the user to choose between different options such as downloading the image,
/// downloading or uploading json file, downloading g-code, or clearing all data.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              'Image to G-code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.black),
            title: const Text('Upload Json File'),
            onTap: () {
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              appProvider.selectAndProcessJsonFile(); // Upload json file to the server and process it to get g-code.
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image, color: Colors.black),
            title: const Text('Download Image'),
            onTap: () {
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              appProvider.downloadImage(); // Download image from app provider or showing an error message.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(appProvider.errorMessage!))
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black),
            title: const Text('Download Information'),
            onTap: () {
              final appProvider = Provider.of<AppProvider>(context, listen: false); 
              appProvider.downloadJsonFile(); // Download json file from app provider or showing an error message.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(appProvider.errorMessage!))
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download, color: Colors.black),
            title: const Text('Download G-Code'),
            onTap: () {
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              appProvider.downloadGCodeFile(); // Download g-code from app provider or showing an error message.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(appProvider.errorMessage!))
              );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear, color: Colors.black),
            title: const Text('Clear All'),
            onTap: () {
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              appProvider.clearData(); // Clear all data in app provider.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data cleared"))
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
  
}

