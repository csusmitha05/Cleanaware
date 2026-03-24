import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/issue_model.dart';

class FirestoreService {
  static const int _maxInlineImageBytes = 700 * 1024;
  final CollectionReference<Map<String, dynamic>> _issues =
      FirebaseFirestore.instance.collection('issues');
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> _events =
      FirebaseFirestore.instance.collection('events');
  final CollectionReference<Map<String, dynamic>> _leaders =
      FirebaseFirestore.instance.collection('leadership');
  final CollectionReference<Map<String, dynamic>> _feed =
      FirebaseFirestore.instance.collection('community_feed');

  Future<void> saveFcmToken({required String userId, required String token}) async {
    await _users.doc(userId).set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<int> getTotalIssuesCount() async {
    final snapshot = await _issues.get();
    return snapshot.docs.length;
  }

  Future<int> getUserIssuesCount(String userId) async {
    final snapshot = await _issues.where('userId', isEqualTo: userId).get();
    return snapshot.docs.length;
  }

  Stream<List<IssueModel>> getIssuesByUser(String userId) {
    return _issues
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IssueModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<IssueModel>> getAllIssues() {
    return _issues
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IssueModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<String> uploadIssueImage({
    required String userId,
    required XFile image,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('issues')
        .child(userId)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      final uploadTask = kIsWeb
          ? ref.putData(
              await image.readAsBytes(),
              SettableMetadata(contentType: 'image/jpeg'),
            )
          : ref.putFile(
              File(image.path),
              SettableMetadata(contentType: 'image/jpeg'),
            );

      final snapshot = await uploadTask;
      return snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception(
        'Image upload failed (${e.code}). Please check Firebase Storage is enabled and try again.',
      );
    }
  }

  Future<String> encodeIssueImageFallback(XFile image) async {
    final bytes = await image.readAsBytes();
    if (bytes.length > _maxInlineImageBytes) {
      throw Exception(
        'The selected photo is too large to attach directly. Please choose a smaller image.',
      );
    }
    return base64Encode(bytes);
  }

  Future<void> createIssue({
    required String userId,
    required String description,
    required double latitude,
    required double longitude,
    required String imageUrl,
    String imageBase64 = '',
  }) async {
    await _issues.add({
      'userId': userId,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageURL': imageUrl,
      'imageBase64': imageBase64,
      'timestamp': Timestamp.now(),
      'status': 'Pending',
    });
  }

  Future<void> updateIssueStatus({required String issueId, required String status}) async {
    await _issues.doc(issueId).update({'status': status});
  }

  Stream<List<Map<String, dynamic>>> watchEvents() {
    return _events.orderBy('eventDate').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> watchLeadership() {
    return _leaders.orderBy('score', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> watchCommunityFeed() {
    return _feed.orderBy('timestamp', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<void> createFeedPost({
    required String userId,
    required String userName,
    required String content,
  }) async {
    await _feed.add({
      'userId': userId,
      'userName': userName,
      'content': content,
      'likes': 0,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> likeFeedPost(String postId) async {
    await _feed.doc(postId).update({'likes': FieldValue.increment(1)});
  }

  Future<void> ensureCommunitySeedData() async {
    final eventsSnapshot = await _events.limit(1).get();
    if (eventsSnapshot.docs.isEmpty) {
      await _events.add({
        'title': 'Lakefront Revival Drive',
        'location': 'Sector 9 Lake',
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'volunteers': 24,
      });
      await _events.add({
        'title': 'No-Plastic Bazaar Challenge',
        'location': 'Central Market',
        'eventDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'volunteers': 18,
      });
    }

    final leadersSnapshot = await _leaders.limit(1).get();
    if (leadersSnapshot.docs.isEmpty) {
      await _leaders.add({'name': 'Aarav Patel', 'score': 420, 'badge': 'Zone Champion'});
      await _leaders.add({'name': 'Sree Lakshmi', 'score': 385, 'badge': 'Rapid Reporter'});
      await _leaders.add({'name': 'Maya Reddy', 'score': 360, 'badge': 'Eco Ambassador'});
    }
  }
}
