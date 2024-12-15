import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_contacts/models/contact.dart';
import 'package:gestion_contacts/pages/EditContactPage.dart';
import '../db/db_helper.dart';

class ContactDetailPage extends StatefulWidget {
  final Contact contact;
  final Function onContactDeleted;
  final Function onContactBlocked;

  ContactDetailPage({
    required this.contact,
    required this.onContactDeleted,
    required this.onContactBlocked,
  });

  @override
  _ContactDetailPageState createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  late bool isBlocked;

  @override
  void initState() {
    super.initState();
    isBlocked = widget.contact.isBlocked == 1;
  }

  void toggleBlockStatus() async {
    if (isBlocked) {
      // Unblock the contact
      await DBHelper.unblockContact(widget.contact.id!);
    } else {
      // Block the contact
      await DBHelper.updateContact(
        widget.contact..isBlocked = 1, // Update the isBlocked field to 1
      );
    }
    setState(() {
      isBlocked = !isBlocked;
    });
    widget.onContactBlocked(); // Notify parent to refresh blocked contacts
  }

  Future<void> confirmDelete() async {
    // Show a confirmation dialog before deleting the contact
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce contact ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm delete
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Delete contact if confirmed
      await DBHelper.deleteContact(widget.contact.id!);
      widget.onContactDeleted();
      Navigator.pop(context); // Return to the previous page after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('${widget.contact.prenom} ${widget.contact.nom}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Contact's Avatar and Name
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.teal[100],
              backgroundImage: widget.contact.image.isNotEmpty
                  ? FileImage(File(widget.contact.image))
                  : null,
              child: widget.contact.image.isEmpty
                  ? Text(
                      widget.contact.prenom[0].toUpperCase(),
                      style: TextStyle(fontSize: 40, color: Colors.teal),
                    )
                  : null,
            ),
            SizedBox(height: 15),
            Text(
              '${widget.contact.prenom} ${widget.contact.nom}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal[700]),
            ),
            if (widget.contact.entreprise.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                widget.contact.entreprise,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ],
            SizedBox(height: 25),

            // Contact Details Section
            buildDetailCard(Icons.phone, widget.contact.telephone, Colors.teal, 'Téléphone'),
            buildDetailCard(Icons.email, widget.contact.email, Colors.orange, 'Email'),
            buildDetailCard(Icons.location_on, widget.contact.adresse, Colors.green, 'Adresse'),
            buildDetailCard(Icons.cake, widget.contact.dateNaissance, Colors.purple, 'Date de Naissance'),

            SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildActionButton(
                  icon: Icons.edit,
                  label: 'Modifier',
                  color: Colors.blueAccent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditContactPage(
                          contact: widget.contact,
                          onContactUpdated: () {
                            // Refresh the detail view after editing
                          },
                        ),
                      ),
                    );
                  },
                ),
                buildActionButton(
                  icon: Icons.delete,
                  label: 'Supprimer',
                  color: Colors.redAccent,
                  onPressed: confirmDelete, // Use the confirmDelete function
                ),
                buildActionButton(
                  icon: isBlocked ? Icons.lock_open : Icons.block,
                  label: isBlocked ? 'Débloquer' : 'Bloquer',
                  color: isBlocked ? Colors.grey : Colors.red,
                  onPressed: toggleBlockStatus,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailCard(IconData icon, String content, Color color, String label) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          content,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        subtitle: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
