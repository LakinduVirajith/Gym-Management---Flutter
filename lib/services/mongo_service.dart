import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  // Retrieve the connection string from environment variables
  final String _connectionString = dotenv.env['MONGO_CONNECTION_STRING'] ?? '';
  Db? _database;

  // Method to connect to the MongoDB database
  Future<void> connect() async {
    if (_database == null) {
      _database = await Db.create(_connectionString);
      await _database?.open();
    }
  }

  // Method to disconnect from the MongoDB database
  Future<void> disconnect() async {
    if (_database != null) {
      await _database?.close();
      _database = null;
    }
  }

  // Method to insert a new user into the 'users' collection
  Future<void> insertUser(Map<String, dynamic> userData) async {
    if (_database == null) {
      throw Exception("Database connection is not established.");
    }
    final DbCollection usersCollection = _database!.collection('users');
    await usersCollection.insertOne(userData);
  }

  // Method to check if a mobile number is unique
  Future<bool> isMobileNumberUnique(String mobileNumber) async {
    if (_database == null) {
      throw Exception("Database connection is not established.");
    }
    final DbCollection usersCollection = _database!.collection('users');
    final user =
        await usersCollection.findOne(where.eq('mobile_number', mobileNumber));
    return user == null;
  }

  // Method to update the last active date of a user
  Future<void> updateUserLastActiveDate(
      String mobileNumber, DateTime lastActiveDate) async {
    if (_database == null) {
      throw Exception("Database connection is not established.");
    }
    final DbCollection usersCollection = _database!.collection('users');
    await usersCollection.update(
      where.eq('mobile_number', mobileNumber),
      modify.set('last_active_date', lastActiveDate.toIso8601String()),
    );
  }

  // Method to insert a feedback into the 'feedbacks' collection
  Future<void> insertFeedback(Map<String, dynamic> feedback) async {
    if (_database == null) {
      throw Exception("Database connection is not established.");
    }
    final DbCollection usersCollection = _database!.collection('feedbacks');
    await usersCollection.insertOne(feedback);
  }
}
