import 'package:ak_chat_app/models/message_model.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

class FriendReplyToAnyMessage extends StatelessWidget {
  const FriendReplyToAnyMessage({
    super.key,
    required this.Message,
    required this.ReplyToMessage,
    required this.onLongPress,
    required this.currentUsername,
    required this.onTap,
  });

  final MessageModel Message;
  final MessageModel ReplyToMessage;
  final VoidCallback onLongPress;
  final String currentUsername;
  final VoidCallback onTap;

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

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,

          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child:
                  (Message.deleted == true)
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Message.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(
                                int.parse(
                                  Message.color.replaceFirst('#', '0xff'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
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
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Message.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(
                                int.parse(
                                  Message.color.replaceFirst('#', '0xff'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: GestureDetector(
                              onTap: onTap,
                              child: Container(
                                width: double.maxFinite,
                                height: 85,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 57, 57, 57),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ReplyToMessage.userName ==
                                                currentUsername
                                            ? 'You'
                                            : ReplyToMessage.userName,
                                        style: TextStyle(
                                          color: Color(
                                            int.parse(
                                              ReplyToMessage.color.replaceFirst(
                                                '#',
                                                '0xff',
                                              ),
                                            ),
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        ReplyToMessage.realText,
                                        maxLines: 2,
                                        textDirection:
                                            isArabic(ReplyToMessage.realText)
                                                ? TextDirection.rtl
                                                : TextDirection.ltr,
                                        style: TextStyle(
                                          height: 1.3,
                                          overflow: TextOverflow.ellipsis,
                                          color: const Color.fromARGB(
                                            255,
                                            212,
                                            212,
                                            212,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
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
                        ],
                      ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Message.date,
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ],
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
