import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference hotels = FirebaseFirestore.instance.collection('hotels');

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

  Future<QuerySnapshot> getHotelsPaginated(int limit, DocumentSnapshot? lastDocument) {
    Query query = hotels.orderBy('timestamp', descending: true).limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.get();
  }

  Future<DocumentSnapshot> getHotel(String hotelID) {
    return hotels.doc(hotelID).get();
  }

  // Room operations
  Future<void> addRoom(String hotelID, Map<String, dynamic> roomData) {
    return hotels.doc(hotelID).collection('rooms').add(roomData);
  }

  Future<void> updateRoom(String hotelID, String roomID, Map<String, dynamic> roomData) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).update(roomData);
  }

  Future<void> deleteRoom(String hotelID, String roomID) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).delete();
  }

  Future<QuerySnapshot> getRooms(String hotelID) {
    return hotels.doc(hotelID).collection('rooms').orderBy('timestamp', descending: true).get();
  }

  Future<DocumentSnapshot> getRoom(String hotelID, String roomID) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).get();
  }

  Future<void> bookRoom(String hotelID, String roomID, DateTime startDate, DateTime endDate) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).collection('bookings').add({
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'timestamp': Timestamp.now(),
    });
  }

  Future<QuerySnapshot> getBookings(String hotelID, String roomID) {
    return hotels.doc(hotelID).collection('rooms').doc(roomID).collection('bookings').orderBy('timestamp', descending: true).get();
  }

  // Fetch all hotels
  Future<QuerySnapshot> getAllHotels() async {
    return await hotels.get();
  }

  // Fetch all rooms for a given hotel
  Future<QuerySnapshot> getAllRooms(String hotelID) async {
    return await hotels.doc(hotelID).collection('rooms').get();
  }
}
