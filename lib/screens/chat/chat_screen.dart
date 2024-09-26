import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orderly/components/components/chat_bubble.dart';
import 'package:orderly/components/components/const.dart';
import 'package:orderly/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiveUserEmail;
  final String receiveUserID;

  const ChatPage({
    super.key,
    required this.receiveUserEmail,
    required this.receiveUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  String? receiveUsername;
  String? currentUserUsername;
  String chatRoomId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUsernames();
    _initializeChatRoomId();
    _messageController.addListener(_onTyping);
    _setOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnlineStatus(false);
    _messageController.dispose();
    _scrollController.dispose();
    _chatService.setTypingStatus(_firebaseAuth.currentUser!.uid, false);
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
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId != null) {
      _chatService.setOnlineStatus(userId, isOnline);
    }
  }

  void _initializeChatRoomId() {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId != null) {
      List<String> ids = [currentUserId, widget.receiveUserID];
      ids.sort();
      chatRoomId = ids.join("_");
      _updateLastSeen();
    }
  }

  void _updateLastSeen() async {
    try {
      await _chatService.updateLastSeen();
    } catch (e) {
      print('Error updating last seen: $e');
    }
  }

  void _fetchUsernames() async {
    try {
      final currentUserId = _firebaseAuth.currentUser?.uid;
      if (currentUserId == null) return;

      final currentUserDoc =
          await FirebaseDatabase.instance.ref('users/$currentUserId').get();
      final currentUserData = currentUserDoc.value as Map<dynamic, dynamic>?;
      currentUserUsername = currentUserData?['username'];

      final receiveUserDoc = await FirebaseDatabase.instance
          .ref('users/${widget.receiveUserID}')
          .get();
      final receiveUserData = receiveUserDoc.value as Map<dynamic, dynamic>?;
      setState(() {
        receiveUsername = receiveUserData?['username'];
      });
    } catch (e) {
      print('Error fetching usernames: $e');
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await _chatService.sendMessage(
          widget.receiveUserID,
          _messageController.text,
        );
        _messageController.clear();
        _scrollToBottom(animated: true);
        _updateLastSeen();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void _scrollToBottom({bool animated = false}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _onTyping() {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId != null) {
      if (_messageController.text.isNotEmpty) {
        _chatService.setTypingStatus(userId, true);
      } else {
        _chatService.setTypingStatus(userId, false);
      }
    }
  }

  void _clearChat() async {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId != null) {
      try {
        await _chatService.clearChat(currentUserId, widget.receiveUserID);
      } catch (e) {
        print('Error clearing chat: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: backgroundGradient, // Apply the background gradient
            child: Column(
              children: [
                const SizedBox(height: 120), // Space for the custom app bar
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
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
                      title: Row(
                        children: [
                          StreamBuilder<DatabaseEvent>(
                            stream: _chatService
                                .getUserStatus(widget.receiveUserID),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data!.snapshot.value == null) {
                                return Text(
                                    receiveUsername ?? widget.receiveUserEmail);
                              }

                              // Retrieve and type-check the user data
                              Map<dynamic, dynamic>? userData = snapshot.data!
                                  .snapshot.value as Map<dynamic, dynamic>?;

                              if (userData != null) {
                                bool isOnline = userData['online'] is bool
                                    ? userData['online'] as bool
                                    : false; // Default to false if not a bool
                                var lastSeenTimestamp = userData['lastSeen'];

                                String lastSeenFormatted = 'N/A';

                                if (lastSeenTimestamp is String) {
                                  DateTime lastSeenDateTime =
                                      DateTime.parse(lastSeenTimestamp);
                                  lastSeenFormatted =
                                      DateFormat('MMM d, hh:mm a')
                                          .format(lastSeenDateTime);
                                } else {
                                  print(
                                      'Unexpected type for lastSeenTimestamp: $lastSeenTimestamp');
                                  // Handle the case where lastSeenTimestamp is not a String
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(receiveUsername ??
                                        widget.receiveUserEmail),
                                    if (isOnline)
                                      const Row(
                                        children: [
                                          SizedBox(width: 6),
                                          Icon(Icons.circle,
                                              color: Colors.green, size: 10),
                                          SizedBox(width: 6),
                                          Text('Online',
                                              style: TextStyle(fontSize: 12)),
                                        ],
                                      )
                                    else
                                      Text('Last seen: $lastSeenFormatted',
                                          style: const TextStyle(fontSize: 12)),
                                  ],
                                );
                              } else {
                                return Text(
                                    receiveUsername ?? widget.receiveUserEmail);
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          StreamBuilder<DatabaseEvent>(
                            stream: _chatService
                                .getTypingStatus(widget.receiveUserID),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  !snapshot.data!.snapshot.exists) {
                                return Container();
                              }
                              var typingData = snapshot.data!.snapshot.value
                                  as Map<dynamic, dynamic>?;
                              bool isTyping = typingData?['isTyping'] ?? false;
                              return isTyping
                                  ? const Text('Typing...',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic))
                                  : Container();
                            },
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: _clearChat,
                        ),
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

  Widget _buildMessageList() {
    return StreamBuilder<DatabaseEvent>(
      stream: _chatService.getMessages(
        _firebaseAuth.currentUser!.uid,
        widget.receiveUserID,
      ),
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var messages = snapshot.data?.snapshot.children.toList() ?? [];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom(animated: false);
        });

        // Identify unread messages from the other user
        List<DataSnapshot> unreadMessages = [];
        for (var message in messages) {
          var messageData = message.value as Map<dynamic, dynamic>;
          String senderId = messageData['senderId'] as String;

          // Collect unread messages from the other user
          if (senderId != _firebaseAuth.currentUser!.uid &&
              messageData['read'] != true) {
            unreadMessages.add(message);
          }
        }

        // Mark messages as read if there are any unread messages
        if (unreadMessages.isNotEmpty) {
          _chatService.markAsRead(chatRoomId);
          _updateLastSeen(); // Update last seen after marking messages as read
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var document = messages[index];
            return _buildMessageItem(document);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DataSnapshot document) {
    Map<dynamic, dynamic> data = document.value as Map<dynamic, dynamic>;

    // Ensure these are the correct types
    String message = data['message'] as String;
    String senderId = data['senderId'] as String;
    bool isSender = senderId == _firebaseAuth.currentUser!.uid;

    var alignment = isSender ? MainAxisAlignment.end : MainAxisAlignment.start;
    var bubbleColor = isSender
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).primaryColor;
    var username = isSender ? currentUserUsername : receiveUsername;

    DateTime dateTimeLocal;
    if (data['timestamp'] is String) {
      dateTimeLocal = DateTime.parse(data['timestamp']);
    } else {
      print('Invalid timestamp format');
      return Container(); // or handle the error as needed
    }

    String formattedTime = DateFormat('HH:mm').format(dateTimeLocal);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isSender)
            Text(
              username ?? '',
              style: const TextStyle(fontSize: 10),
            ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: alignment,
            children: [
              Flexible(
                child: ChatBubble(
                  message: message,
                  bubbleColor: bubbleColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formattedTime,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              if (isSender) ...[
                const SizedBox(width: 4),
                Icon(
                  data['read'] is bool && data['read']
                      ? Icons.done_all
                      : Icons.done,
                  color: data['read'] is bool && data['read']
                      ? Colors.blue
                      : Colors.grey,
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter message',
                hintStyle: TextStyle(color: Colors.grey[600]),
                fillColor: Theme.of(context).cardColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.arrow_upward,
              size: 30,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
