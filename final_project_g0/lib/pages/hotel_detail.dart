import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/services/firestore.dart';
import 'room_detail.dart';
import 'add_room.dart';

class HotelDetailPage extends StatefulWidget {
  final String hotelID;
  final String hotelName;

  const HotelDetailPage({
    Key? key,
    required this.hotelID,
    required this.hotelName,
  }) : super(key: key);

  @override
  _HotelDetailPageState createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  final FirestoreService fireStoreService = FirestoreService();
  DocumentSnapshot? hotelData;
  List<DocumentSnapshot> roomsList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHotelData();
    getRooms();
  }

  Future<void> fetchHotelData() async {
    setState(() {
      isLoading = true;
    });

    DocumentSnapshot snapshot = await fireStoreService.getHotel(widget.hotelID);
    setState(() {
      hotelData = snapshot;
      isLoading = false;
    });
  }

  Future<void> getRooms() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot querySnapshot = await fireStoreService.getRooms(widget.hotelID);

    setState(() {
      isLoading = false;
      roomsList = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddRoomPage(hotelID: widget.hotelID)),
        ),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hotelData != null ? buildHotelInfo() : Container(),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Rooms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            roomsList.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('No rooms available.'),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: roomsList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = roomsList[index];
                String roomID = document.id;

                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                // Ensure all required fields are present and not null
                String roomName = data['name'] ?? 'No name';
                String description = data['description'] ?? 'No description';
                String imageUrl = data['images'] != null && data['images'].isNotEmpty ? data['images'][0] : '';
                List<String> amenities = data['amenities'] != null ? List<String>.from(data['amenities']) : [];
                int guests = data['guests'] ?? 0;
                int beds = data['beds'] ?? 0;
                double price = (data['price'] ?? 0).toDouble();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailPage(
                          hotelID: widget.hotelID,
                          roomID: roomID,
                          roomName: roomName,
                          description: description,
                          imageUrl: imageUrl,
                          amenities: amenities,
                          guests: guests,
                          beds: beds,
                          hotelName: widget.hotelName,
                          price: price,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
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
                                  builder: (context) => AddRoomPage(
                                    hotelID: widget.hotelID,
                                    roomID: roomID,
                                    roomData: data,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.edit, color: Colors.white),
                            ),
                            IconButton(
                              onPressed: () => fireStoreService.deleteRoom(widget.hotelID, roomID),
                              icon: const Icon(Icons.delete, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHotelInfo() {
    Map<String, dynamic> data = hotelData!.data() as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          data['image_url'] != null ? Image.network(data['image_url']) : Container(),
          SizedBox(height: 10),
          Text('Hotel Name:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(data['hotel_name'] ?? ''),
          SizedBox(height: 10),
          Text('Address:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(data['address'] ?? ''),
          SizedBox(height: 10),
          Text('Host Name:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(data['host_name'] ?? ''),
          SizedBox(height: 10),
          Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(data['description'] ?? ''),
          SizedBox(height: 10),
          Text('Amenities:', style: TextStyle(fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: (data['amenities'] as List<dynamic>?)
                ?.map((amenity) => Text(amenity.toString()))
                .toList() ??
                [],
          ),
          SizedBox(height: 10),
          Text('Contact Info:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Phone: ${data['contact_info']['phone'] ?? ''}'),
          Text('Email: ${data['contact_info']['email'] ?? ''}'),
        ],
      ),
    );
  }
}
