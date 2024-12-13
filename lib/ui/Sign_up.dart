import 'package:flutter/material.dart';
import '../controllers/Auth.dart';
import '../main.dart';


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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Let's Create an account",
          style: TextStyle(
              fontSize: 25, color: Color(0XFF996CF3), fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: mykey,
                  child: Column(
                    children: [
                      SizedBox(
                          child: TextFormField(
                            controller: AppUserName,
                            decoration: InputDecoration(
                                hintText: 'UserName',
                                prefixIcon: Icon(Icons.person_rounded)),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                          child: TextFormField(
                            controller: Email,
                            decoration: InputDecoration(
                                hintText: 'Email', prefixIcon: Icon(Icons.email)),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                          child: TextFormField(
                            controller: Password,
                            decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: Icon(Icons.password)),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(350, 50),
                                backgroundColor: Color(0XFF996CF3)),
                            onPressed: () async {

                             final newUser = await  myAuth.sign_up(Email.text, Password.text);

                             await updateAppUser();

                              if(newUser != null){
                                Navigator.pushNamedAndRemoveUntil(context,
                                    '/home', (Route<dynamic> route) => false);
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Weak password or user exists")));
                              }


                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(color: Colors.grey[200]),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?  "),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Sign in",
                                  style: TextStyle(
                                    color: Color(0XFF996CF3),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
