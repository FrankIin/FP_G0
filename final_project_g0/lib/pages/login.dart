// import 'dart:js_interop';

// import 'dart:js';

import 'package:firebase/components/my_button.dart';
import 'package:firebase/components/my_textfield.dart';
import 'package:firebase/pages/square_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/pages/register.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  void register(){
    Navigator.popAndPushNamed(context, "/register");

  }
  // sign user in method
  void signUserIn() async {

    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Text('Incorrect Email or Password'),
            title: Text('Please recheck again!'),
          );
        },
      );
      // if (e.code == 'user-not-found') {
      //   wrongEmailMessage();
      // }
      // else if (e.code == 'wrong-password') {
      //   wrongPasswordMessage();
      // }

    }
  }

  // void wrongEmailMessage() {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return const AlertDialog(
  //           content: Text('Incorrect Email'),
  //         );
  //       },
  //   );
  // }
  //
  // void wrongPasswordMessage() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return const AlertDialog(
  //         content: Text('Incorrect Password'),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              //
              // // logo
              const Icon(
                Icons.lock,
                size: 100,
              ),
              //
              const SizedBox(height: 50),
              //
              Text(
                "Welcome Back!",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              //
              const SizedBox(height: 25),

              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obsureText: false,
              ),
              //
              const SizedBox(height: 25),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obsureText: true,
              ),
              //
              const SizedBox(height: 25),

              // forget password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              //
              const SizedBox(height: 25),
              //
              // // sign in button
              MyButton(
                onTap: signUserIn,
              ),
              //
              const SizedBox(height: 50),

              // or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or Continue With',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              // google + apple sign
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: const [
              //     // google button
              //     SquareTile(imagePath: 'lib/images/google.png'),
              //
              //     SizedBox(width: 25,),
              //
              //     //apple button
              //     SquareTile(imagePath: 'lib/images/apple.png'),
              //   ],
              // ),

              const SizedBox(height: 50),

              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    child: Text(
                      'Register Now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: register,
                  )
                  // const Text(
                  //   'Register Now',
                  //   style: TextStyle(
                  //     color: Colors.blue,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}