import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/firestore.dart';
import 'room_detail.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirestoreService fireStoreService = FirestoreService();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController guestsController = TextEditingController();
  final TextEditingController bedsController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> searchResults = [];
  List<String> allAddresses = [];

  @override
  void initState() {
    super.initState();
    _fetchAllHotels();
  }

  Future<void> _fetchAllHotels() async {
    QuerySnapshot querySnapshot = await fireStoreService.getAllHotels();
    List<DocumentSnapshot> hotels = querySnapshot.docs;

    setState(() {
      allAddresses = hotels.map((doc) => doc['address'] as String).toList();
    });

    // Debug prints to verify all addresses
    print('All hotel addresses:');
    for (var address in allAddresses) {
      print(address);
    }
  }

  Future<void> _searchHotels() async {
    setState(() {
      isLoading = true;
    });

    String city = cityController.text.trim().toLowerCase();
    int? guests = guestsController.text.isNotEmpty ? int.tryParse(guestsController.text.trim()) : null;
    int? beds = bedsController.text.isNotEmpty ? int.tryParse(bedsController.text.trim()) : null;

    QuerySnapshot hotelSnapshot = await fireStoreService.getAllHotels();

    List<Map<String, dynamic>> results = [];
    for (var hotelDoc in hotelSnapshot.docs) {
      Map<String, dynamic> hotelData = hotelDoc.data() as Map<String, dynamic>;
      String address = hotelData['address'].toLowerCase();

      // Check if the hotel matches the city criteria
      bool matchesCity = city.isEmpty || address.contains(city);

      if (matchesCity) {
        QuerySnapshot roomSnapshot = await fireStoreService.getRooms(hotelDoc.id);
        for (var roomDoc in roomSnapshot.docs) {
          Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
          int roomGuests = roomData['guests'] ?? 0; // Use guests for guests
          int roomBeds = roomData['beds'] ?? 0;

          // Check if the room matches the guests and beds criteria
          bool matchesGuests = guests == null || roomGuests >= guests;
          bool matchesBeds = beds == null || roomBeds >= beds;

          if (matchesGuests && matchesBeds) {
            List<String> images = List<String>.from(roomData['images'] ?? []);
            List<String> amenities = List<String>.from(roomData['amenities'] ?? []);

            results.add({
              'hotelID': hotelDoc.id,
              'hotelName': hotelData['hotel_name'],
              'roomID': roomDoc.id,
              'roomName': roomData['name'],
              'address': hotelData['address'],
              'guests': roomData['guests'],
              'beds': roomData['beds'],
              'imageUrl': images.isNotEmpty ? images[0] : '',
              'description': roomData['description'],
              'amenities': amenities,
              'price': roomData['price'] ?? 0.0,
            });
          }
        }
      }
    }

    setState(() {
      searchResults = results;
      isLoading = false;
    });

    // Debug prints to verify the search results
    print('Search results count: ${searchResults.length}');
    for (var result in searchResults) {
      print('Hotel found: ${result['hotelName']}, Room: ${result['roomName']}, Address: ${result['address']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Hotels'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(hintText: 'Enter city'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: guestsController,
              decoration: InputDecoration(hintText: 'Enter number of guests'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: bedsController,
              decoration: InputDecoration(hintText: 'Enter number of beds'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchHotels,
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : searchResults.isEmpty
                ? Text('No results found')
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> result = searchResults[index];
                return ListTile(
                  title: Text('${result['hotelName']} - ${result['roomName']}'),
                  subtitle: Text('${result['address']} (Guests: ${result['guests']}, Beds: ${result['beds']})'),
                  leading: result['imageUrl'] != null
                      ? Image.network(result['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailPage(
                          roomID: result['roomID'],
                          hotelID: result['hotelID'],
                          roomName: result['roomName'],
                          description: result['description'],
                          imageUrl: result['imageUrl'],
                          amenities: List<String>.from(result['amenities']),
                          guests: result['guests'],
                          beds: result['beds'],
                          hotelName: result['hotelName'],
                          price: result['price'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20),
            Text('All hotel addresses:'),
            ...allAddresses.map((address) => Text(address)).toList(),
          ],
        ),
      ),
    );
  }
}
