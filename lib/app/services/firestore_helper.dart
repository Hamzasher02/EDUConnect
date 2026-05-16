import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static FirebaseFirestore get db => _db;

  static CollectionReference get schools => _db.collection('schools');
  static CollectionReference get students => _db.collection('students');
  static CollectionReference get teachers => _db.collection('teachers');
  static CollectionReference get parents => _db.collection('parents');
  static CollectionReference get classes => _db.collection('classes');

  static CollectionReference get timetables => _db.collection('timetables');
  static CollectionReference get assignments => _db.collection('assignments');
  static CollectionReference get submissions => _db.collection('submissions');
  static CollectionReference get attendance => _db.collection('attendance');
  static CollectionReference get results => _db.collection('results');
  static CollectionReference get fees => _db.collection('fees');
  static CollectionReference get exams => _db.collection('exams');
  static CollectionReference get rankings => _db.collection('rankings');
  static CollectionReference get notifications =>
      _db.collection('notifications');
  static CollectionReference get messages => _db.collection('messages');
  static CollectionReference get users => _db.collection('users');
  static CollectionReference get settings => _db.collection('settings');

  static CollectionReference get systemBackups =>
      _db.collection('system_backups');
  static CollectionReference get systemRestoreRequests =>
      _db.collection('system_restore_requests');
}
