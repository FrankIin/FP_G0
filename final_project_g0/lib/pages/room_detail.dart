import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_page.dart';
import 'package:intl/intl.dart';

class RoomDetailPage extends StatefulWidget {
  final String hotelID;
  final String roomID;
  final String hotelName;

  const RoomDetailPage({
    Key? key,
    required this.hotelID,
    required this.roomID,
    required this.hotelName,
  }) : super(key: key);

  @override
  _RoomDetailPageState createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final FirestoreService fireStoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate != null ? _startDate!.add(Duration(days: 1)) : DateTime.now(),
      firstDate: _startDate != null ? _startDate!.add(Duration(days: 1)) : DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _bookRoom(double price) async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both start and end dates')),
      );
      return;
    }

    final int nights = _endDate!.difference(_startDate!).inDays;
    final double amount = price * nights;

    if (await _isBookingAvailable(_startDate!, _endDate!)) {
      fireStoreService.bookRoom(
        widget.hotelID,
        widget.roomID,
        _startDate!,
        _endDate!,
        user.email!,
        amount,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room booked successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The room is already booked for the selected dates')),
      );
    }
  }

  Future<bool> _isBookingAvailable(DateTime startDate, DateTime endDate) async {
    QuerySnapshot bookingsSnapshot = await fireStoreService.getBookingsStream(widget.hotelID, widget.roomID).first;
    for (var doc in bookingsSnapshot.docs) {
      Map<String, dynamic> booking = doc.data() as Map<String, dynamic>;
      DateTime bookingStart = (booking['start_date'] as Timestamp).toDate();
      DateTime bookingEnd = (booking['end_date'] as Timestamp).toDate();

      if ((startDate.isBefore(bookingEnd) && endDate.isAfter(bookingStart)) ||
          startDate.isAtSameMomentAs(bookingStart) || endDate.isAtSameMomentAs(bookingEnd)) {
        return false;
      }
    }
    return true;
  }

  bool get isAdmin {
    return user.email == 'admin@gmail.com'; // Adjust this as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hotelName),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: fireStoreService.getRoomStream(widget.hotelID, widget.roomID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Room not found.'));
          }
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

          String roomName = data['name'] ?? 'No name';
          String description = data['description'] ?? 'No description';
          String imageUrl = data['images'] != null && data['images'].isNotEmpty ? data['images'][0] : '';
          List<String> amenities = data['amenities'] != null ? List<String>.from(data['amenities']) : [];
          int guests = data['guests'] ?? 0;
          int beds = data['beds'] ?? 0;
          double price = (data['price'] ?? 0).toDouble();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageUrl.isNotEmpty ? Image.network(imageUrl) : Container(),
                  SizedBox(height: 10),
                  Text('Room Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(roomName),
                  SizedBox(height: 10),
                  Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(description),
                  SizedBox(height: 10),
                  Text('Amenities:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: amenities.map((amenity) => Text(amenity)).toList(),
                  ),
                  SizedBox(height: 10),
                  Text('Guests: $guests'),
                  Text('Beds: $beds'),
                  Text('Price: IDR ${NumberFormat('#,##0').format(price)} per night'),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _selectStartDate(context),
                        child: Text(_startDate == null
                            ? 'Select Start Date'
                            : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                      ),
                      TextButton(
                        onPressed: _startDate == null ? null : () => _selectEndDate(context),
                        child: Text(_endDate == null
                            ? 'Select End Date'
                            : 'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _bookRoom(price),
                    child: Text('Book Room'),
                  ),
                  if (isAdmin)
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingsPage(hotelID: widget.hotelID, roomID: widget.roomID),
                        ),
                      ),
                      child: Text('View All Bookings'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
