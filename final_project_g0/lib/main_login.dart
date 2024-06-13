import 'package:flutter/material.dart';
// import 'package:fp_1/pages/add_hotel.dart';
// import 'package:fp_1/pages/add_room.dart';
import 'package:firebase/pages/auth.dart';
// import 'package:fp_1/pages/booking_page.dart';
import 'package:firebase/pages/login.dart';
import 'package:firebase/pages/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/register' :(context) => RegisterPage(),
        '/login' :(context) => LoginPage(),
        // '/add_hotel' :(context) => AddHotelPage(),
        // '/add_room' :(context) => AddRoomPage(hotelID: '',),
        // '/booking_page' :(context) => BookingsPage(hotelID: '', roomID: '',),



      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthPage(),
    );
  }
}

