import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderly/components/components/blurred_card.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/screens/chat/chat_screen.dart';
import 'package:orderly/services/auth/auth_service.dart';
import 'package:orderly/services/chat/chat_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _setOnlineStatus(false);
    }
  }

  void _setOnlineStatus(bool isOnline) {
    _chatService.setOnlineStatus(_auth.currentUser!.uid, isOnline);
  }

  void signOut() {
    _setOnlineStatus(false); // Explicitly set offline on sign out
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: backgroundGradient,
            child: Column(
              children: [
                const SizedBox(height: 120), // Space for the custom app bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildSearchBar(),
                ),
                Expanded(child: _buildContactList()),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 20, // Adjust as needed to position the AppBar correctly
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: SafeArea(
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Contact',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: signOut,
                          icon: const Icon(Icons.logout, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by username',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
        },
      ),
    );
  }

  Widget _buildContactList() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .ref('users/${_auth.currentUser!.uid}')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var userData = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
        var contactsMap = userData?['contacts'] as Map<dynamic, dynamic>? ?? {};
        var contacts = contactsMap.keys.toList();

        if (_searchQuery.isNotEmpty) {
          return _buildSearchResults();
        }

        if (contacts.isEmpty) {
          return const Center(child: Text('No contacts found'));
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getSortedContacts(contacts),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            var sortedContacts = snapshot.data ?? [];

            return ListView.builder(
              itemCount: sortedContacts.length,
              itemBuilder: (context, index) {
                return _buildUserListItem(sortedContacts[index]['userId']);
              },
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getSortedContacts(
      List<dynamic> contacts) async {
    List<Map<String, dynamic>> contactList = [];

    for (var userId in contacts) {
      var lastMessageSnapshot =
          await _chatService.getMessages(_auth.currentUser!.uid, userId).first;
      var lastMessage = lastMessageSnapshot.snapshot.children.isNotEmpty
          ? lastMessageSnapshot.snapshot.children.last
          : null;

      DateTime? lastMessageTimestamp = lastMessage != null
          ? DateTime.parse(lastMessage.child('timestamp').value as String)
          : null;

      contactList.add({
        'userId': userId,
        'lastMessageTimestamp': lastMessageTimestamp,
      });
    }

    contactList.sort((a, b) {
      DateTime? aTimestamp = a['lastMessageTimestamp'];
      DateTime? bTimestamp = b['lastMessageTimestamp'];
      if (aTimestamp == null && bTimestamp == null) return 0;
      if (aTimestamp == null) return 1;
      if (bTimestamp == null) return -1;
      return bTimestamp.compareTo(aTimestamp);
    });

    return contactList;
  }

  Widget _buildSearchResults() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .ref('users')
          .orderByChild('username')
          .equalTo(_searchQuery)
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.data!.snapshot.exists) {
          return const Center(child: Text('No users found'));
        }

        var users = snapshot.data!.snapshot.children.toList();

        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userId = users[index].key!;
            return _buildUserListItem(userId);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(String userId) {
    return FutureBuilder<DatabaseEvent>(
      future: FirebaseDatabase.instance.ref('users/$userId').once(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var data = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) {
          return const SizedBox();
        }

        String username = data['username'] ?? 'Unknown';
        String email = data['email'] ?? 'No email';

        return StreamBuilder<DatabaseEvent>(
          stream: _chatService.getMessages(_auth.currentUser!.uid, userId),
          builder: (context, messageSnapshot) {
            if (messageSnapshot.hasError) {
              return const Center(child: Text('Error'));
            }

            if (messageSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            var messages = messageSnapshot.data!.snapshot.children;
            var lastMessage = messages.isNotEmpty ? messages.last : null;

            return StreamBuilder<DatabaseEvent>(
              stream: _chatService.getUserStatus(userId),
              builder: (context, statusSnapshot) {
                if (statusSnapshot.hasError) {
                  return const Center(child: Text('Error'));
                }

                if (statusSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var statusData = statusSnapshot.data?.snapshot.value
                    as Map<dynamic, dynamic>?;
                bool isOnline = statusData?['online'] ?? false;
                var lastSeenTimestamp = statusData?['lastSeen'];

                bool hasUnreadMessages = lastMessage != null &&
                    (lastSeenTimestamp == null ||
                        (lastMessage.child('senderId').value !=
                                _auth.currentUser!.uid &&
                            lastMessage.child('timestamp').value != null &&
                            lastSeenTimestamp != null &&
                            (lastMessage.child('timestamp').value as String)
                                    .compareTo(lastSeenTimestamp as String) >
                                0));

                return BlurredCard(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(
                      username,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOnline
                              ? 'Online'
                              : 'Last seen: ${lastSeenTimestamp != null ? DateFormat('MMM d, hh:mm a').format(DateTime.parse(lastSeenTimestamp)) : 'N/A'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: hasUnreadMessages
                        ? const Icon(Icons.markunread, color: Colors.red)
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            receiveUserEmail: email,
                            receiveUserID: userId,
                          ),
                        ),
                      ).then((_) {
                        // Update online status when returning to HomePage
                        _setOnlineStatus(true);
                      });
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
