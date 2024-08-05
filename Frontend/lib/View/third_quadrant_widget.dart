import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/Provider/app_provider.dart';

class ThirdQuadrantWidget extends StatefulWidget {
  const ThirdQuadrantWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ThirdQuadrantWidgetState createState() => _ThirdQuadrantWidgetState();
}

class _ThirdQuadrantWidgetState extends State<ThirdQuadrantWidget> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _faxController = TextEditingController();
  final _facultyController = TextEditingController();
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _faxController.dispose();
    _facultyController.dispose();
    _positionController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void saveData() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    final dataEmpty = _nameController.text.isEmpty &&
        _addressController.text.isEmpty &&
        _phoneController.text.isEmpty &&
        _emailController.text.isEmpty &&
        _faxController.text.isEmpty &&
        _facultyController.text.isEmpty &&
        _positionController.text.isEmpty &&
        _companyController.text.isEmpty &&
        _websiteController.text.isEmpty;
        
    final imageData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'fax': _faxController.text,
      'faculty': _facultyController.text,
      'position': _positionController.text,
      'company': _companyController.text,
      'website': _websiteController.text,
    };
    if (dataEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No information to save')),
      );
      return;
    }
    try {
      appProvider.updateJson(imageData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final imageData = appProvider.imageData;

        _nameController.text = imageData['name'] ?? '';
        _addressController.text = imageData['address'] ?? '';
        _phoneController.text = imageData['phone'] ?? '';
        _emailController.text = imageData['email'] ?? '';
        _faxController.text = imageData['fax'] ?? '';
        _facultyController.text = imageData['faculty'] ?? '';
        _positionController.text = imageData['position'] ?? '';
        _companyController.text = imageData['company'] ?? '';
        _websiteController.text = imageData['website'] ?? '';

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: const Color.fromARGB(255, 0, 71, 104),
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Data obtained',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Name:',
                        hintText: 'Not obtained',
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Address:',
                        hintText: 'Not obtained',
                        controller: _addressController,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Phone:',
                        hintText: 'Not obtained',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Email:',
                        hintText: 'Not obtained',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Fax:',
                        hintText: 'Not obtained',
                        controller: _faxController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Faculty:',
                        hintText: 'Not obtained',
                        controller: _facultyController,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Position:',
                        hintText: 'Not obtained',
                        controller: _positionController,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Company:',
                        hintText: 'Not obtained',
                        controller: _companyController,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    CustomCard(
                      fieldData: FieldData(
                        label: 'Website:',
                        hintText: 'Not obtained',
                        controller: _websiteController,
                        keyboardType: TextInputType.url,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: saveData,
            backgroundColor: const Color.fromARGB(255, 0, 71, 104),
            child: const Icon(Icons.save, color: Colors.white),
          ),
        );
      },
    );
  }
}

class FieldData {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;

  FieldData({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.keyboardType,
  });
}

class CustomCard extends StatelessWidget {
  final FieldData fieldData;

  const CustomCard({super.key, required this.fieldData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[50],
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                fieldData.label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: fieldData.controller,
                keyboardType: fieldData.keyboardType,
                cursorColor: const Color.fromARGB(255, 0, 71, 104),
                decoration: InputDecoration(
                  hintText: fieldData.hintText,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 236, 239, 241)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 0, 71, 104)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}