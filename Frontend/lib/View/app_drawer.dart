import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Provider/app_provider.dart';

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
              appProvider.selectAndProcessJsonFile();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image, color: Colors.black),
            title: const Text('Download Image'),
            onTap: () {
              final appProvider = Provider.of<AppProvider>(context, listen: false);
              appProvider.downloadImage();
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
              appProvider.downloadJsonFile();
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
              appProvider.downloadGCodeFile();
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
              appProvider.clearData();
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

