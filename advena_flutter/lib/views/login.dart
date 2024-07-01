import 'package:advena_flutter/controllers/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginController loginController = LoginController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
                'Advena.',
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
                child: Container(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          isLoading = true;
                        });

                        List<dynamic> result = await loginController.loginUser(
                            emailController.text, passwordController.text);
                        bool isLogin = result[0];
                        User user = result[1];
                        if (isLogin) {
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
                                'Login Error',
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
                                'Login',
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
                                'Login Error',
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
                          'Sign in with Google',
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Center(
                  child: Text(
                    'Don\'t have an account? Sign up.',
                    style: TextStyle(
                        fontFamily: 'WorkSans',
                        fontSize: 15,
                        color: Colors.grey),
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
