import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore.dart';
import 'package:intl/intl.dart';

class AllBookingsPage extends StatelessWidget {
  final FirestoreService fireStoreService = FirestoreService();

  AllBookingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getAllBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }
          List<DocumentSnapshot> bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = bookings[index].data() as Map<String, dynamic>;
              DateTime startDate = (data['start_date'] as Timestamp).toDate();
              DateTime endDate = (data['end_date'] as Timestamp).toDate();
              String userEmail = data['user_email'] ?? 'Unknown';
              double amount = data['amount'] ?? 0.0;

              return ListTile(
                title: Text('Booking ${index + 1}'),
                subtitle: Text(
                    'From ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}\nUser: $userEmail\nAmount: IDR ${NumberFormat('#,##0').format(amount)}'),
              );
            },
          );
        },
      ),
    );
  }
}
