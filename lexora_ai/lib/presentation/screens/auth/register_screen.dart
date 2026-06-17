import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/user_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  String _selectedNative = 'Uzbek';
  final List<String> _nativeLanguages = ['Uzbek', 'Russian', 'Turkish', 'Arabic', 'Other'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userState = ref.watch(userProvider);

    ref.listen(userProvider, (prev, next) {
      if (next.isAuthenticated) context.go('/home');
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E0C1E), Color(0xFF1A1730)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Create Account',
                    style: theme.textTheme.displayMedium?.copyWith(color: Colors.white),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),
                  Text(
                    'Start your English mastery journey',
                    style: TextStyle(color: AppColors.textWhite50, fontSize: 14),
                  ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 32),

                  _buildField('Full Name', _nameCtrl, Icons.person_outline_rounded,
                    validator: (v) => v!.length >= 2 ? null : 'Enter your name'),
                  const SizedBox(height: 16),
                  _buildField('Email', _emailCtrl, Icons.email_outlined,
                    type: TextInputType.emailAddress,
                    validator: (v) => v!.contains('@') ? null : 'Invalid email'),
                  const SizedBox(height: 16),
                  _buildField('Password', _passCtrl, Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textWhite30, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => v!.length >= 6 ? null : 'Min 6 characters'),

                  const SizedBox(height: 20),

                  Text('Native Language', style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedNative,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1A1730),
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        items: _nativeLanguages.map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(l),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedNative = v!),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: userState.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: userState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                          : const Text('Create Account',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ).animate(delay: 400.ms).fadeIn(),

                  const SizedBox(height: 20),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: AppColors.textWhite50, fontSize: 14)),
                        GestureDetector(
                          onTap: () => context.go('/auth/login'),
                          child: const Text('Sign In',
                            style: TextStyle(color: AppColors.primaryLight, fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {
    bool obscure = false,
    TextInputType? type,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: type,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textWhite30, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5)),
          ),
        ),
      ],
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ref.read(userProvider.notifier).signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
