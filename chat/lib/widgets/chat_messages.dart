import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. الحصول على المستخدم الحالي (لتحقيق شرط 'رسائلي أنا')
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    final currentDeviceWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong!'));
        }

        final loadedMessages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatDoc = loadedMessages[index];
            final messageData = chatDoc.data();
            final messageText = messageData['Text'] as String;
            final Timestamp timestamp = messageData['created_at'];
            final userName =
                messageData['user_name'] as String? ?? 'Unknown User';
            final senderId =
                messageData['user_id'] as String; // الحصول على معرف المرسل

            // 2. 🌟 تحديد ما إذا كانت الرسالة خاصة بالمستخدم الحالي
            final isMe = authenticatedUser.uid == senderId;

            final time = timestamp.toDate();
            final formattedTime =
                '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

            // 3. تحديد اللون والتنسيق بناءً على isMe
            final bubbleColor = isMe
                ? const Color.fromARGB(255, 16, 103, 137) // أزرق غامق (رسائلك)
                : Colors.grey[300]; // رمادي فاتح (رسائل الآخرين)

            final textColor = isMe ? Colors.white : Colors.black87;
            final timeColor = isMe ? Colors.white70 : Colors.black54;

            final mainAxisAlignment = isMe
                ? MainAxisAlignment
                      .end // يمين (رسائلك)
                : MainAxisAlignment.start; // يسار (رسائل الآخرين)

            final crossAxisAlignment = isMe
                ? CrossAxisAlignment
                      .end // محاذاة النص والوقت لليمين داخل الفقاعة
                : CrossAxisAlignment
                      .start; // محاذاة النص والوقت لليسار داخل الفقاعة

            final usernamePadding = isMe
                ? const EdgeInsets.only(right: 12.0, bottom: 4.0, top: 8.0)
                : const EdgeInsets.only(left: 12.0, bottom: 4.0, top: 8.0);

            return Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start, // محاذاة اسم المستخدم
              children: [
                // إضافة اسم المستخدم
                Padding(
                  padding: usernamePadding,
                  child: Text(
                    userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? colorScheme.primary
                          : Colors.grey, // لون مختلف لاسم مستخدم الآخرين
                    ),
                  ),
                ),
                // الـ Row المحتوي على الفقاعة
                Row(
                  mainAxisAlignment:
                      mainAxisAlignment, // ⬅️ محاذاة الفقاعة بالكامل
                  children: [
                    Container(
                      // ⬅️ تطبيق اللون الشرطي
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // إضافة حواف دائرية
                      ),
                      constraints: BoxConstraints(
                        maxWidth: currentDeviceWidth * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),

                      child: Column(
                        crossAxisAlignment:
                            crossAxisAlignment, // ⬅️ محاذاة النص داخل الفقاعة
                        children: [
                          Text(
                            messageText,
                            style: TextStyle(
                              color: textColor, // ⬅️ لون الخط الشرطي
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: timeColor, // ⬅️ لون الوقت الشرطي
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
