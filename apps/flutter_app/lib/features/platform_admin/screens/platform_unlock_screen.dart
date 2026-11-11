import 'package:flutter/material.dart';

import '../../authentication/providers/platform_auth_provider.dart';

class PlatformUnlockScreen extends StatefulWidget {
  const PlatformUnlockScreen({super.key});

  @override
  State<PlatformUnlockScreen> createState() => _PlatformUnlockScreenState();
}

class _PlatformUnlockScreenState extends State<PlatformUnlockScreen> {
  final _pinController = TextEditingController();
  bool _loading = false;

  Future<void> _unlock() async {
    if (!RegExp(r'^\d{6}).hasMatch(_pinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your 6-digit MPIN.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await PlatformAuthController.instance.unlockWithPin(_pinController.text);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              PlatformAuthController.instance.errorMessage ??
                  error.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      _pinController.clear();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06111F), Color(0xFF0B1E35), Color(0xFF102B4C)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Card(
                color: const Color(0xFF142A43),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_person_rounded,
                        size: 54,
                        color: Color(0xFF60A5FA),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your MPIN to unlock this remembered device.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFB7C8DC)),
                      ),
                      const SizedBox(height: 26),
                      TextField(
                        controller: _pinController,
                        autofocus: true,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 12,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: '••••••',
                          hintStyle: TextStyle(color: Color(0xFF7189A5)),
                          filled: true,
                          fillColor: Color(0xFF071A2E),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _unlock(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _loading ? null : _unlock,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Unlock'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : PlatformAuthController.instance
                                .forgetRememberedDevice,
                        child: const Text(
                          'Use email and password instead',
                          style: TextStyle(color: Color(0xFF93C5FD)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
).hasMatch(_pinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your 6-digit MPIN.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await PlatformAuthController.instance.unlockWithPin(_pinController.text);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              PlatformAuthController.instance.errorMessage ??
                  error.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
      _pinController.clear();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF06111F), Color(0xFF0B1E35), Color(0xFF102B4C)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Card(
                color: const Color(0xFF142A43),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_person_rounded,
                        size: 54,
                        color: Color(0xFF60A5FA),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your MPIN to unlock this remembered device.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFB7C8DC)),
                      ),
                      const SizedBox(height: 26),
                      TextField(
                        controller: _pinController,
                        autofocus: true,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 12,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: '••••••',
                          hintStyle: TextStyle(color: Color(0xFF7189A5)),
                          filled: true,
                          fillColor: Color(0xFF071A2E),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _unlock(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _loading ? null : _unlock,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Unlock'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : PlatformAuthController.instance
                                .forgetRememberedDevice,
                        child: const Text(
                          'Use email and password instead',
                          style: TextStyle(color: Color(0xFF93C5FD)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
