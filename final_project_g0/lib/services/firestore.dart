import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference hotels = FirebaseFirestore.instance.collection(
      'hotels');

  // Hotel operations
  Future<void> addHotel(Map<String, dynamic> hotelData) {
    return hotels.add(hotelData);
  }

  Future<void> updateHotel(String docID, Map<String, dynamic> hotelData) {
    return hotels.doc(docID).update(hotelData);
  }

  Future<void> deleteHotel(String docID) {
    return hotels.doc(docID).delete();
  }

  Stream<QuerySnapshot> getHotelsStream() {
    return hotels.orderBy('timestamp', descending: true).snapshots();
  }

  Stream<DocumentSnapshot> getHotelStream(String hotelID) {
    return hotels.doc(hotelID).snapshots();
  }

  // Room operations
  Future<void> addRoom(String hotelID, Map<String, dynamic> roomData) {
    return hotels.doc(hotelID).collection('rooms').add(roomData);
  }

  Future<void> updateRoom(String hotelID, String roomID,
      Map<String, dynamic> roomData) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).update(roomData);
  }

  Future<void> deleteRoom(String hotelID, String roomID) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).delete();
  }

  Stream<QuerySnapshot> getRoomsStream(String hotelID) {
    return hotels.doc(hotelID).collection('rooms').orderBy(
        'timestamp', descending: true).snapshots();
  }

  Stream<DocumentSnapshot> getRoomStream(String hotelID, String roomID) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).snapshots();
  }

  Future<void> bookRoom(String hotelID, String roomID, DateTime startDate,
      DateTime endDate, String userEmail, double amount) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).collection(
        'bookings').add({
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'timestamp': Timestamp.now(),
      'user_email': userEmail,
      'amount': amount,
    });
  }

  Stream<QuerySnapshot> getBookingsStream(String hotelID, String roomID) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).collection(
        'bookings').orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getAllBookingsStream() {
    return hotels.snapshots().asyncExpand((hotelSnapshot) {
      final hotelDocs = hotelSnapshot.docs;
      return Stream.fromIterable(hotelDocs).asyncExpand((hotelDoc) {
        final hotelID = hotelDoc.id;
        return hotels.doc(hotelID).collection('rooms').snapshots().asyncExpand((
            roomSnapshot) {
          final roomDocs = roomSnapshot.docs;
          return Stream.fromIterable(roomDocs).asyncExpand((roomDoc) {
            final roomID = roomDoc.id;
            return hotels.doc(hotelID).collection('rooms')
                .doc(roomID)
                .collection('bookings')
                .snapshots();
          });
        });
      });
    });
  }
}
