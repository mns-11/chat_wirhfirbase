import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  // دالة مساعدة لبناء خيارات الإرفاق في القائمة المنسدلة
  Widget _buildAttachmentTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        onTap();
        // إغلاق القائمة المنسدلة بعد النقر
        Navigator.of(context).pop();
      },
    );
  }

  // دالة لعرض خيارات الإرفاق عند النقر على زر الزايد
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. صورة من الألبوم
              _buildAttachmentTile(
                'صورة من الألبوم',
                Icons.image,
                () => print('ACTION: Pick Image from Album'),
              ),
              // 2. الموقع
              _buildAttachmentTile(
                'الموقع',
                Icons.location_on,
                () => print('ACTION: Share Location'),
              ),
              // 3. ملف
              _buildAttachmentTile(
                'ملف',
                Icons.folder,
                () => print('ACTION: Share File'),
              ),
              // 4. تصويت (Poll)
              _buildAttachmentTile(
                'تصويت (Poll)',
                Icons.poll,
                () => print('ACTION: Create Poll'),
              ),
              // 5. حدث (Event)
              _buildAttachmentTile(
                'حدث (Event)',
                Icons.event,
                () => print('ACTION: Create Event'),
              ),
            ],
          ),
        );
      },
    );
  }

  _sendMessage() async {
    final message = _messageController.text;

    if (message.trim().isEmpty) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // 🏆 مسح حقل النص بعد الإرسال
    _messageController.clear();

    final DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    await FirebaseFirestore.instance.collection('chat').add({
      'Text': message,
      // 'password': _enteredPassword,
      'created_at': Timestamp.now(),
      'user_id': user.uid,
      'user_name': userData.data()?['user_name'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // تم تعديل padding لجعل زر الزايد أقرب للحافة اليسرى
      padding: const EdgeInsets.only(bottom: 25, left: 1, right: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ⬅️ 1. زر الزايد (Attachments)
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: const Icon(Icons.add),
            color: Theme.of(context).colorScheme.primary,
          ),

          // 2. حقل النص (يأخذ المساحة المتبقية)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 8.0,
              ), // مسافة بسيطة قبل زر الإرسال
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Send message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null, // يسمح بالسطور المتعددة
                textCapitalization: TextCapitalization.sentences,
                enableSuggestions: true,
                autocorrect: true,
              ),
            ),
          ),

          // 3. زر الإرسال
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
