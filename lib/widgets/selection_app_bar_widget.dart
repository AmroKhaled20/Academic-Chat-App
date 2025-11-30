import 'package:flutter/material.dart';

class SelectionAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  SelectionAppBarWidget({
    required this.onclose,
    required this.onDelete,
    required this.onReply,
    required this.isDeleted,
  });
  final VoidCallback onclose;
  final VoidCallback onDelete;
  final VoidCallback onReply;
  final bool Function() isDeleted;

  @override
  Widget build(BuildContext context) {
    final i = isDeleted();
    return AppBar(
      backgroundColor: Colors.blueGrey,
      leading: IconButton(
        onPressed: onclose,
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
      ),
      actions: [
        i != true
            ? IconButton(
              onPressed: onReply,
              icon: Icon(
                Icons.subdirectory_arrow_left_outlined,
                color: Colors.white,
                size: 32,
              ),
            )
            : SizedBox(width: 0),
        IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete, color: Colors.white, size: 32),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
