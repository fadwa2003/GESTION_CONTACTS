import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_contacts/db/db_helper.dart';
import 'package:gestion_contacts/models/contact.dart';
import 'package:gestion_contacts/pages/ContactDetailPage.dart';
import 'package:gestion_contacts/pages/home_page.dart';

class FavoritesPage extends StatefulWidget {
  final int userId;

  FavoritesPage({required this.userId});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Contact> favoriteContacts = [];
  int _currentIndex = 2; // Set "Favorites" as the default tab when opening this page

  @override
  void initState() {
    super.initState();
    loadFavoriteContacts();
  }

  Future<void> loadFavoriteContacts() async {
    List<Contact> loadedContacts = await DBHelper.getFavoriteContacts(widget.userId);
    setState(() {
      favoriteContacts = loadedContacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: favoriteContacts.isEmpty
          ? Center(child: Text('No favorite contacts yet.'))
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: favoriteContacts.length,
              itemBuilder: (context, index) {
                final contact = favoriteContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: contact.image.isNotEmpty
                        ? FileImage(File(contact.image))
                        : null,
                    child: contact.image.isEmpty ? Text(contact.prenom[0]) : null,
                  ),
                  title: Text(
                    '${contact.prenom} ${contact.nom}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailPage(
                          contact: contact,
                          onContactDeleted: loadFavoriteContacts,
                          onContactBlocked: loadFavoriteContacts,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            // Navigate to the "Recents" page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(username: 'Recents', userId: widget.userId),
              ),
            );
          } else if (index == 1) {
            // Navigate to the "Contacts" page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(username: 'Contacts', userId: widget.userId),
              ),
            );
          } else if (index == 2) {
            // Stay on "Favorites" page
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: _currentIndex == 0 ? Colors.blueAccent : Colors.grey),
            label: 'Recents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_page, color: _currentIndex == 1 ? Colors.blueAccent : Colors.grey),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star, color: Colors.yellow),
            label: 'Favorites',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
      ),
    );
  }
}
