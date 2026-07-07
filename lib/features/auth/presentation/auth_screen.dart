import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/supabase/supabase_client.dart';

/// Auth entry — email/password sign up + sign in via Supabase.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _handle = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _handle.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() { _loading = true; _error = null; });

    try {
      if (_isSignUp) {
        final handle = _handle.text.trim().replaceFirst('@', '');
        if (handle.isEmpty) {
          setState(() { _error = 'Pick a handle'; _loading = false; });
          return;
        }
        await SupabaseConfig.client.auth.signUp(
          email: email,
          password: password,
          data: {'handle': handle},
        );
      } else {
        await SupabaseConfig.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.skewX(-0.244),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                      boxShadow: const [BoxShadow(color: Color(0x383B82F6), blurRadius: 24)],
                    ),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.skewX(0.244),
                      child: const Text('🔑', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Goal Isle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 28),
                if (_isSignUp)
                  _input(_handle, 'handle', keyboard: TextInputType.text),
                _input(_email, 'email', keyboard: TextInputType.emailAddress),
                const SizedBox(height: 8),
                _input(_password, 'password', obscure: true),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isSignUp ? 'Join' : 'Sign in', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() { _isSignUp = !_isSignUp; _error = null; }),
                  child: Text(_isSignUp ? 'Have an account? Sign in' : 'New here? Join'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String hint, {bool obscure = false, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFECEFF2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
