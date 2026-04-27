import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = AuthService.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.accountManagement)),
        body: Center(child: Text(l10n.signInToAccount)),
      );
    }

    _emailController.text = _emailController.text.isEmpty
        ? (user.email ?? '')
        : _emailController.text;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountManagement)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.changeEmail, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loading ? null : () => _updateEmail(user),
            child: Text(l10n.save),
          ),
          const SizedBox(height: 18),
          Text(l10n.changePassword, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.passwordLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loading ? null : () => _updatePassword(user),
            child: Text(l10n.save),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _loading ? null : () => _confirmDelete(user),
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }

  Future<void> _updateEmail(User user) async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _show(l10n.enterValidEmailError);
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.updateEmail(user: user, newEmail: email);
      _show(l10n.emailUpdateSent);
    } on FirebaseAuthException catch (e) {
      _show(e.message ?? l10n.authError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updatePassword(User user) async {
    final l10n = AppLocalizations.of(context)!;
    final password = _passwordController.text;
    if (password.length < 6) {
      _show(l10n.minPasswordError);
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.updatePassword(user: user, newPassword: password);
      _show(l10n.passwordUpdated);
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      _show(e.message ?? l10n.authError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(User user) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await AuthService.instance.deleteAccount(user);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _show(e.message ?? l10n.authError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
