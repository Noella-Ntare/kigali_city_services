import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final user = auth.userProfile;
    final firebaseUser = auth.firebaseUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.navyCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.navyLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.gold,
                    child: Text(
                      (user?.displayName ?? firebaseUser?.displayName ?? 'U')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                          fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ??
                              firebaseUser?.displayName ??
                              'User',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? firebaseUser?.email ?? '',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              firebaseUser?.emailVerified == true
                                  ? Icons.verified
                                  : Icons.warning_amber,
                              size: 14,
                              color: firebaseUser?.emailVerified == true
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              firebaseUser?.emailVerified == true
                                  ? 'Email Verified'
                                  : 'Email Not Verified',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: firebaseUser?.emailVerified == true
                                      ? AppColors.success
                                      : AppColors.error),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Preferences',
                style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),

            // Notification toggle
            _SettingTile(
              icon: Icons.notifications_outlined,
              title: 'Location Notifications',
              subtitle: 'Get alerts for services near you',
              trailing: Switch(
                value: settings.locationNotifications,
                onChanged: (_) => context
                    .read<SettingsProvider>()
                    .toggleLocationNotifications(),
                activeThumbColor: AppColors.gold,
                inactiveTrackColor: AppColors.navyLight,
              ),
            ),
            const SizedBox(height: 8),

            const _SettingTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Always on',
              trailing: Icon(Icons.check, color: AppColors.gold, size: 18),
            ),
            const SizedBox(height: 24),

            const Text('Account',
                style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),

            const _SettingTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
              trailing: null,
            ),
            const SizedBox(height: 24),

            // Sign Out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.navyCard,
                      title: const Text('Sign Out',
                          style: TextStyle(color: AppColors.textPrimary)),
                      content: const Text('Are you sure you want to sign out?',
                          style: TextStyle(color: AppColors.textMuted)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel',
                              style: TextStyle(color: AppColors.textMuted)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sign Out',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await context.read<AuthProvider>().signOut();
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Sign Out',
                    style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navyLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textDim, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
