class Contact {
  int? id;
  String prenom;
  String nom;
  String entreprise;
  String telephone;
  String email;
  String adresse;
  String dateNaissance;
  String image;
  int userId;
  int isBlocked;
  int isFavorite; // New field for marking favorite status

  Contact({
    this.id,
    required this.prenom,
    required this.nom,
    required this.entreprise,
    required this.telephone,
    required this.email,
    required this.adresse,
    required this.dateNaissance,
    required this.image,
    required this.userId,
    this.isBlocked = 0,
    this.isFavorite = 0, // Default to not favorite
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'entreprise': entreprise,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'dateNaissance': dateNaissance,
      'image': image,
      'userId': userId,
      'isBlocked': isBlocked,
      'isFavorite': isFavorite, // Include the new field
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      prenom: map['prenom'],
      nom: map['nom'],
      entreprise: map['entreprise'],
      telephone: map['telephone'],
      email: map['email'],
      adresse: map['adresse'],
      dateNaissance: map['dateNaissance'],
      image: map['image'],
      userId: map['userId'],
      isBlocked: map['isBlocked'] ?? 0,
      isFavorite: map['isFavorite'] ?? 0, // Default to 0 if not set
    );
  }

  get key => null;
}
