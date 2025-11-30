import 'package:ak_chat_app/models/message_model.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

class ReplyMessageWidget extends StatelessWidget {
  const ReplyMessageWidget({
    super.key,
    required this.Message,
    required this.ReplyToMessage,
    required this.onLongPress,
    required this.onTap,
  });

  final MessageModel Message;
  final MessageModel ReplyToMessage;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Bubble(
        color: const Color(0xFF2196F3),
        margin: const BubbleEdges.only(top: 10, left: 55, right: 5),
        padding: const BubbleEdges.only(top: 6, bottom: 6, left: 8),
        radius: const Radius.circular(8),
        stick: true,
        alignment: AlignmentDirectional.bottomEnd,
        nip: BubbleNip.rightTop,
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
                      ? Row(
                        children: [
                          Icon(
                            Icons.block_flipped,
                            size: 22,
                            color: Color.fromARGB(255, 81, 81, 81),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'You deleted this message.',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              letterSpacing: -0.8,
                              color: Color.fromARGB(255, 81, 81, 81),
                              fontSize: 17.5,
                            ),
                          ),
                        ],
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: GestureDetector(
                              onTap: onTap,
                              child: Container(
                                width: double.maxFinite,
                                height: 85,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    22,
                                    103,
                                    168,
                                  ),
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
                                                Message.userName
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
                (Message.deleted != true)
                    ? const Icon(
                      Icons.done_all,
                      size: 14,
                      color: Colors.white70,
                    )
                    : const SizedBox(width: 0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

bool isArabic(String text) {
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');
  return arabicRegex.hasMatch(text);
}
