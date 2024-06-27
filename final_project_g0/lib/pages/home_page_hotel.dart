import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore.dart';
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
  final int limit = 10;

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  bool get isAdmin {
    return user.email == 'admin@gmail.com'; // Adjust this as needed
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotels"),
        actions: [
          TextButton(
            onPressed: signUserOut,
            child: const Text("Sign Out",
                // style: TextStyle(color: Colors.white)
            ),
          ),
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
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddHotelPage()),
        ),
        child: const Icon(Icons.add),
      )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreService.getHotelsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hotels found.'));
          }



          List<DocumentSnapshot> hotelsList = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: hotelsList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = hotelsList[index];
              String docID = document.id;
              //bookmark checking
              bool checkBookmark = false;



              Map<String, dynamic> bookmark = {
                "hotelID" : docID,
                "user" : user.email,
                'timestamp': Timestamp.now(),
              };

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
                      child: isAdmin
                          ? Row(
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
                      )

                          // : Container(),
                     : Row(
                        // children: [
                        //   IconButton(
                        //       onPressed: () => fireStoreService.addBookmark(bookmark),
                        //       icon:  Icon(Icons.book_outlined, color: Colors.white)
                        //   ),
                        // ],


                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: fireStoreService.getBookmarksStream(),
                              builder: (context, snapshot) {
                                bool checkdata = false;
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return IconButton(
                                      onPressed: () => fireStoreService.addBookmark(bookmark),
                                      icon:  Icon(Icons.book_outlined, color: Colors.white)
                                  );
                                }

                                List<DocumentSnapshot> bookmarksList = snapshot.data!.docs;
                                for(int i = 0; i < bookmarksList.length; i++) {
                                  // Object? doc = bookmarksList[i].data();
                                  Map<String, dynamic> doc = bookmarksList[i].data() as Map<String, dynamic>;
                                  // for(int j = 0; j<doc)
                                  // return Text(doc["hotelID"]+" - "+docID);
                                  if(docID == doc["hotelID"] &&  user.email == doc["user"]){
                                    // return Text(docID);

                                    return IconButton(
                                        // onPressed: () =>{},

                                        onPressed: () => fireStoreService.deleteBookmark(bookmarksList[i].id),
                                        icon:  Icon(Icons.bookmark, color: Colors.white)
                                    );
                                    checkdata = true;
                                  }
                                  else{
                                    return IconButton(
                                        onPressed: () => fireStoreService.addBookmark(bookmark),
                                        icon:  Icon(Icons.book_outlined, color: Colors.white)
                                    );
                                  }
                                }
                                return build(context);

                                // return Center(
                                //   itemCount: hotelsList.length,
                                //   itemBuilder: (context, index) {
                                //     DocumentSnapshot document = hotelsList[index];
                                //     String docID = document.id;
                                //   },
                                // );

                              },
                            ),
                            // IconButton(
                            //   onPressed: () => fireStoreService.addBookmark(bookmark),
                            //   icon:  Icon(Icons.book_outlined, color: Colors.white)
                            // ),
                          ],

                      ),
                    ),
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
