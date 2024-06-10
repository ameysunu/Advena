import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Spacer(),
        // Center(
        //   child: SvgPicture.asset(
        //     'assets/images/login.svg',
        //     height: 250,
        //   ),
        // ),
        Text(
          'Advena',
          style: TextStyle(fontFamily: 'NeueHaas-Medium', fontSize: 35),
        ),
        Text(
          'Explore your new city with personalized recommendations and connect with others.',
          style: TextStyle(fontFamily: 'NeueHaas-Light', fontSize: 20),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/login.svg',
              height: 350,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Container(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign in with Google',
                    style:
                        TextStyle(fontFamily: 'NeueHaas-Medium', fontSize: 15),
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
        Spacer(),
        Center(
          child: Text(
            'Copyright 2024 Advena',
            style: TextStyle(fontFamily: 'NeueHaas-Light', fontSize: 20),
          ),
        ),
      ],
    );
  }
}
