import 'package:flutter/material.dart';
import 'package:gestion_contacts/pages/login_page.dart';
import 'package:gestion_contacts/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisez le service de notifications

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Contacts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Navigation initiale
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HomePage(
              username: args['username'],
              userId: args['userId'],
            ),
          );
        }
        return null;
      },
    );
  }
}
