import 'package:flutter/material.dart';
import '../controllers/Auth.dart';
import '../main.dart';

class Sign_in extends StatefulWidget {
  const Sign_in({super.key});

  @override
  State<Sign_in> createState() => _Sign_inState();
}

class _Sign_inState extends State<Sign_in> {
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();

  MyAuth myAuth = MyAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
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
              const CircleAvatar(
                radius: 150,
                backgroundImage: AssetImage('images/gift.png'),
              ),
              Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    SizedBox(
                      child: TextField(
                        controller: Email,
                        decoration: InputDecoration(
                            hintText: 'Email', prefixIcon: Icon(Icons.email)),
                      ),
                      width: 300,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      child: TextField(
                        controller: Password,
                        decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.password)),
                      ),
                      width: 300,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      onPressed: () async {

                        bool status = await myAuth.sign_in(Email.text, Password.text);
                        await updateAppUser();
                        if(status == true){
                          Navigator.pushReplacementNamed(context, '/home');
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not allowed user")));
                        }


                      },
                      child: Text(
                        "Sign in",
                        style: TextStyle(color: Colors.grey[200]),
                      ),
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Color(0XFF996CF3)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account ?"),
                        const SizedBox(
                          width: 30,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/sign_up');
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                  color: Color(0XFF996CF3),
                                  fontStyle: FontStyle.italic),
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
