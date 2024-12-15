import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_contacts/db/db_helper.dart';
import 'package:gestion_contacts/models/contact.dart';
import 'package:gestion_contacts/pages/AddContactPage.dart';
import 'package:gestion_contacts/pages/ContactDetailPage.dart';
import 'package:gestion_contacts/pages/BlockedContactsPage.dart';
import 'package:gestion_contacts/pages/FavoritesPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final int userId;

  HomePage({required this.username, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = [];
  Map<String, List<Contact>> groupedContacts = {};
  TextEditingController searchController = TextEditingController();
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    loadContacts();
    searchController.addListener(() {
      filterContacts();
    });
  }

  Future<void> loadContacts() async {
    List<Contact> loadedContacts = await DBHelper.getContactsForUser(widget.userId);

    loadedContacts.sort((a, b) {
      if (a.isFavorite != b.isFavorite) {
        return b.isFavorite.compareTo(a.isFavorite); // Favorites first
      }
      return a.prenom.toLowerCase().compareTo(b.prenom.toLowerCase()); // Alphabetically
    });

    setState(() {
      contacts = loadedContacts;
      groupedContacts = _groupContactsByInitial(contacts);
    });
  }

  Map<String, List<Contact>> _groupContactsByInitial(List<Contact> contacts) {
    Map<String, List<Contact>> grouped = {};
    for (var contact in contacts) {
      String initial = contact.prenom[0].toUpperCase();
      if (!grouped.containsKey(initial)) {
        grouped[initial] = [];
      }
      grouped[initial]!.add(contact);
    }
    return grouped;
  }

  void filterContacts() {
    List<Contact> results = [];
    if (searchController.text.isEmpty) {
      results = contacts;
    } else {
      results = contacts.where((contact) =>
          contact.prenom.toLowerCase().contains(searchController.text.toLowerCase()) ||
          contact.nom.toLowerCase().contains(searchController.text.toLowerCase())).toList();
    }

    setState(() {
      groupedContacts = _groupContactsByInitial(results);
    });
  }

  void addContact(
    String prenom,
    String nom,
    String entreprise,
    String telephone,
    String email,
    String adresse,
    String dateNaissance,
    String image,
  ) async {
    Contact newContact = Contact(
      prenom: prenom,
      nom: nom,
      entreprise: entreprise,
      telephone: telephone,
      email: email,
      adresse: adresse,
      dateNaissance: dateNaissance,
      image: image,
      userId: widget.userId,
    );

    await DBHelper.insertContact(newContact);
    loadContacts();
  }

  void toggleFavorite(Contact contact) async {
    int newFavoriteStatus = contact.isFavorite == 1 ? 0 : 1;
    await DBHelper.toggleFavoriteStatus(contact.id!, newFavoriteStatus);
    setState(() {
      contact.isFavorite = newFavoriteStatus;
      loadContacts();
    });
  }

  bool isTodayBirthday(String dateNaissance) {
    if (dateNaissance.isEmpty) return false;
    try {
      final parts = dateNaissance.split('/');
      final birthday = DateTime(
        DateTime.now().year,
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      final now = DateTime.now();
      return birthday.day == now.day && birthday.month == now.month;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void sendMessage(String phoneNumber) async {
    final Uri messageUri = Uri(scheme: 'sms', path: phoneNumber);
    try {
      await launchUrl(messageUri);
    } catch (e) {
      print('Could not open the messaging app: $e');
    }
  }

  void makeCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(callUri);
    } catch (e) {
      print('Could not initiate call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.star, color: Colors.teal),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(userId: widget.userId),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (choice) {
              if (choice == 'blocked') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlockedContactsPage(userId: widget.userId),
                  ),
                );
              } else if (choice == 'logout') {
                logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'blocked',
                child: Text('Liste Bloquée'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Déconnexion'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddContactPage(onContactAdded: addContact, userId: widget.userId),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: groupedContacts.keys.map((letter) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      letter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    Column(
                      children: groupedContacts[letter]!.map((contact) {
                        final isBirthday = isTodayBirthday(contact.dateNaissance);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isBirthday) Icon(Icons.cake, color: Colors.pink),
                                IconButton(
                                  icon: Icon(
                                    contact.isFavorite == 1 ? Icons.star : Icons.star_border,
                                    color: contact.isFavorite == 1 ? Colors.yellow : Colors.grey,
                                  ),
                                  onPressed: () {
                                    toggleFavorite(contact);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactDetailPage(
                                    contact: contact,
                                    onContactDeleted: loadContacts,
                                    onContactBlocked: loadContacts,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
