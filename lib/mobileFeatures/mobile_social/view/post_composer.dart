import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class PostComposerPage extends StatefulWidget {
  const PostComposerPage({super.key});

  @override
  State<PostComposerPage> createState() => _PostComposerPageState();
}

class _PostComposerPageState extends State<PostComposerPage> {
  final _controller = TextEditingController();
  XFile? _pickedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    String? imageUrl;

    // ✅ Firebase Storage'a resmi yükle
    if (_pickedImage != null) {
      final file = File(_pickedImage!.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('postImages')
          .child('${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg');

      final uploadTask = await storageRef.putFile(file);
      imageUrl = await uploadTask.ref.getDownloadURL();
    }

    final postId = const Uuid().v4();

    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    final userName = userDoc.data()?['mahlas'] ?? 'Kullanıcı';
    final userPhoto = userDoc.data()?['profileImageUrl'];

    await FirebaseFirestore.instance.collection("posts").doc(postId).set({
      "id": postId,
      "userId": user.uid,
      "userName": userName,
      "userPhoto": userPhoto,
      "text": _controller.text.trim(),
      "imageUrl": imageUrl,
      "createdAt": FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ne düşünüyorsun?")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Bir şeyler yaz...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_pickedImage != null)
              Image.file(
                File(_pickedImage!.path),
                height: 150,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Görsel Ekle"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Paylaş"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
