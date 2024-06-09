import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/firestore.dart';
import 'hotel_detail.dart'; // Import the hotel detail page
import 'add_hotel.dart';
import 'search_page.dart';  // Import the search page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService fireStoreService = FirestoreService();
  List<DocumentSnapshot> hotelsList = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    getHotels();
  }

  Future<void> getHotels() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await fireStoreService.getHotelsPaginated(limit, lastDocument);

    if (querySnapshot.docs.length < limit) {
      hasMore = false;
    }

    lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

    setState(() {
      isLoading = false;
      hotelsList.addAll(querySnapshot.docs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotels"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddHotelPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            getHotels();
          }
          return false;
        },
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: hotelsList.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = hotelsList[index];
            String docID = document.id;

            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HotelDetailPage(
                      hotelID: docID,
                      hotelName: data['hotel_name'],
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(data['image_url']),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddHotelPage(docID: docID, hotelData: data),
                            ),
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () => fireStoreService.deleteHotel(docID),
                          icon: const Icon(Icons.delete, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () => openRoomBox(hotelID: docID),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void openRoomBox({required String hotelID}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HotelDetailPage(hotelID: hotelID, hotelName: '')),
    );
  }
}
