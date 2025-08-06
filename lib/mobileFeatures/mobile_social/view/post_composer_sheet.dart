import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merinocizgi/core/providers/account_providers.dart';
import 'package:merinocizgi/core/theme/colors.dart';
import 'package:merinocizgi/core/theme/typography.dart';
import 'package:uuid/uuid.dart';

class PostComposerSheet extends ConsumerStatefulWidget {
  const PostComposerSheet({super.key});

  @override
  ConsumerState<PostComposerSheet> createState() => _PostComposerSheetState();
}

class _PostComposerSheetState extends ConsumerState<PostComposerSheet> {
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

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext) {
    final currentUser = ref.watch(currentUserProfileProvider);
    final profileImageUrl = currentUser.when(
      data: (currentUser) => currentUser!['profileImageUrl'],
      error: (_, __) => null,
      loading: () => null,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          // color: AppColors.primary.withOpacity(0.1),
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.6), width: 1.5),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
          child: SafeArea(
            child: Padding(
              padding: MediaQuery.of(context).viewInsets, // klavyeye göre kayar
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 6.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        height: 3,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(20),
                        )),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      maxLines: 5,
                      decoration: InputDecoration(
                        prefix: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: CircleAvatar(
                            backgroundImage: (profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty)
                                ? NetworkImage(profileImageUrl!)
                                : null,
                            child: profileImageUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        ),
                        hintText: 'Ne düşünüyorsun?',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.6),
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Clarity.image_line),
                          label: Text("Görsel Ekle",
                              style: AppTextStyles.oswaldText.copyWith(
                                  fontSize: 14, color: Colors.white70)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(color: Colors.white70)),
                        ),
                        const SizedBox(width: 8),
                        if (_pickedImage != null)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_pickedImage!.path),
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -9,
                                right: -9,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _pickedImage = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  "Paylaş",
                                  style: AppTextStyles.oswaldText.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    // ElevatedButton(
                    //   onPressed: _isLoading ? null : _submit,
                    //   child: _isLoading
                    //       ? const CircularProgressIndicator()
                    //       : const Text("Paylaş"),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
