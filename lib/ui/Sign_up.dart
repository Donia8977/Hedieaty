import 'package:flutter/material.dart';
import '../controllers/Auth.dart';
import '../main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';


class Sign_up extends StatefulWidget {

  const Sign_up({super.key });

  @override
  State<Sign_up> createState() => _Sign_upState();
}

class _Sign_upState extends State<Sign_up> {
  TextEditingController AppUserName = TextEditingController();
  TextEditingController Password = TextEditingController();
  TextEditingController Email = TextEditingController();
  MyAuth myAuth = MyAuth();

  GlobalKey<FormState> mykey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background image decoration
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/signin_pagecute.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                "Let's Create an account",
                style: TextStyle(
                  fontSize: 25,
                  color: Color(0XFF996CF3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Form(
                      key: mykey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // UserName Field
                          TextFormField(
                            controller: AppUserName,
                            decoration: const InputDecoration(
                              hintText: 'UserName',
                              prefixIcon: Icon(Icons.person_rounded),
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Email Field
                          TextFormField(
                            controller: Email,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Password Field
                          TextFormField(
                            controller: Password,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.password),
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(350, 50),
                              backgroundColor: const Color(0XFF996CF3),
                            ),
                            onPressed: () async {
                              final newUser = await myAuth.sign_up(
                                Email.text,
                                Password.text,
                              );

                              await updateAppUser();

                                if (newUser != null) {
                                  if (mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/home',
                                          (Route<dynamic> route) => false,
                                    );
                                  }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                    Text("Weak password or user exists"),
                                  ),
                                );
                              }


                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(color: Colors.grey[200]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account?  "),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Sign in",
                                    style: TextStyle(
                                      color: Color(0XFF996CF3),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
