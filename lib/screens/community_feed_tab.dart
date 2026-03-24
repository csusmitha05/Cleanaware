import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class CommunityFeedTab extends StatefulWidget {
  final String userId;
  final String userName;

  const CommunityFeedTab({super.key, required this.userId, required this.userName});

  @override
  State<CommunityFeedTab> createState() => _CommunityFeedTabState();
}

class _CommunityFeedTabState extends State<CommunityFeedTab> {
  final TextEditingController _postController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _posting = false;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    setState(() => _posting = true);
    try {
      await _firestoreService.createFeedPost(
        userId: widget.userId,
        userName: widget.userName,
        content: content,
      );
      _postController.clear();
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD2E6DF)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _postController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share cleanup updates, ideas, or volunteer calls...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _posting ? null : _publishPost,
                  icon: const Icon(Icons.send),
                  label: Text(_posting ? 'Posting...' : 'Post Update'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.watchCommunityFeed(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data!;
              if (posts.isEmpty) {
                return const Center(child: Text('No posts yet. Start the community conversation.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final ts = post['timestamp'];
                  final timeText = ts is Timestamp
                      ? _timeAgo(ts.toDate())
                      : 'just now';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                child: Icon(Icons.person, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  post['userName']?.toString() ?? 'Citizen',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(post['content']?.toString() ?? ''),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => _firestoreService.likeFeedPost(post['id'].toString()),
                                icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                              ),
                              Text('${post['likes'] ?? 0} likes'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
