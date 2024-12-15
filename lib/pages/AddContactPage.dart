import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_contacts/db/db_helper.dart';
import 'package:image_picker/image_picker.dart';

class AddContactPage extends StatefulWidget {
  final Function(String, String, String, String, String, String, String, String) onContactAdded;
  final int userId;

  AddContactPage({required this.onContactAdded, required this.userId});

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController entrepriseController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController dateNaissanceController = TextEditingController();

  File? selectedImage;
  String selectedCountryCode = '+212';

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void saveContact() async {
    final fullPhoneNumber = '$selectedCountryCode ${telephoneController.text.trim()}';

    bool phoneExists = await DBHelper.doesPhoneNumberExist(fullPhoneNumber, widget.userId);
    
    if (phoneExists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Numéro de téléphone existant'),
          content: Text('Ce numéro de téléphone existe déjà dans vos contacts.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onContactAdded(
      prenomController.text,
      nomController.text,
      entrepriseController.text,
      fullPhoneNumber,
      emailController.text,
      adresseController.text,
      dateNaissanceController.text,
      selectedImage?.path ?? '',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Ajouter un Contact'),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            GestureDetector(
              onTap: selectImage,
              child: CircleAvatar(
                radius: 55,
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
            SizedBox(height: 10),
            Text(
              'Ajouter une photo',
              style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            buildTextField(controller: prenomController, label: 'Prénom', icon: Icons.person),
            SizedBox(height: 15),
            buildTextField(controller: nomController, label: 'Nom', icon: Icons.person_outline),
            SizedBox(height: 15),
            buildTextField(controller: entrepriseController, label: 'Entreprise', icon: Icons.business),
            SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCountryCode,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCountryCode = newValue!;
                          });
                        },
                        items: [
                          {'flag': '🇲🇦', 'code': '+212'},
                          {'flag': '🇫🇷', 'code': '+33'},
                          {'flag': '🇺🇸', 'code': '+1 (US)'},
                          {'flag': '🇬🇧', 'code': '+44'},
                          {'flag': '🇨🇦', 'code': '+1 (CA)'},
                        ].map<DropdownMenuItem<String>>((country) {
                          return DropdownMenuItem<String>(
                            value: country['code'],
                            child: Row(
                              children: [
                                Text(country['flag']!, style: TextStyle(fontSize: 18)),
                                SizedBox(width: 8),
                                Text(country['code']!),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 7,
                  child: buildTextField(
                    controller: telephoneController,
                    label: 'Téléphone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    maxLength: 15,
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),
            buildTextField(controller: emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 15),
            buildTextField(controller: adresseController, label: 'Adresse', icon: Icons.location_on),
            SizedBox(height: 15),
            buildTextField(controller: dateNaissanceController, label: 'Date de Naissance (JJ/MM/AAAA)', icon: Icons.calendar_today, keyboardType: TextInputType.datetime),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveContact,
              child: Text(
                'Sauvegarder',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
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
    int? maxLength,
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
      maxLength: maxLength,
    );
  }
}
