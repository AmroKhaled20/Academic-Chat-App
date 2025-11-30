import 'package:ak_chat_app/models/message_model.dart';
import 'package:ak_chat_app/widgets/constans.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TextfeildWidgetAtChatpage extends StatefulWidget {
  TextfeildWidgetAtChatpage({
    required this.controller,
    required this.messages,
    required this.email,
    required this.userName,
    required this.color,
    this.isReply = false,
    this.messageID,
    this.ReplyToMessage,
    this.selectionAppBarr = false,
    required this.onResetReply,
  });

  TextEditingController controller;
  CollectionReference messages;
  String email;
  String userName;
  String color;

  bool isReply;
  String? messageID;
  MessageModel? ReplyToMessage;
  bool selectionAppBarr;

  final VoidCallback onResetReply;

  @override
  _TextfeildWidgetAtChatpageState createState() =>
      _TextfeildWidgetAtChatpageState();
}

class _TextfeildWidgetAtChatpageState extends State<TextfeildWidgetAtChatpage> {
  void sendMessage() {
    final text = widget.controller.text.trim();

    if (text.isEmpty) return;

    widget.messages.add({
      'realText': text,
      kmessageText: text,
      kcreatedAt: DateTime.now(),
      'UserId': FirebaseAuth.instance.currentUser!.uid,
      'userName': widget.userName,
      'color': widget.color,
      'replyTo': widget.isReply ? widget.ReplyToMessage!.docID : null,
    });

    widget.controller.clear();

    widget.onResetReply();
  }

  @override
  Widget build(BuildContext context) {
    bool isarabic = isArabic(widget.controller.text);
    return Stack(
      children: [
        TextField(
          controller: widget.controller,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => sendMessage(),
          keyboardType: TextInputType.multiline,
          maxLines: 6,
          minLines: 1,
          textInputAction: TextInputAction.newline,

          textDirection:
              isArabic(widget.controller.text)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
          textAlign:
              isArabic(widget.controller.text)
                  ? TextAlign.right
                  : TextAlign.left,

          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(16, 12, 50, 12),
            hintText: 'Send message...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: kPraimaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: kPraimaryColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: kPraimaryColor, width: 3),
            ),
          ),
        ),

        Positioned(
          bottom: 14,
          right: 15,
          child: GestureDetector(
            onTap: sendMessage,
            child: Icon(Icons.send, color: kPraimaryColor, size: 25),
          ),
        ),
      ],
    );
  }
}

bool isArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}
