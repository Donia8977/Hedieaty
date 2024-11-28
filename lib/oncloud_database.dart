import 'package:cloud_firestore/cloud_firestore.dart';

class MyCloudDB{
  read()async{
    // var x = FirebaseFirestore.instance.collection('users');
    // QuerySnapshot y = await x.get();
    // List z = y.docs;
    // return z;
  }

  add(String name, int age){
    // var x = FirebaseFirestore.instance.collection('users');
    // x.add({
    //   'name': name,
    //   'age': age,
    // });
  }

  delete(id){
    // var x = FirebaseFirestore.instance.collection('users');
    // x.doc(id).delete();
  }


  update(){

  }
}