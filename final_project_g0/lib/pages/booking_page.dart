import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore.dart';
import 'package:intl/intl.dart';

class BookingsPage extends StatelessWidget {
  final String hotelID;
  final String roomID;

  const BookingsPage({
    Key? key,
    required this.hotelID,
    required this.roomID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getBookingsStream(hotelID, roomID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found'));
          }
          List<DocumentSnapshot> bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = bookings[index].data() as Map<String, dynamic>;
              DateTime startDate = (data['start_date'] as Timestamp).toDate();
              DateTime endDate = (data['end_date'] as Timestamp).toDate();
              String userEmail = data['user_email'] ?? 'No email provided';
              double amount = data['amount'] ?? 0.0;

              return ListTile(
                title: Text('Booking ${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: ${DateFormat('yyyy-MM-dd').format(startDate)}'),
                    Text('To: ${DateFormat('yyyy-MM-dd').format(endDate)}'),
                    Text('User Email: $userEmail'),
                    Text('Amount: IDR ${NumberFormat('#,##0').format(amount)}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
