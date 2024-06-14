import 'package:flutter/material.dart';
import '/services/firestore.dart';
import 'booking_page.dart';
import 'hotel_detail.dart';

class RoomDetailPage extends StatefulWidget {
  final String hotelID;
  final String hotelName;
  final String roomID;
  final String roomName;
  final String description;
  final String imageUrl;
  final List<String> amenities;
  final int guests;
  final int beds;
  final double price;

  RoomDetailPage({
    required this.hotelID,
    required this.roomID,
    required this.roomName,
    required this.description,
    required this.imageUrl,
    required this.amenities,
    required this.guests,
    required this.beds,
    required this.hotelName,
    required this.price,
  });

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  DateTime? startDate;
  DateTime? endDate;
  final FirestoreService fireStoreService = FirestoreService();

  Future<void> bookRoom() async {
    if (startDate != null && endDate != null) {
      await fireStoreService.bookRoom(widget.hotelID, widget.roomID, startDate!, endDate!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Room booked successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select start and end dates.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.imageUrl),
              SizedBox(height: 10),
              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.description),
              SizedBox(height: 10),
              Text('Amenities:', style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.amenities.map((amenity) => Text(amenity)).toList(),
              ),
              SizedBox(height: 10),
              Text('Guests: ${widget.guests}'),
              Text('Beds: ${widget.beds}'),
              Text('Price: IDR ${widget.price.toInt()}'),
              SizedBox(height: 10),
              Text('Booking:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          startDate = pickedDate;
                        });
                      }
                    },
                    child: Text(startDate != null ? 'Start Date: ${startDate!.toLocal()}'.split(' ')[0] : 'Select Start Date'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          endDate = pickedDate;
                        });
                      }
                    },
                    child: Text(endDate != null ? 'End Date: ${endDate!.toLocal()}'.split(' ')[0] : 'Select End Date'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: bookRoom,
                child: Text('Book Room'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingsPage(hotelID: widget.hotelID, roomID: widget.roomID)),
                  );
                },
                child: Text('View All Bookings'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HotelDetailPage(hotelID: widget.hotelID, hotelName: widget.hotelName),
                    ),
                  );
                },
                child: Text('View Hotel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
