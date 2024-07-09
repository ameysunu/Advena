import 'package:advena_flutter/controllers/login.dart';
import 'package:advena_flutter/views/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';

import 'home.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  LoginController loginController = LoginController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Spacer(),
              Text(
                'Register for Advena.',
                style: TextStyle(
                    fontFamily: 'WorkSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: HexColor('#6100FF')),
              ),
              SizedBox(height: 35),
              SingleChildScrollView(),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email Address",
                        hintText: "test@test.ie",
                        labelStyle: TextStyle(fontFamily: 'WorkSans')),
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                        labelStyle: TextStyle(fontFamily: 'WorkSans')),
                  )),
                                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Confirm Password",
                        labelStyle: TextStyle(fontFamily: 'WorkSans')),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          isLoading = true;
                        });

                        List<dynamic> result = await loginController.registerUser(
                            emailController.text, passwordController.text, confirmPasswordController.text);
                        bool isRegister = result[0];
                        User user = result[1];
                        if (isRegister) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                  body: SafeArea(child: Home(user: user))),
                            ),
                          );
                          print("Yayy!");
                        }
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              ///backgroundColor: HexColor('#FBE4D8'),
                              title: Text(
                                'Error',
                                style: TextStyle(fontFamily: 'WorkSans', fontWeight: FontWeight.bold, color: HexColor("#6100FF")),
                              ),
                              content: Text(e.toString(),
                                  style: TextStyle(fontFamily: 'WorkSans')),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: isLoading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.grey,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                HexColor('#190019')),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Register',
                                style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontSize: 15,
                                    color: HexColor('#FFFFFF')),
                              ),
                            ],
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor('#6100FF'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
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
                    onPressed: () async {
                      try {
                        User? user = await loginController.signInWithGoogle();
                        if (user != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                  body: SafeArea(child: Home(user: user))),
                            ),
                          );
                          print("Yayy!");
                        }
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              //backgroundColor: HexColor('#FBE4D8'),
                              title: Text(
                                'Error',
                                style: TextStyle(
                                    fontFamily: 'WorkSans',
                                    fontWeight: FontWeight.bold,
                                    color: HexColor("#FFFFFF")
                                    ),
                              ),
                              content: Text(e.toString(),
                                  style: TextStyle(fontFamily: 'WorkSans')),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign up with Google',
                          style: TextStyle(
                              fontFamily: 'WorkSans',
                              fontSize: 15,
                              color: HexColor('#6100FF')),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Scaffold(body: SafeArea(child: Login())),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Center(
                    child: Text(
                      'Have an account? Sign in',
                      style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 15,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
