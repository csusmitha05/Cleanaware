import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/firestore_service.dart';
import 'user_issues_screen.dart';

class AdminIssuesScreen extends StatelessWidget {
  const AdminIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Issue Management')),
      body: StreamBuilder(
        stream: service.getAllIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final issues = snapshot.data ?? [];
          if (issues.isEmpty) {
            return const Center(child: Text('No issues found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
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
                        const SizedBox(height: 10),
                      ],
                      Text(
                        issue.description,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text('User: ${issue.userId}'),
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(issue.timestamp)}',
                      ),
                      Text('Status: ${issue.status}'),
                      Text(
                        'Location: ${issue.latitude.toStringAsFixed(5)}, ${issue.longitude.toStringAsFixed(5)}',
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: issue.status,
                        items: const [
                          DropdownMenuItem(
                            value: 'Pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'Resolved',
                            child: Text('Resolved'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null || value == issue.status) return;
                          service.updateIssueStatus(
                            issueId: issue.id,
                            status: value,
                          );
                        },
                        decoration: const InputDecoration(
                          labelText: 'Update Status',
                          border: OutlineInputBorder(),
                        ),
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
