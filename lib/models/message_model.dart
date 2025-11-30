import 'package:ak_chat_app/widgets/constans.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  MessageModel({
    required this.text,
    required this.id,
    required this.date,
    required this.userName,
    required this.color,
    required this.deleted,
    required this.docID,
    required this.replyTo,
    required this.deletedFor,
    required this.realText,
  });

  final String? text;
  final String date;
  final String id;
  final String userName;
  final String color;
  final String docID;
  final bool deleted;
  final String? replyTo;
  final List<String> deletedFor;
  final String realText;

  factory MessageModel.fromSnapshot(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    DateTime messageTime = json[kcreatedAt].toDate();
    String formattedTime = formatTime(messageTime);

    return MessageModel(
      text: json[kmessageText],
      id: json[kuserId],
      date: formattedTime,
      userName: json[kuserName],
      color: json[kcolor],
      deleted: json['deleted'] ?? false,
      docID: doc.id,
      replyTo: json['replyTo'],
      deletedFor: List<String>.from(json['deletedFor'] ?? []),
      realText: json['realText'] ?? json[kmessageText],
    );
  }
  static String formatTime(DateTime time) {
    int hour = time.hour > 12 ? time.hour - 12 : time.hour;
    String minute = time.minute.toString().padLeft(2, '0');
    String period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<String> getUserColor(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    return userDoc.get('color') as String;
  }
}
