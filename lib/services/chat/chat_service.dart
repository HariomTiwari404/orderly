import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Stream<DatabaseEvent> getMessages(String currentUserId, String receiverId) {
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _database.child('messages/$chatRoomId').onValue;
  }

  Future<void> sendMessage(String receiverId, String message) async {
    String senderId = FirebaseAuth.instance.currentUser!.uid;
    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    String messageId = _database.child('messages/$chatRoomId').push().key!;
    DateTime now = DateTime.now();

    await _database.child('messages/$chatRoomId/$messageId').set({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': now.toIso8601String(),
      'read': false,
    });

    await _database.child('users/$receiverId/contacts').update({
      senderId: true,
    });

    await _database.child('users/$senderId/contacts').update({
      receiverId: true,
    });
  }

  Future<void> setTypingStatus(String userId, bool isTyping) async {
    await _database.child('users/$userId').update({'isTyping': isTyping});
  }

  Future<void> setOnlineStatus(String userId, bool isOnline) async {
    await _database.child('users/$userId').update({'online': isOnline});
  }

  Future<void> updateLastSeen() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await _database
        .child('users/$userId')
        .update({'lastSeen': DateTime.now().toIso8601String()});
  }

  Stream<DatabaseEvent> getUserStatus(String userId) {
    return _database.child('users/$userId').onValue;
  }

  Stream<DatabaseEvent> getTypingStatus(String userId) {
    return _database.child('users/$userId').onValue;
  }

  Future<void> clearChat(String currentUserId, String receiverId) async {
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _database.child('messages/$chatRoomId').remove();
  }

  Future<void> markAsRead(String chatRoomId) async {
    DataSnapshot snapshot = await _database.child('messages/$chatRoomId').get();

    for (DataSnapshot messageSnapshot in snapshot.children) {
      await messageSnapshot.ref.update({'read': true});
    }
  }
}
