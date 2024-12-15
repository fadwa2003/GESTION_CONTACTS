import 'package:flutter/material.dart';
import 'package:gestion_contacts/models/users.dart';
import '../db/db_helper.dart';
import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  String successMessage = '';

  Future<void> register() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Tous les champs sont obligatoires.';
        successMessage = '';
      });
      return;
    }

    User? existingUser = await DBHelper.getUserByEmail(email);
    if (existingUser != null) {
      setState(() {
        errorMessage = 'Cet email est déjà utilisé.';
        successMessage = '';
      });
      return;
    }

    User newUser = User(username: username, email: email, password: password);
    try {
      int userId = await DBHelper.registerUser(newUser);
      setState(() {
        successMessage = 'Inscription réussie pour l\'utilisateur : $username';
        errorMessage = '';
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (error) {
      setState(() {
        errorMessage = 'Erreur lors de l\'inscription : ${error.toString()}';
        successMessage = '';
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
                  "Créer un compte",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Remplissez les informations pour créer votre compte",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                // Username field
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Email field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                SizedBox(height: 20),
                // Register button
                ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Registration link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous avez déjà un compte? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        "Connectez-vous",
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
                if (successMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      successMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green, fontSize: 16),
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
