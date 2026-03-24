import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_wrapper_screen.dart';
import '../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;
  String? _statusMessage;
  bool _statusIsError = false;

  void _setStatus(String message, {required bool isError}) {
    setState(() {
      _statusMessage = message;
      _statusIsError = isError;
    });
  }

  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    final error = await context.read<AuthService>().sendEmailVerification();
    if (!mounted) return;
    setState(() {
      _busy = false;
    });
    _setStatus(
      error ?? 'Verification link sent. Check inbox and spam folder.',
      isError: error != null,
    );
  }

  Future<void> _iVerified() async {
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    final verified = await context.read<AuthService>().reloadAndCheckEmailVerified();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!verified) {
      _setStatus('Email still not verified. Please verify and try again.', isError: true);
      return;
    }
    _setStatus('Verified successfully. Signing you in...', isError: false);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthWrapperScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final email = auth.currentUser?.email ?? 'your email';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F766E).withValues(alpha: 0.9),
                    const Color(0xFFDCF5EE),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.mark_email_read_outlined, size: 46, color: Color(0xFF0F766E)),
                        const SizedBox(height: 10),
                        const Text(
                          'Verify Your Email',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We sent a verification link to $email',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _busy ? null : _iVerified,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('I Verified, Continue'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _resend,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Resend Verification Email'),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _busy ? null : () => context.read<AuthService>().logout(),
                          icon: const Icon(Icons.logout),
                          label: const Text('Use another account'),
                        ),
                        if (_statusMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _statusMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _statusIsError
                                    ? Theme.of(context).colorScheme.error
                                    : const Color(0xFF0F766E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (_busy)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
