import 'package:flutter/material.dart';
import 'login_page.dart';
import 'registration_page.dart';

class page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image représentant la gestion de contacts
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'image/image1.png', // Remplace par une illustration correspondant à la gestion de contacts
                  height: 250,
                ),
              ),
              SizedBox(height: 20),
              // Texte principal
              Text(
                "Manage Your Contacts Effortlessly",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              // Texte de description
              Text(
                "Store, organize, and access all your contacts\nin one place for easier management.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              // Boutons pour "Register" et "Sign In"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bouton Register
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistrationPage()),
                      );
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  // Bouton Sign In
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text("Sign In"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    backgroundColor: Colors.teal[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
