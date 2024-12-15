import 'package:gestion_contacts/models/contact.dart';
import 'package:gestion_contacts/models/users.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer';

class DBHelper {
  static Database? _database;

  // Initialize the database
  static Future<Database> initDb() async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');
    log('Database path: $path');

    _database = await openDatabase(
      path,
      version: 3, // Increment the version number for each migration
      onCreate: (db, version) async {
        log('Creating tables...');

        // Initial creation of the contacts and users tables
        
        await db.execute('''
  CREATE TABLE contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    prenom TEXT NOT NULL,
    nom TEXT NOT NULL,
    entreprise TEXT,
    telephone TEXT NOT NULL,
    email TEXT,
    adresse TEXT,
    dateNaissance TEXT,
    image TEXT,
    userId INTEGER NOT NULL,
    isBlocked INTEGER DEFAULT 0,
    isFavorite INTEGER DEFAULT 0  -- New column for favorite status
  );
''');


        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          );
        ''');

        log('Tables created successfully.');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        log('Upgrading database from version $oldVersion to $newVersion');
        
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE contacts ADD COLUMN userId INTEGER NOT NULL DEFAULT 0;");
          log('Migrated to version 2: Added userId column to contacts table.');
        }
        
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE contacts ADD COLUMN isBlocked INTEGER DEFAULT 0;");
          log('Migrated to version 3: Added isBlocked column to contacts table.');
        }
      },
    );

    return _database!;
  }

  // Insert a contact associated with a specific user
  static Future<void> insertContact(Contact contact) async {
    final db = await initDb();
    await db.insert('contacts', contact.toMap());
    log('Contact inserted: ${contact.prenom} ${contact.nom}');
  }

  // Update an existing contact
  static Future<void> updateContact(Contact contact) async {
    final db = await initDb();
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
    log('Contact updated: ${contact.prenom} ${contact.nom}');
  }

  // Delete a contact by ID
  static Future<void> deleteContact(int id) async {
    final db = await initDb();
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    log('Contact deleted: $id');
  }

  // Fetch contacts for a specific user by userId
  static Future<List<Contact>> getContactsForUser(int userId) async {
    final db = await initDb();
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) {
      log('No contacts found for userId: $userId');
      return [];
    }

    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // Register a new user
  static Future<int> registerUser(User user) async {
    final db = await initDb();
    try {
      int result = await db.insert('users', user.toMap());
      log('User registered successfully: ${user.username}');
      return result;
    } catch (error) {
      log('Error registering user: $error');
      return -1;
    }
  }

  // User login method
  static Future<User?> loginUser(String email, String password) async {
    final db = await initDb();
    log('Attempting login for email: $email');

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      log('Login successful for user: ${maps.first['username']}');
      return User.fromMap(maps.first);
    } else {
      log('No user found with provided email and password.');
      return null;
    }
  }

   static Future<User?> getUserByEmail(String email) async {
    final db = await initDb();

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first); // User found
    } else {
      return null; // No user found with this email
    }
  }

  // Method to mark a contact as blocked
  static Future<List<Contact>> getBlockedContacts(int userId) async {
  final db = await initDb();
  final List<Map<String, dynamic>> maps = await db.query(
    'contacts',
    where: 'isBlocked = ? AND userId = ?',
    whereArgs: [1, userId], // Only blocked contacts for this user
  );

  return List.generate(maps.length, (i) {
    return Contact.fromMap(maps[i]);
  });
}




  // Method to unblock a contact
  static Future<void> unblockContact(int contactId) async {
  final db = await initDb();
  await db.update(
    'contacts',
    {'isBlocked': 0},
    where: 'id = ?',
    whereArgs: [contactId],
  );
  log('Contact unblocked: $contactId');
}


  // Method to get blocked contacts
    // Méthode pour obtenir les contacts bloqués pour un utilisateur spécifique
 

  // Method to unblock a contact
static Future<bool> doesPhoneNumberExist(String phoneNumber, int userId) async {
  final db = await initDb();
  final List<Map<String, dynamic>> maps = await db.query(
    'contacts',
    where: 'telephone = ? AND userId = ?',
    whereArgs: [phoneNumber, userId],
  );
  return maps.isNotEmpty; // Returns true if the phone number exists
}
static Future<void> toggleFavoriteStatus(int id, int isFavorite) async {
  final db = await initDb();
  await db.update(
    'contacts',
    {'isFavorite': isFavorite},
    where: 'id = ?',
    whereArgs: [id],
  );
}
// Method to get all favorite contacts
static Future<List<Contact>> getFavoriteContacts(int userId) async {
  final db = await initDb();
  final List<Map<String, dynamic>> maps = await db.query(
    'contacts',
    where: 'userId = ? AND isFavorite = ?',
    whereArgs: [userId, 1],
  );

  return List.generate(maps.length, (i) {
    return Contact.fromMap(maps[i]);
  });
}


}


