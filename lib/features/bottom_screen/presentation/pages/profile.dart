import 'package:fitness_tracker/core/api/api_endpoint.dart';
import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:fitness_tracker/core/services/biometric/biometric_auth_service.dart';
import 'package:fitness_tracker/features/auth/presentation/pages/login_screen.dart';
import 'package:fitness_tracker/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:fitness_tracker/features/profilefeature_screen/page/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileSccreenState();
}

class _ProfileSccreenState extends ConsumerState<ProfileScreen> {
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  
  @override
  void initState() {
    super.initState();
    // Refresh session data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // print('👤 ProfileScreen: Refreshing session data...');
      ref.invalidate(userSessionServiceProvider);
      _checkBiometricAvailability();
    });
  }
  
  Future<void> _checkBiometricAvailability() async {
    final biometricService = ref.read(biometricAuthServiceProvider);
    final canCheckBiometrics = await biometricService.canCheckBiometrics();
    final isDeviceSupported = await biometricService.isDeviceSupported();
    final availableBiometrics = await biometricService.getAvailableBiometrics();
    final isEnabled = biometricService.isBiometricEnabled();
    
    if (mounted) {
      setState(() {
        _isBiometricAvailable =
            (canCheckBiometrics || isDeviceSupported) && availableBiometrics.isNotEmpty;
        _isBiometricEnabled = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSessionService = ref.watch(userSessionServiceProvider);
    final userName = userSessionService.getCurrentUserFullName() ?? 'User';
    final userEmail = userSessionService.getCurrentUserEmail() ?? '';
    final userPhotoUrl = userSessionService.getCurrentUserProfilePicture() ?? '';

    String? _buildProfileImageUrl(String path) {
      if (path.isEmpty || path == 'default.png') return null;
      if (path.startsWith('http')) return path;
      if (path.startsWith('/public')) {
        return '${ApiEndpoints.serverUrl}${path.replaceFirst('/public', '')}';
      }
      if (path.startsWith('/profile_picture')) return '${ApiEndpoints.serverUrl}$path';
      return '${ApiEndpoints.serverUrl}/profile_picture/$path';
    }

    final displayPhotoUrl = _buildProfileImageUrl(userPhotoUrl);
    
    // print('🔍 ProfileScreen build - Photo URL: $userPhotoUrl');

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
              // Header with black background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),

                // Profile Info
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profile Picture
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: (displayPhotoUrl != null)
                          ? CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                displayPhotoUrl,
                              ),
                              child: Container(),
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // User Name and Email
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        userName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        userEmail,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfile()),
                        );
                        if (mounted) {
                          ref.invalidate(userSessionServiceProvider);
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.security_rounded,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    // Fingerprint Toggle
                    if (_isBiometricAvailable)
                      _BiometricToggleItem(
                        icon: Icons.fingerprint,
                        title: 'Use Fingerprint',
                        isEnabled: _isBiometricEnabled,
                        onToggle: (value) async {
                          final biometricService = ref.read(biometricAuthServiceProvider);
                          
                          if (value) {
                            final availableBiometrics =
                                await biometricService.getAvailableBiometrics();
                            if (availableBiometrics.isEmpty) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No fingerprint is set on this device'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            // User wants to enable biometric - authenticate first
                            final authenticated = await biometricService.authenticate(
                              reason: 'Authenticate to enable fingerprint login',
                            );
                            
                            if (authenticated) {
                              await biometricService.setBiometricEnabled(true);
                              final userSessionService = ref.read(userSessionServiceProvider);
                              final userId = userSessionService.getCurrentUserId();
                              final userEmail = userSessionService.getCurrentUserEmail();
                              final userFullName = userSessionService.getCurrentUserFullName();

                              if (userId != null && userEmail != null && userFullName != null) {
                                await biometricService.saveBiometricSessionData(
                                  userId: userId,
                                  email: userEmail,
                                  fullName: userFullName,
                                  phoneNumber: userSessionService.getCurrentUserPhoneNumber(),
                                  profilePicture: userSessionService.getCurrentUserProfilePicture(),
                                );
                              }

                              if (mounted) {
                                setState(() => _isBiometricEnabled = true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fingerprint login enabled'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fingerprint authentication failed'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            // User wants to disable biometric
                            await biometricService.setBiometricEnabled(false);
                            if (mounted) {
                              setState(() => _isBiometricEnabled = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fingerprint login disabled'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    const SizedBox(height: 50),
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
              ),
            ),
          );
          }
        ),
      ),
    );
  }

  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Clear user session
              await ref.read(authViewModelProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BiometricToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isEnabled;
  final Function(bool) onToggle;
  final Color? iconColor;

  const _BiometricToggleItem({
    required this.icon,
    required this.title,
    required this.isEnabled,
    required this.onToggle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.lime).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.cyan,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.cyan,
                ),
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: const Color(0xffD4FF00),
              activeTrackColor: const Color(0xffD4FF00).withAlpha(100),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage {
  const LoginPage();
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (iconColor ?? Colors.lime).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Colors.cyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.cyan,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.white30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}