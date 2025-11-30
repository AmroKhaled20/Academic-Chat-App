import 'package:cloud_firestore/cloud_firestore.dart';

List<String> colors = [
  "#FF6F61", // مرجاني هادي
  "#FFA500", // برتقالي دافئ
  "#FFD700", // ذهبي هادي
  "#ADFF2F", // أخضر فاتح نسبياً
  "#32CD32", // أخضر ليموني هادي
  "#40E0D0", // فيروزي هادي
  "#1E90FF", // أزرق سماوي
  "#6495ED", // أزرق باهت
  "#9370DB", // بنفسجي متوسط
  "#BA55D3", // بنفسجي وردي
  "#FF69B4", // وردي هادي
  "#FF4500", // برتقالي أحمر
  "#FF6347", // طماطمي هادي
  "#00CED1", // تركوازي هادي
  "#3CB371", // أخضر نباتي
  "#7FFF00", // أخضر ليموني فاتح
  "#FFA07A", // مشمشي هادي
  "#D2691E", // بني محروق هادي
  "#EE82EE", // بنفسجي فاتح
  "#87CEEB", // أزرق سماوي فاتح
];

Future<String> getColor(List<String> colors) async {
  try {
    colors.shuffle();
    for (String color in colors) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .where("color", isEqualTo: color)
              .get();

      if (snapshot.docs.isEmpty) {
        return color;
      }
    }

    return colors[0];
  } catch (e) {
    print(e.toString());
    return '#FFFFFF';
  }
}
