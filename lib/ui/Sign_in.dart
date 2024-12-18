import 'package:flutter/material.dart';
import '../controllers/Auth.dart';
import '../main.dart';

class Sign_in extends StatefulWidget {
  const Sign_in({super.key});

  @override
  State<Sign_in> createState() => _Sign_inState();
}

class _Sign_inState extends State<Sign_in> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();

  MyAuth myAuth = MyAuth();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body:  Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
        image: DecorationImage(
        image: AssetImage('images/signin_pagecute.jpg'),
    fit: BoxFit.cover,
    ),
    ),
    child:SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Welcome to Hedieatak',
                  style: TextStyle(
                      fontSize: 35,
                      color: Color(0XFF996CF3),
                      fontWeight: FontWeight.bold),
                ),
              ),
              // const CircleAvatar(
              //   radius: 150,
              //   backgroundImage: AssetImage('images/gift.png'),
              // ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: Email,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex =
                            RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Password Field
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: Password,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
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
                      ),
                      const SizedBox(height: 30),

                      // Sign-in Button
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            bool status = await myAuth.sign_in(
                              Email.text.trim(),
                              Password.text.trim(),
                            );

                            await updateAppUser();

                            if (status == true) {

                              Navigator.pushReplacementNamed(
                                  context, '/home');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Invalid credentials"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            print("Validation failed");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0XFF996CF3),
                        ),
                        child: Text(
                          "Sign in",
                          style: TextStyle(color: Colors.grey[200]),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/sign_up');
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                color: Color(0XFF996CF3),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ),
      ),
    );
  }
}

