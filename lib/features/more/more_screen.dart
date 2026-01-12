import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/session_repository.dart';
import '../../routes/app_routes.dart';
import '../settings/settings_screen.dart';
import '../about/about_screen.dart';

/// MoreScreen - Settings, profile, and app info
/// 
/// Sections:
/// - Profile card (username, avatar, auth buttons)
/// - General (Settings, About)
/// - App (Exit)
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final _sessionRepo = SessionRepository();
  String _username = '';
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    setState(() {
      _username = _sessionRepo.getUsername() ?? 'User';
      _isGuest = _sessionRepo.isGuest();
    });
  }

  String get _userInitial {
    return _username.isNotEmpty ? _username[0].toUpperCase() : 'U';
  }

  Future<void> _handleSignIn() async {
    await Navigator.pushNamed(context, AppRoutes.login);
    _loadUserInfo();
  }

  Future<void> _handleRegister() async {
    await Navigator.pushNamed(context, AppRoutes.register);
    _loadUserInfo();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?\nYou will be switched to Guest mode.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sessionRepo.logout();
      _loadUserInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Future<void> _handleAbout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  void _handleExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => SystemNavigator.pop(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildProfileCard(),
          const Divider(),
          
          // General Section
          _buildSectionHeader('General'),
          _buildListTile(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences and theme',
            onTap: _handleSettings,
          ),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App information',
            onTap: _handleAbout,
          ),
          const Divider(),
          
          // App Section
          _buildSectionHeader('App'),
          _buildListTile(
            icon: Icons.exit_to_app,
            title: 'Exit',
            subtitle: 'Close the application',
            onTap: _handleExit,
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              _userInitial,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Username
          Text(
            _username,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          
          // User type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _isGuest ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _isGuest ? 'GUEST' : 'USER',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Auth buttons
          if (_isGuest) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _handleRegister,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register'),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
