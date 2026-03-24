import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/issue_model.dart';
import '../services/firestore_service.dart';

class UserIssuesScreen extends StatelessWidget {
  final String userId;
  final String title;
  final String? statusFilter;

  const UserIssuesScreen({
    super.key,
    required this.userId,
    required this.title,
    this.statusFilter,
  });

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<IssueModel>>(
        stream: service.getIssuesByUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allIssues = snapshot.data ?? const [];
          final issues = statusFilter == null
              ? allIssues
              : allIssues
                  .where(
                    (issue) =>
                        issue.status.toLowerCase() == statusFilter!.toLowerCase(),
                  )
                  .toList();

          if (issues.isEmpty) {
            return Center(
              child: Text(
                statusFilter == null
                    ? 'No uploaded issues found.'
                    : 'No $statusFilter issues found.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (issue.hasImage) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: IssueImage(issue: issue),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        issue.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${issue.status}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(issue.timestamp)}',
                      ),
                      Text(
                        'Location: ${issue.latitude.toStringAsFixed(5)}, ${issue.longitude.toStringAsFixed(5)}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class IssueImage extends StatelessWidget {
  final IssueModel issue;

  const IssueImage({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    if (issue.imageUrl.isNotEmpty) {
      return Image.network(
        issue.imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _inlineImageOrFallback(),
      );
    }

    return _inlineImageOrFallback();
  }

  Widget _inlineImageOrFallback() {
    if (issue.imageBase64.isEmpty) {
      return _fallback();
    }

    try {
      return Image.memory(
        base64Decode(issue.imageBase64),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (_) {
      return _fallback();
    }
  }

  Widget _fallback() {
    return Container(
      height: 180,
      width: double.infinity,
      color: const Color(0xFFE8F1ED),
      alignment: Alignment.center,
      child: const Text('Image unavailable'),
    );
  }
}
