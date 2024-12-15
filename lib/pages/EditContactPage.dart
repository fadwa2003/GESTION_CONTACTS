import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gestion_contacts/models/contact.dart';
import 'package:gestion_contacts/db/db_helper.dart';

class EditContactPage extends StatefulWidget {
  final Contact contact;
  final Function onContactUpdated;

  EditContactPage({required this.contact, required this.onContactUpdated});

  @override
  _EditContactPageState createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  late TextEditingController prenomController;
  late TextEditingController nomController;
  late TextEditingController entrepriseController;
  late TextEditingController telephoneController;
  late TextEditingController emailController;
  late TextEditingController adresseController;
  late TextEditingController dateNaissanceController;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    prenomController = TextEditingController(text: widget.contact.prenom);
    nomController = TextEditingController(text: widget.contact.nom);
    entrepriseController = TextEditingController(text: widget.contact.entreprise);
    telephoneController = TextEditingController(text: widget.contact.telephone);
    emailController = TextEditingController(text: widget.contact.email);
    adresseController = TextEditingController(text: widget.contact.adresse);
    dateNaissanceController = TextEditingController(text: widget.contact.dateNaissance);
    selectedImage = widget.contact.image.isNotEmpty ? File(widget.contact.image) : null;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void updateContact() async {
    widget.contact.prenom = prenomController.text;
    widget.contact.nom = nomController.text;
    widget.contact.entreprise = entrepriseController.text;
    widget.contact.telephone = telephoneController.text;
    widget.contact.email = emailController.text;
    widget.contact.adresse = adresseController.text;
    widget.contact.dateNaissance = dateNaissanceController.text;
    widget.contact.image = selectedImage?.path ?? '';

    await DBHelper.updateContact(widget.contact);
    widget.onContactUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Modifier Contact'),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.teal[100],
                backgroundImage: selectedImage != null ? FileImage(selectedImage!) : null,
                child: selectedImage == null
                    ? Icon(
                        Icons.add_a_photo,
                        size: 30,
                        color: Colors.teal,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedImage = null;
                });
              },
              child: Text(
                'Supprimer la photo',
                style: TextStyle(color: Colors.red),
              ),
            ),
            SizedBox(height: 20),

            buildTextField(controller: prenomController, label: 'Prénom', icon: Icons.person),
            SizedBox(height: 15),
            buildTextField(controller: nomController, label: 'Nom', icon: Icons.person_outline),
            SizedBox(height: 15),
            buildTextField(controller: entrepriseController, label: 'Entreprise', icon: Icons.business),
            SizedBox(height: 15),
            buildTextField(controller: telephoneController, label: 'Téléphone', icon: Icons.phone, keyboardType: TextInputType.phone),
            SizedBox(height: 15),
            buildTextField(controller: emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 15),
            buildTextField(controller: adresseController, label: 'Adresse', icon: Icons.location_on),
            SizedBox(height: 15),
            buildTextField(controller: dateNaissanceController, label: 'Date de Naissance (JJ/MM/AAAA)', icon: Icons.calendar_today, keyboardType: TextInputType.datetime),
            SizedBox(height: 25),

            ElevatedButton(
              onPressed: updateContact,
              child: Text(
                'Enregistrer les modifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal, fontSize: 16),
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(vertical: 18),
      ),
      keyboardType: keyboardType,
    );
  }
}
