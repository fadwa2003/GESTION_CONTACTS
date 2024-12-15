import 'package:flutter/material.dart';
import 'package:gestion_contacts/db/db_helper.dart';
import 'package:gestion_contacts/models/contact.dart';
import 'dart:io';

class BlockedContactsPage extends StatefulWidget {
  final int userId;

  BlockedContactsPage({required this.userId});

  @override
  _BlockedContactsPageState createState() => _BlockedContactsPageState();
}

class _BlockedContactsPageState extends State<BlockedContactsPage> {
  List<Contact> blockedContacts = [];

  @override
  void initState() {
    super.initState();
    loadBlockedContacts();
  }

  Future<void> loadBlockedContacts() async {
  List<Contact> loadedBlockedContacts = await DBHelper.getBlockedContacts(widget.userId);
  setState(() {
    blockedContacts = loadedBlockedContacts;
  });
}



  Future<void> unblockContact(int contactId) async {
    await DBHelper.unblockContact(contactId);
    loadBlockedContacts(); // Recharge la liste après déblocage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts Bloqués'),
      ),
      body: blockedContacts.isEmpty
          ? Center(child: Text('Aucun contact bloqué.'))
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: blockedContacts.length,
              itemBuilder: (context, index) {
                final contact = blockedContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: contact.image.isNotEmpty ? FileImage(File(contact.image)) : null,
                    child: contact.image.isEmpty ? Text(contact.prenom[0]) : null,
                  ),
                  title: Text('${contact.prenom} ${contact.nom}'),
                  subtitle: Text(contact.telephone),
                  trailing: IconButton(
                    icon: Icon(Icons.lock_open, color: Colors.green),
                    onPressed: () {
                      unblockContact(contact.id!);
                    },
                  ),
                );
              },
            ),
    );
  }
}
