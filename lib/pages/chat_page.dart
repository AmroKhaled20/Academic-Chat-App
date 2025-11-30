import 'package:ak_chat_app/helpers/get_userColor_helper.dart';
import 'package:ak_chat_app/models/message_model.dart';
import 'package:ak_chat_app/pages/login_page.dart';
import 'package:ak_chat_app/widgets/Friend_Message_Bubble.dart';
import 'package:ak_chat_app/widgets/Friend_reply_to_any_message.dart';
import 'package:ak_chat_app/widgets/My_Message_Bubble.dart';
import 'package:ak_chat_app/widgets/Reply_message_widget.dart';
import 'package:ak_chat_app/widgets/constans.dart';
import 'package:ak_chat_app/widgets/selection_app_bar_widget.dart';
import 'package:ak_chat_app/widgets/textfeild_widget_at_chatpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ChatPage extends StatefulWidget {
  ChatPage();

  static String id = 'chat page';
  @override
  State<ChatPage> createState() => _ChatPageState();
}

Map<String, GlobalKey> messageKeys = {};

class _ChatPageState extends State<ChatPage> {
  CollectionReference messages = FirebaseFirestore.instance.collection(
    kmessagescollection,
  );
  TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Future<void> jumpToMessage(
    String targetMessageId,
    List<MessageModel> messagesList,
  ) async {
    final key = messageKeys[targetMessageId];
    if (key == null) return;

    await Future.delayed(const Duration(milliseconds: 50));

    BuildContext? ctx = key.currentContext;
    if (ctx == null) return;

    RenderBox box = ctx.findRenderObject() as RenderBox;

    double yPosition = box.localToGlobal(Offset.zero).dy;

    double currentScroll = scrollController.offset;
    double targetOffset = currentScroll + yPosition - 200;

    if (targetOffset < 0) targetOffset = 0;

    await scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    setState(() => messageID = targetMessageId);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) setState(() => messageID = null);
  }

  bool showButton = false;
  bool isloading = false;
  String? colorr;
  bool selectionAppBarr = false;
  String? messageID;
  bool isDeleted = false;
  bool isReply = false;
  MessageModel? ReplyToMessage;
  var user;
  String? userNamemessageOwner;

  String? currentUserID;
  DocumentSnapshot? docc;
  String? messageOwnerId;

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;

    isloading = true;
    scrollController.addListener(() {
      if (scrollController.offset > 50 && !showButton) {
        setState(() => showButton = true);
      } else if (scrollController.offset <= 50 && showButton) {
        setState(() => showButton = false);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var arguments = ModalRoute.of(context)!.settings.arguments as Map;
    currentUserID = arguments['argumentID'];
    return StreamBuilder<QuerySnapshot>(
      stream: messages.orderBy(kcreatedAt, descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (isloading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => isloading = false);
            });
          }

          List<MessageModel> messagesList = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            var doc = snapshot.data!.docs[i];
            var data = doc.data() as Map<String, dynamic>;

            messagesList.add(
              MessageModel(
                text: data[kmessageText],
                realText: data['realText'] ?? data[kmessageText] ?? '',
                id: data[kuserId],
                date: MessageModel.formatTime(data[kcreatedAt].toDate()),
                userName: data[kuserName],
                color: data[kcolor],
                deleted: data['deleted'] ?? false,
                docID: doc.id,
                replyTo: data['replyTo'],
                deletedFor: List<String>.from(data['deletedFor'] ?? []),
              ),
            );
          }

          return Scaffold(
            appBar:
                selectionAppBarr
                    ? SelectionAppBarWidget(
                      isDeleted: () {
                        ReplyToMessage = messagesList.firstWhere(
                          (msg) => msg.docID == messageID,
                        );
                        return ReplyToMessage!.deleted;
                      },
                      onclose: () {
                        setState(() {
                          selectionAppBarr = false;
                          messageID = null;
                          isReply = false;
                          ReplyToMessage = null;
                        });
                      },
                      onDelete: () {
                        bool isMyMessage = messageOwnerId == currentUserID;
                        bool del = isDeleted;
                        //________________________________________________________________________________________________________
                        if (isMyMessage && !del) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            useSafeArea: true,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  10,
                                  10,
                                  10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text(
                                  'Delete message?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                content: const Text(
                                  'Do you want to delete your message?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (user == null) {
                                          return;
                                        }

                                        messages.doc(messageID).update({
                                          'deleted': true,
                                          'text': '',
                                        });

                                        Navigator.of(context).pop(false);
                                        selectionAppBarr = false;
                                        messageID = null;
                                      });
                                    },
                                    child: const Text(
                                      'Delete for everyone',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                      setState(() {
                                        selectionAppBarr = false;
                                      });
                                      messageID = null;
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        //________________________________________________________________________________________________________
                        else if (isMyMessage && del) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            useSafeArea: true,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  10,
                                  10,
                                  10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text(
                                  'Delete message?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                content: const Text(
                                  'Do you want to delete your message?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                      setState(() {
                                        selectionAppBarr = false;
                                      });
                                      messageID = null;
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (user == null) {
                                          return;
                                        }

                                        messages.doc(messageID).update({
                                          'deletedFor': FieldValue.arrayUnion([
                                            currentUserID,
                                          ]),
                                        });

                                        Navigator.of(context).pop(false);
                                        selectionAppBarr = false;
                                        messageID = null;
                                      });
                                    },
                                    child: const Text(
                                      'Delete for me',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        //__________________________________________________________________________________________________
                        else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            useSafeArea: true,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  10,
                                  10,
                                  10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text(
                                  'Delete message?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                content: Text(
                                  'Delete this message from $userNamemessageOwner?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                      setState(() {
                                        selectionAppBarr = false;
                                      });
                                      messageID = null;
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (user == null) {
                                          return;
                                        }

                                        messages.doc(messageID).update({
                                          'deletedFor': FieldValue.arrayUnion([
                                            currentUserID,
                                          ]),
                                        });

                                        Navigator.of(context).pop(false);
                                        selectionAppBarr = false;
                                        messageID = null;
                                      });
                                    },
                                    child: const Text(
                                      'Delete for me',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      onReply: () {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            duration: Duration(milliseconds: 400),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(bottom: 20),

                            content: Align(
                              alignment: Alignment.bottomCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 160),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Reply now",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );

                        setState(() {
                          isReply = true;
                          ReplyToMessage = messagesList.firstWhere(
                            (msg) => msg.docID == messageID,
                          );
                        });
                      },
                    )
                    : AppBar(
                      centerTitle: true,
                      leading: IconButton(
                        onPressed: () async {
                          return showDialog(
                            context: context,
                            barrierDismissible: false,
                            useSafeArea: true,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  10,
                                  10,
                                  10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text(
                                  'Confirm Logout',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                content: const Text(
                                  'Are you sure you want to log out?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text(
                                      'No',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      Navigator.pushReplacementNamed(
                                        context,
                                        LoginPage.id,
                                      );
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      backgroundColor: kPraimaryColor,
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/scholar.png', scale: 1.7),
                          Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: messagesList.length,
                          itemBuilder: (context, index) {
                            final MessageModel message = messagesList[index];
                            messageKeys[message.docID] ??= GlobalKey();

                            if (currentUserID != null &&
                                message.deletedFor.contains(currentUserID)) {
                              return const SizedBox();
                            }
                            bool isSelected =
                                messagesList[index].docID == messageID;

                            return messagesList[index].id ==
                                    arguments['argumentID']
                                ? Container(
                                  key: messageKeys[message.docID],
                                  width: double.infinity,

                                  color:
                                      (isSelected)
                                          ? const Color.fromARGB(
                                            124,
                                            33,
                                            149,
                                            243,
                                          )
                                          : Colors.transparent,
                                  child:
                                      messagesList[index].replyTo == null
                                          ? MyMessageBubble(
                                            Message: messagesList[index],

                                            onLongPress: () async {
                                              messagesList[index].deleted
                                                  ? isDeleted = true
                                                  : isDeleted = false;
                                              setState(() {
                                                messageID =
                                                    messagesList[index].docID;

                                                selectionAppBarr = true;
                                              });
                                              docc =
                                                  await messages
                                                      .doc(messageID!)
                                                      .get();

                                              userNamemessageOwner =
                                                  docc!['userName'];
                                              messageOwnerId = docc!['UserId'];
                                            },
                                          )
                                          : ReplyMessageWidget(
                                            onTap: () {
                                              final replyID =
                                                  messagesList[index].replyTo;

                                              if (replyID == null) return;

                                              final repliedMessage =
                                                  messagesList.any(
                                                        (msg) =>
                                                            msg.docID ==
                                                            replyID,
                                                      )
                                                      ? messagesList.firstWhere(
                                                        (msg) =>
                                                            msg.docID ==
                                                            replyID,
                                                      )
                                                      : null;

                                              if (repliedMessage == null ||
                                                  repliedMessage.deleted)
                                                return;

                                              jumpToMessage(
                                                repliedMessage.docID,
                                                messagesList,
                                              );
                                            },
                                            Message: messagesList[index],
                                            ReplyToMessage: messagesList
                                                .firstWhere(
                                                  (msg) =>
                                                      msg.docID ==
                                                      messagesList[index]
                                                          .replyTo,
                                                ),
                                            onLongPress: () async {
                                              messagesList[index].deleted
                                                  ? isDeleted = true
                                                  : isDeleted = false;
                                              setState(() {
                                                messageID =
                                                    messagesList[index].docID;

                                                selectionAppBarr = true;
                                              });
                                              docc =
                                                  await messages
                                                      .doc(messageID!)
                                                      .get();
                                              userNamemessageOwner =
                                                  docc!['userName'];
                                              messageOwnerId = docc!['UserId'];
                                            },
                                          ),
                                )
                                : Container(
                                  key: messageKeys[message.docID],
                                  width: double.infinity,
                                  color:
                                      (isSelected)
                                          ? const Color.fromARGB(
                                            123,
                                            94,
                                            94,
                                            94,
                                          )
                                          : Colors.transparent,
                                  child:
                                      messagesList[index].replyTo == null
                                          ? FriendMessageBubble(
                                            onLongPress: () async {
                                              messagesList[index].deleted
                                                  ? isDeleted = true
                                                  : isDeleted = false;
                                              setState(() {
                                                messageID =
                                                    messagesList[index].docID;

                                                selectionAppBarr = true;
                                              });
                                              docc =
                                                  await messages
                                                      .doc(messageID!)
                                                      .get();
                                              userNamemessageOwner =
                                                  docc!['userName'];
                                              messageOwnerId = docc!['UserId'];
                                            },
                                            Message: messagesList[index],
                                          )
                                          : FriendReplyToAnyMessage(
                                            currentUsername:
                                                arguments['userName'],
                                            Message: messagesList[index],
                                            ReplyToMessage: messagesList
                                                .firstWhere(
                                                  (msg) =>
                                                      msg.docID ==
                                                      messagesList[index]
                                                          .replyTo,
                                                ),
                                            onTap: () {
                                              final replyID =
                                                  messagesList[index].replyTo;

                                              if (replyID == null) return;

                                              final repliedMessage =
                                                  messagesList.any(
                                                        (msg) =>
                                                            msg.docID ==
                                                            replyID,
                                                      )
                                                      ? messagesList.firstWhere(
                                                        (msg) =>
                                                            msg.docID ==
                                                            replyID,
                                                      )
                                                      : null;

                                              if (repliedMessage == null ||
                                                  repliedMessage.deleted)
                                                return;

                                              jumpToMessage(
                                                repliedMessage.docID,
                                                messagesList,
                                              );
                                            },
                                            onLongPress: () async {
                                              messagesList[index].deleted
                                                  ? isDeleted = true
                                                  : isDeleted = false;
                                              setState(() {
                                                messageID =
                                                    messagesList[index].docID;
                                                selectionAppBarr = true;
                                              });
                                              docc =
                                                  await messages
                                                      .doc(messageID!)
                                                      .get();
                                              userNamemessageOwner =
                                                  docc!['userName'];
                                              messageOwnerId = docc!['UserId'];
                                            },
                                          ),
                                );
                          },
                          reverse: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        child: TextfeildWidgetAtChatpage(
                          controller: controller,
                          messages: messages,
                          email: arguments['email'],
                          userName: arguments['userName'],
                          color: arguments['color'] ?? '0xffFFFFFF',
                          ReplyToMessage: ReplyToMessage,
                          messageID: messageID,
                          isReply: isReply,

                          selectionAppBarr: selectionAppBarr,
                          onResetReply: () {
                            setState(() {
                              isReply = false;
                              ReplyToMessage = null;
                              messageID = null;
                              selectionAppBarr = false;
                              ScrollToBottom();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (showButton)
                    Positioned(
                      bottom: 60,
                      right: 5,
                      child: FloatingActionButton(
                        shape: CircleBorder(),
                        mini: true,
                        onPressed: ScrollToBottom,
                        child: Icon(Icons.arrow_downward, color: Colors.white),
                        backgroundColor: const Color.fromARGB(
                          255,
                          105,
                          113,
                          112,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, LoginPage.id);
                },
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
              ),
              backgroundColor: kPraimaryColor,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/scholar.png', scale: 1.7),
                  Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
            body: ModalProgressHUD(
              inAsyncCall: isloading,
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                strokeWidth: 5,
              ),
              child: Container(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void ScrollToBottom() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }
}
