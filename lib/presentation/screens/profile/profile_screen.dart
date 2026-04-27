import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../../services/avatar_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService.instance;
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.profileTab)),
          body: user == null
              ? _UnauthorizedProfile(onOpenAuth: () => _showAuthSheet(context))
              : _AuthorizedProfile(user: user),
        );
      },
    );
  }

  void _showAuthSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _AuthSheet(),
    );
  }
}

class _UnauthorizedProfile extends StatelessWidget {
  final VoidCallback onOpenAuth;

  const _UnauthorizedProfile({required this.onOpenAuth});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 1,
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.signInToAccount,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.profileSignInSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onOpenAuth,
                    icon: const Icon(Icons.login),
                    label: Text(l10n.signInOrRegister),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorizedProfile extends StatelessWidget {
  final User user;

  const _AuthorizedProfile({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return StreamBuilder<Map<String, dynamic>?>(
      stream: AuthService.instance.watchUserProfile(user.uid),
      builder: (context, snapshot) {
        final data = snapshot.data ?? const <String, dynamic>{};
        final createdAtRaw = data['registrationDate'];
        final createdAt =
            createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now();
        final plan = (data['tariffPlan'] as String?) ?? 'free';
        final isPro = plan.toLowerCase() != 'free';
        final avatarUrl = (data['avatarUrl'] as String?) ?? user.photoURL;
        final name =
            (data['name'] as String?) ??
            user.displayName ??
            l10n.defaultUserName;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primary,
                          backgroundImage:
                              avatarUrl != null ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl == null
                              ? Text(
                                  _initials(name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        _PlanBadge(isPro: isPro, label: plan),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${l10n.emailLabel}: ${user.email ?? l10n.notSpecified}',
                    ),
                    Text(
                      '${l10n.phoneLabel}: ${user.phoneNumber ?? l10n.notSpecified}',
                    ),
                    Text(
                      '${l10n.registrationDate}: ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(createdAt)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.subscriptionStatus, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _PlanBenefitRow(
                      icon: isPro ? Icons.check_circle : Icons.lock_outline,
                      text: isPro
                          ? l10n.proBenefitUnlimitedHabits
                          : l10n.freeBenefitHabitLimit,
                    ),
                    _PlanBenefitRow(
                      icon: isPro ? Icons.check_circle : Icons.lock_outline,
                      text: isPro
                          ? l10n.proBenefitPrioritySupport
                          : l10n.freeBenefitBasicSupport,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _pickAndUploadAvatar(context, user),
              icon: const Icon(Icons.photo_camera_back_outlined),
              label: Text(l10n.changeAvatar),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showEditNameDialog(context, user, name),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.editName),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/account-management'),
              icon: const Icon(Icons.manage_accounts_outlined),
              label: Text(l10n.accountManagement),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async => AuthService.instance.signOut(),
              icon: const Icon(Icons.logout),
              label: Text(l10n.signOut),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    User user,
    String currentName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.editName),
        content: TextField(
          controller: controller,
          inputFormatters: [LengthLimitingTextInputFormatter(40)],
          decoration: InputDecoration(labelText: l10n.nameFieldLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final nextName = controller.text.trim();
              if (nextName.isEmpty) return;
              await AuthService.instance.updateProfileName(
                user: user,
                name: nextName,
              );
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _pickAndUploadAvatar(BuildContext context, User user) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final file = await AvatarService.instance.pickAvatar();
      if (file == null) return;
      final url = await AvatarService.instance.uploadAvatar(uid: user.uid, file: file);
      await AuthService.instance.updateAvatarUrl(user: user, avatarUrl: url);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.avatarUpdated)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.avatarUpdateFailed}: $e')),
      );
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final chars = parts.take(2).map((e) => e[0].toUpperCase()).join();
    return chars.isEmpty ? 'U' : chars;
  }
}

class _PlanBadge extends StatelessWidget {
  final bool isPro;
  final String label;

  const _PlanBadge({required this.isPro, required this.label});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final normalized = label.toLowerCase() == 'free' ? l10n.planFree : label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${isPro ? "PRO" : "FREE"} · $normalized',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

class _PlanBenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlanBenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _AuthSheet extends StatefulWidget {
  const _AuthSheet();

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService.instance;

  bool _isRegister = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.authTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.authSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (_isRegister)
                TextFormField(
                  controller: _nameController,
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  decoration: InputDecoration(
                    labelText: l10n.nameFieldLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (_isRegister && v.isEmpty) return l10n.enterNameError;
                    if (_isRegister && v.length > 40) return 'Максимум 40 символов';
                    return null;
                  },
                ),
              if (_isRegister) const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return l10n.enterValidEmailError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return l10n.minPasswordError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loading ? null : _submitEmailAuth,
                child: Text(_isRegister ? l10n.registerAction : l10n.signInAction),
              ),
              TextButton(
                onPressed: _loading ? null : () => setState(() => _isRegister = !_isRegister),
                child: Text(
                  _isRegister ? l10n.haveAccountSignIn : l10n.noAccountRegister,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              OutlinedButton.icon(
                onPressed: _loading ? null : _submitGoogleAuth,
                icon: const Icon(Icons.g_mobiledata),
                label: Text(l10n.googleSignIn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      if (_isRegister) {
        await _authService.registerWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
        );
      } else {
        await _authService.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? l10n.authError);
    } catch (_) {
      _showError(l10n.signInFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitGoogleAuth() async {
    setState(() => _loading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await _authService.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? l10n.googleSignInError);
    } catch (_) {
      _showError(l10n.googleSignInFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
