import 'package:ak_chat_app/models/message_model.dart';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendMessageBubble extends StatelessWidget {
  const FriendMessageBubble({
    super.key,
    required this.Message,
    required this.onLongPress,
  });

  final MessageModel Message;
  final VoidCallback onLongPress;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Bubble(
        color: const Color.fromARGB(255, 97, 97, 97),
        margin: const BubbleEdges.only(top: 10, left: 5, right: 55),
        padding: const BubbleEdges.only(top: 6, bottom: 6, left: 8),
        radius: const Radius.circular(8),
        stick: true,
        alignment: AlignmentDirectional.bottomStart,
        nip: BubbleNip.leftTop,
        elevation: 4,
        shadowColor: Colors.black45,
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth:
                  _textWidth(
                    Message.userName,
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ) +
                  80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    Message.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(
                        int.parse(Message.color.replaceFirst('#', '0xff')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child:
                      (Message.deleted == true)
                          ? Row(
                            children: [
                              Icon(
                                Icons.block_flipped,
                                size: 22,
                                color: const Color.fromARGB(255, 255, 121, 111),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'This message was deleted.',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  letterSpacing: -0.8,
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    121,
                                    111,
                                  ),
                                  fontSize: 17.5,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            Message.text!,
                            textDirection:
                                isArabic(Message.text!)
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.5,
                            ),
                          ),
                ),

                Text(
                  Message.date,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

double _textWidth(String text, TextStyle style) {
  final TextPainter painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.size.width;
}

bool isArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}
