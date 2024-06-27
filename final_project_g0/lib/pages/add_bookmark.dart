import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore.dart';

import '../services/firestore.dart';

class AddBookmarkPage extends StatefulWidget {
  final String? docID;
  final Map<String, dynamic>? hotelData;

  AddBookmarkPage({this.docID, this.hotelData});

  @override
  _AddBookmarkPageState createState() => _AddBookmarkPageState();
}

class _AddBookmarkPageState extends State<AddBookmarkPage> {
  final FirestoreService fireStoreService = FirestoreService();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.hotelData != null) {
      nameController.text = widget.hotelData!['collection_name'] ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docID == null ? 'Add Collection' : 'Update Collection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Enter collection name'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                try {

                  Map<String, dynamic> hotelData = {
                    'collection_name': nameController.text,
                    'timestamp': Timestamp.now(),
                  };

                  // await fireStoreService.addBookmark(hotelData);

                  // if (widget.docID == null) {
                  //   await fireStoreService.addHotel(hotelData);
                  // } else {
                  //   await fireStoreService.updateHotel(widget.docID!, hotelData);
                  // }

                  Navigator.pop(context);
                } catch (e) {
                  // Handle the error (e.g., show an alert)
                  print('Error: $e');
                }
              },
              child: Text(widget.docID == null ? "Add" : "Add"),
            )
          ],
        ),
      ),
    );
  }
}