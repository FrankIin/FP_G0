import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore.dart';

class AddRoomPage extends StatefulWidget {
  final String hotelID;
  final String? roomID;
  final Map<String, dynamic>? roomData;

  AddRoomPage({required this.hotelID, this.roomID, this.roomData});

  @override
  _AddRoomPageState createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final FirestoreService fireStoreService = FirestoreService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController guestsController = TextEditingController();
  final TextEditingController bedsController = TextEditingController();
  final TextEditingController amenitiesController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController(); // New controller for price

  @override
  void initState() {
    super.initState();
    if (widget.roomData != null) {
      nameController.text = widget.roomData!['name'] ?? '';
      descriptionController.text = widget.roomData!['description'] ?? '';
      guestsController.text = widget.roomData!['guests'].toString();
      bedsController.text = widget.roomData!['beds'].toString();
      amenitiesController.text = (widget.roomData!['amenities'] as List<dynamic>).join(', ');
      imageUrlController.text = widget.roomData!['images'][0] ?? '';
      priceController.text = widget.roomData!['price'].toString(); // Set price value
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomID == null ? 'Add Room' : 'Edit Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Enter room name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'Enter room description'),
            ),
            TextField(
              controller: guestsController,
              decoration: InputDecoration(hintText: 'Enter room guests'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bedsController,
              decoration: InputDecoration(hintText: 'Enter number of beds'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: amenitiesController,
              decoration: InputDecoration(hintText: 'Enter amenities (comma separated)'),
            ),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(hintText: 'Enter image URL'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(hintText: 'Enter room price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                try {
                  Map<String, dynamic> roomData = {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'guests': int.parse(guestsController.text),
                    'beds': int.parse(bedsController.text),
                    'amenities': amenitiesController.text.split(', ').toList(),
                    'images': [imageUrlController.text],
                    'price': double.parse(priceController.text), // Add price to room data
                    'booked': false,
                    'timestamp': Timestamp.now(),
                  };

                  if (widget.roomID == null) {
                    fireStoreService.addRoom(widget.hotelID, roomData);
                  } else {
                    fireStoreService.updateRoom(widget.hotelID, widget.roomID!, roomData);
                  }

                  Navigator.pop(context);
                } catch (e) {
                  // Handle the error (e.g., show an alert)
                  print('Error: $e');
                }
              },
              child: Text(widget.roomID == null ? 'Add Room' : 'Update Room'),
            ),
          ],
        ),
      ),
    );
  }
}
