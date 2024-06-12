import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lottie/lottie.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: HexColor('#FBE4D8'),
        child: Stack(
          children: [
            // Background Lottie animation
            Positioned.fill(
              child: Lottie.asset(
                'assets/images/login.json',
                fit: BoxFit.cover,
              ),
            ),
            // Foreground content
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advena',
                    style: TextStyle(
                        fontFamily: 'NeueHaas-Medium',
                        fontSize: 35,
                        color: HexColor('#190019')),
                  ),
                  Text(
                    'Explore your new city with personalized recommendations and connect with others.',
                    style: TextStyle(
                        fontFamily: 'NeueHaas-Light',
                        fontSize: 20,
                        color: HexColor('#2B124C')),
                  ),
                  SizedBox(height: 35),
                  SingleChildScrollView( ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Email Address",
                            hintText: "test@test.ie",
                            labelStyle:
                                TextStyle(fontFamily: 'NeueHaas-Light')),
                      )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Password",
                            labelStyle:
                                TextStyle(fontFamily: 'NeueHaas-Light')),
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Google sign-in
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                  fontFamily: 'NeueHaas-Medium',
                                  fontSize: 15,
                                  color: HexColor('#190019')),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('#DFB6B2'),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Google sign-in
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                  fontFamily: 'NeueHaas-Medium',
                                  fontSize: 15,
                                  color: HexColor('#190019')),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Center(
                      child: Text(
                        'Don\'t have an account? Sign up.',
                        style: TextStyle(
                            fontFamily: 'NeueHaas-Light',
                            fontSize: 20,
                            color: HexColor('#854F6C')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
