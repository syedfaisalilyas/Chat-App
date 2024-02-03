import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});
  @override
  Widget build(BuildContext context) {
    final isauthenticuser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('Created At', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages found'),
            );
          }
          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('Somethinng went wrong'),
            );
          }
          final loadedmsgs = chatSnapshots.data!.docs;
          return ListView.builder(
              padding: EdgeInsets.only(
                bottom: 40,
                left: 13,
                right: 13,
              ),
              reverse: true,
              itemCount: loadedmsgs.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedmsgs[index].data();
                final nextChatMessage = index + 1 < loadedmsgs.length
                    ? loadedmsgs[index + 1].data()
                    : null;
                final currentmsgusername = chatMessage['User ID'];
                final nextmsgusername =
                    nextChatMessage != null ? nextChatMessage['User ID'] : null;
                final nextuserissame = currentmsgusername == nextmsgusername;
                if (nextuserissame) {
                  return MessageBubble.next(
                      message: chatMessage['Text'],
                      isMe: isauthenticuser.uid == currentmsgusername);
                } else {
                  return MessageBubble.first(
                      userImage: chatMessage['UserImage'],
                      username: chatMessage['Username'],
                      message: chatMessage['Text'],
                      isMe: isauthenticuser.uid == currentmsgusername);
                }
              });
        });
  }
}
