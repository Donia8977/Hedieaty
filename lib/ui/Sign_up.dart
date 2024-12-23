import 'package:flutter/material.dart';
import '../controllers/Auth.dart';
import '../main.dart';



class Sign_up extends StatefulWidget {

  const Sign_up({super.key });

  @override
  State<Sign_up> createState() => _Sign_upState();
}

class _Sign_upState extends State<Sign_up> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController AppUserName = TextEditingController();
  TextEditingController Password = TextEditingController();
  TextEditingController Email = TextEditingController();
  MyAuth myAuth = MyAuth();

  GlobalKey<FormState> mykey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: AppUserName,
                            decoration: const InputDecoration(
                              hintText: 'UserName',
                              prefixIcon: Icon(Icons.person_rounded),
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username is required';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          TextFormField(
                            controller: Email ,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }

                              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Enter a valid email (e.g., user@example.com)';
                              }

                              if (!value.contains('@')) {
                                return 'Email must contain "@"';
                              }
                              if (!value.endsWith('.com')) {
                                return 'Email must end with ".com"';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          // Password Field
                          TextFormField(
                            controller: Password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              filled: true,
                              fillColor: Colors.white70,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          // Sign Up Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(350, 50),
                              backgroundColor: const Color(0XFF996CF3),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final newUser = await myAuth.sign_up(
                                  Email.text.trim(),
                                  Password.text.trim(),
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
                                      content: Text(
                                          "Weak password or user already exists"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                print("Form validation failed");
                              }
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(color: Colors.grey[200]),
                            ),
                          ),

                          // Sign-in Navigation
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

