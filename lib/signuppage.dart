// import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:trialtwo/wrapper.dart';
// import 'package:get/get.dart';

// class Signup extends StatefulWidget {
//   const Signup({super.key});

//   @override
//   State<Signup> createState() => _SignupState();
// }

// class _SignupState extends State<Signup> {
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//   TextEditingController name = TextEditingController();
//   TextEditingController phone = TextEditingController();
//   TextEditingController age = TextEditingController();
//   TextEditingController address = TextEditingController();

//   signup() async {
//     try {
//       // Create user in Firebase Authentication
//       UserCredential userCredential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//               email: email.text, password: password.text);

//       // Store additional details in Firestore
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user?.uid)
//           .set({
//         'name': name.text,
//         'email': email.text,
//         'phone': phone.text,
//         'age': age.text,
//         'address': address.text,
//       });

//       // Navigate to Wrapper
//       Get.offAll(Wrapper());
//     } catch (e) {
//       // Handle errors (e.g., show a snackbar)
//       Get.snackbar("Error", e.toString(),
//           snackPosition: SnackPosition.BOTTOM);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Register"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: name,
//                 decoration: InputDecoration(hintText: "Enter Name"),
//               ),
//               TextField(
//                 controller: email,
//                 decoration: InputDecoration(hintText: "Enter Email"),
//               ),
//               TextField(
//                 controller: phone,
//                 decoration: InputDecoration(hintText: "Enter Phone Number"),
//               ),
//               TextField(
//                 controller: age,
//                 decoration: InputDecoration(hintText: "Enter Age"),
//               ),
//               TextField(
//                 controller: address,
//                 decoration: InputDecoration(hintText: "Enter Address"),
//               ),
//               TextField(
//                 controller: password,
//                 obscureText: true,
//                 decoration: InputDecoration(hintText: "Enter Password"),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                   onPressed: () => signup(), child: Text("Register"))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trialtwo/wrapper.dart';
import 'package:get/get.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController age = TextEditingController();
  TextEditingController address = TextEditingController();

  signup() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'name': name.text.trim(),
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        'age': age.text.trim(),
        'address': address.text.trim(),
      });

      Get.snackbar("Success", "Account created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.greenAccent,
          colorText: Colors.black);

      Get.offAll(Wrapper());
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    }
  }

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      labelText: label,
      hintText: "Enter $label",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.person_add_alt_1,
              size: 100,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: name,
              decoration: inputStyle("Name", Icons.person),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: inputStyle("Email", Icons.email),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: inputStyle("Phone Number", Icons.phone),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: age,
              keyboardType: TextInputType.number,
              decoration: inputStyle("Age", Icons.cake),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: address,
              decoration: inputStyle("Address", Icons.home),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: password,
              obscureText: true,
              decoration: inputStyle("Password", Icons.lock),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: signup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
