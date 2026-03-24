import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'awareness_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'report_issue_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _firestoreService.ensureCommunitySeedData();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clean & Green Community',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _buildSelectedPage(user),
      bottomNavigationBar: NavigationBar(
        height: 74,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.add_location_alt_outlined), label: 'Report'),
          NavigationDestination(
              icon: Icon(Icons.lightbulb_outline), label: 'Tips'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSelectedPage(User? user) {
    switch (_selectedIndex) {
      case 0:
        return HomeTab(
          userName: user?.email?.split('@').first ?? 'Citizen',
          onGoReportIssue: () => setState(() => _selectedIndex = 1),
        );
      case 1:
        return ReportIssueTab(userId: user?.uid ?? '');
      case 2:
        return const AwarenessTab();
      case 3:
        return ProfileTab(userId: user?.uid ?? '', email: user?.email ?? '');
      default:
        return const SizedBox.shrink();
    }
  }
}
