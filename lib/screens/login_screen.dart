import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _rememberLoaded = false;
  bool _loading = false;
  String? _statusMessage;
  bool _statusIsError = false;
  int _statusVersion = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_rememberLoaded) {
      _rememberMe = context.read<AuthService>().rememberMe;
      _rememberLoaded = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setStatus(
    String message, {
    required bool isError,
    Duration? autoClearAfter,
  }) {
    _statusVersion += 1;
    final localVersion = _statusVersion;
    setState(() {
      _statusMessage = message;
      _statusIsError = isError;
    });
    if (autoClearAfter != null) {
      Future<void>.delayed(autoClearAfter, () {
        if (!mounted || localVersion != _statusVersion) return;
        setState(() {
          _statusMessage = null;
        });
      });
    }
  }

  Future<void> _emailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    final error = await context.read<AuthService>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      _setStatus(error, isError: true);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    final error = await context.read<AuthService>().signInWithGoogle();
    setState(() => _loading = false);

    if (error != null) {
      _setStatus(error, isError: true);
    }
  }

  Future<void> _forgotPassword() async {
    final emailController = TextEditingController(text: _emailController.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, emailController.text.trim()),
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
    emailController.dispose();
    if (email == null || email.isEmpty) return;
    if (!mounted) return;

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _setStatus('Enter a valid email address.', isError: true);
      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    final error = await context.read<AuthService>().sendPasswordResetEmail(email: email);
    if (!mounted) return;
    setState(() => _loading = false);
    _setStatus(
      error ?? 'Password reset link sent. Check inbox and spam folder.',
      isError: error != null,
      autoClearAfter: error == null ? const Duration(seconds: 4) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F766E).withValues(alpha: 0.88),
                    const Color(0xFFEAF5F2),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: Card(
                  color: Colors.white.withValues(alpha: 0.9),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.shield_moon_rounded, size: 46, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          'Secure Sign In',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in using email/password or Google',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (_) {
                                  if (_statusMessage != null) {
                                    setState(() => _statusMessage = null);
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) return 'Enter your email';
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                onChanged: (_) {
                                  if (_statusMessage != null) {
                                    setState(() => _statusMessage = null);
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if ((value ?? '').isEmpty) return 'Enter your password';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      controlAffinity: ListTileControlAffinity.leading,
                                      title: const Text('Remember me'),
                                      value: _rememberMe,
                                      onChanged: _loading
                                          ? null
                                          : (value) {
                                              if (value == null) return;
                                              setState(() => _rememberMe = value);
                                            },
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _loading ? null : _forgotPassword,
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: _loading ? null : _emailSignIn,
                          child: const Text('Sign in'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('or'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _googleSignIn,
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: const Text('Sign in with Google'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                                  );
                                },
                          child: const Text("No account? Create one"),
                        ),
                        if (_statusMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _statusMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _statusIsError
                                    ? theme.colorScheme.error
                                    : const Color(0xFF0F766E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (_loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: CircularProgressIndicator(),
                            ),
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
