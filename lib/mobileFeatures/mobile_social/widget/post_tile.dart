import 'package:flutter/material.dart';
import 'package:merinocizgi/domain/entities/post.dart';
import 'package:intl/intl.dart';

class PostTile extends StatelessWidget {
  final Post post;
  const PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy HH:mm').format(post.createdAt);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (post.userPhoto != null && post.userPhoto!.isNotEmpty)
            ? NetworkImage(post.userPhoto!)
            : null,
        child: post.userPhoto == null ? const Icon(Icons.person) : null,
      ),
      title: Text(post.userName,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(post.text),
            ),
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.imageUrl!, fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(date,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}
