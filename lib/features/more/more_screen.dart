import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/avatar_repository.dart';
import '../../core/services/backup_service.dart';
import '../../routes/app_routes.dart';
import '../settings/settings_screen.dart';
import '../about/about_screen.dart';

/// MoreScreen - Settings, profile, and app info
/// 
/// Sections:
/// - Profile card (username, avatar animation, auth buttons)
/// - General (Settings, About)
/// - App (Exit)
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final _sessionRepo = SessionRepository();
  final _avatarRepo = AvatarRepository();
  final _backupService = BackupService();
  String _username = '';
  bool _isGuest = false;
  String _avatarType = 'male'; // Default avatar type
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final avatarType = await _avatarRepo.getAvatarType();
    setState(() {
      _username = _sessionRepo.getUsername() ?? 'User';
      _isGuest = _sessionRepo.isGuest();
      _avatarType = avatarType;
    });
  }

  String get _userInitial {
    return _username.isNotEmpty ? _username[0].toUpperCase() : 'U';
  }
  
  String get _avatarAssetPath {
    return 'assets/animations/avatar-$_avatarType.json';
  }
  
  Future<void> _showAvatarSelectionDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Avatar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Male Avatar Option
              InkWell(
                onTap: () => Navigator.pop(context, 'male'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _avatarType == 'male' ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Lottie.asset(
                          'assets/animations/avatar-male.json',
                          fit: BoxFit.contain,
                          repeat: false,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 48);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Male Avatar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _avatarType == 'male' ? 'Current' : 'Select',
                              style: TextStyle(
                                fontSize: 12,
                                color: _avatarType == 'male' ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_avatarType == 'male')
                        const Icon(Icons.check_circle, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Female Avatar Option
              InkWell(
                onTap: () => Navigator.pop(context, 'female'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _avatarType == 'female' ? Colors.pink : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Lottie.asset(
                          'assets/animations/avatar-female.json',
                          fit: BoxFit.contain,
                          repeat: false,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 48);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Female Avatar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _avatarType == 'female' ? 'Current' : 'Select',
                              style: TextStyle(
                                fontSize: 12,
                                color: _avatarType == 'female' ? Colors.pink : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_avatarType == 'female')
                        const Icon(Icons.check_circle, color: Colors.pink),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null && selected != _avatarType) {
      final success = await _avatarRepo.setAvatarType(selected);
      if (success) {
        setState(() {
          _avatarType = selected;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Avatar changed to ${selected == 'male' ? 'Male' : 'Female'}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
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
      // Reset avatar to default (male) on logout
      await _avatarRepo.resetAvatar();
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
  
  Future<void> _handleBackup() async {
    setState(() => _isLoading = true);
    
    try {
      final filePath = await _backupService.saveBackupToFile();
      
      if (!mounted) return;
      
      if (filePath != null) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        // Show success dialog with file location
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup Saved'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Backup file saved successfully!'),
                const SizedBox(height: 16),
                const Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    filePath,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create backup: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _handleRestore() async {
    // Show confirmation dialog
    final confirm = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'How would you like to restore your data?\n\n'
          '• Merge: Keep existing data and add backup data\n'
          '• Replace: Delete all current data and restore from backup',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context, 'merge'),
            child: const Text('Merge'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    
    if (confirm == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final success = await _backupService.restoreFromFile(
        mergeData: confirm == 'merge',
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload user info
        _loadUserInfo();
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          // Bold App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/more.json',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Text(
                  'MORE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Profile Section
                _buildProfileCard(isDark),
                const SizedBox(height: 8),
                
                // General Section
                _buildSectionHeader('GENERAL', isDark),
                _buildListTile(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences and theme',
                  onTap: _handleSettings,
                  isDark: isDark,
                ),
                _buildListTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App information',
                  onTap: _handleAbout,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                
                // Data Management Section
                _buildSectionHeader('DATA MANAGEMENT', isDark),
                _buildListTile(
                  icon: Icons.upload_file,
                  title: 'Backup Data',
                  subtitle: 'Export your reading data',
                  onTap: _isLoading ? null : _handleBackup,
                  isDark: isDark,
                ),
                _buildListTile(
                  icon: Icons.download,
                  title: 'Restore Data',
                  subtitle: 'Import backup file',
                  onTap: _isLoading ? null : _handleRestore,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                
                // App Section
                _buildSectionHeader('APP', isDark),
                _buildListTile(
                  icon: Icons.exit_to_app,
                  title: 'Exit',
                  subtitle: 'Close the application',
                  onTap: _handleExit,
                  iconColor: Colors.red,
                  isDark: isDark,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Avatar Animation with tap gesture for logged-in users
          GestureDetector(
            onTap: _isGuest ? null : _showAvatarSelectionDialog,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Center(
                      child: Transform.scale(
                        scale: 1.5,
                        child: Lottie.asset(
                          _avatarAssetPath,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          repeat: true,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback ke CircleAvatar jika gagal load animasi
                            return Icon(
                              Icons.person,
                              size: 70,
                              color: isDark ? Colors.white54 : Colors.black54,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                // Edit icon for logged-in users
                if (!_isGuest)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Username
          Text(
            _username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          
          // User type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _isGuest ? Colors.orange[700] : Colors.green[700],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _isGuest ? 'GUEST' : 'USER',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Auth buttons
          if (_isGuest) ...[
            Wrap(
              spacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _handleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _handleRegister,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Register'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isDark,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? (isDark ? Colors.white70 : Colors.black54)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black45,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white54 : Colors.black38,
        ),
        onTap: onTap,
      ),
    );
  }
}
