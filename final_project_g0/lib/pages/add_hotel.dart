import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/firestore.dart';

class AddHotelPage extends StatefulWidget {
  final String? docID;
  final Map<String, dynamic>? hotelData;

  AddHotelPage({this.docID, this.hotelData});

  @override
  _AddHotelPageState createState() => _AddHotelPageState();
}

class _AddHotelPageState extends State<AddHotelPage> {
  final FirestoreService fireStoreService = FirestoreService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController hostController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amenitiesController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.hotelData != null) {
      nameController.text = widget.hotelData!['hotel_name'] ?? '';
      addressController.text = widget.hotelData!['address'] ?? '';
      latitudeController.text = (widget.hotelData!['location'] as GeoPoint?)?.latitude.toString() ?? '';
      longitudeController.text = (widget.hotelData!['location'] as GeoPoint?)?.longitude.toString() ?? '';
      hostController.text = widget.hotelData!['host_name'] ?? '';
      descriptionController.text = widget.hotelData!['description'] ?? '';
      amenitiesController.text = (widget.hotelData!['amenities'] as List<dynamic>?)?.cast<String>().join(', ') ?? '';
      contactController.text = widget.hotelData!['contact_info']?['phone'] ?? '';
      emailController.text = widget.hotelData!['contact_info']?['email'] ?? '';
      imageController.text = widget.hotelData!['image_url'] ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    hostController.dispose();
    descriptionController.dispose();
    amenitiesController.dispose();
    contactController.dispose();
    emailController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docID == null ? 'Add Hotel' : 'Update Hotel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Enter hotel name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: InputDecoration(hintText: 'Enter hotel address'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: latitudeController,
              decoration: InputDecoration(hintText: 'Enter latitude'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: longitudeController,
              decoration: InputDecoration(hintText: 'Enter longitude'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: hostController,
              decoration: InputDecoration(hintText: 'Enter host name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'Enter description'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: amenitiesController,
              decoration: InputDecoration(hintText: 'Enter amenities (comma separated)'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: contactController,
              decoration: InputDecoration(hintText: 'Enter contact phone'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: 'Enter email address'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: imageController,
              decoration: InputDecoration(hintText: 'Enter image URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  double latitude = double.parse(latitudeController.text);
                  double longitude = double.parse(longitudeController.text);
                  GeoPoint location = GeoPoint(latitude, longitude);

                  // Extract city from address
                  String address = addressController.text;
                  List<String> addressParts = address.split(',').map((e) => e.trim()).toList();
                  String city = addressParts.length > 2 ? addressParts[2] : '';

                  Map<String, dynamic> hotelData = {
                    'hotel_name': nameController.text,
                    'address': address,
                    'location': location,
                    'city': city,  // Add city field
                    'host_name': hostController.text,
                    'description': descriptionController.text,
                    'amenities': amenitiesController.text.split(', ').toList(),
                    'contact_info': {
                      'phone': contactController.text,
                      'email': emailController.text,
                    },
                    'image_url': imageController.text,
                    'timestamp': Timestamp.now(),
                  };

                  if (widget.docID == null) {
                    await fireStoreService.addHotel(hotelData);
                  } else {
                    await fireStoreService.updateHotel(widget.docID!, hotelData);
                  }

                  Navigator.pop(context);
                } catch (e) {
                  // Handle the error (e.g., show an alert)
                  print('Error: $e');
                }
              },
              child: Text(widget.docID == null ? "Add" : "Update"),
            )
          ],
        ),
      ),
    );
  }
}
