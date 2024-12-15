import 'package:flutter/material.dart';
import 'package:gestion_contacts/models/users.dart';
import '../db/db_helper.dart';
import 'home_page.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Tous les champs sont obligatoires.';
      });
      return;
    }

    User? user = await DBHelper.loginUser(email, password);
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(username: user.username, userId: user.id!),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'Email ou mot de passe incorrect';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Image
                
                SizedBox(height: 20),
                Text(
                  "Bienvenue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Connectez-vous pour continuer",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                // Email field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.email, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Password field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle forgot password
                    },
                    child: Text(
                      "Mot de passe oublié?",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Login button
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Se connecter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Social login options
                Text(
                  "Ou connectez-vous avec",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
                      onPressed: () {
                        // Google login
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.apple, color: Colors.black, size: 30),
                      onPressed: () {
                        // Apple login
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.facebook, color: Colors.blue, size: 30),
                      onPressed: () {
                        // Facebook login
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Registration link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pas encore de compte? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegistrationPage()),
                        );
                      },
                      child: Text(
                        "Inscrivez-vous",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 16),
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
