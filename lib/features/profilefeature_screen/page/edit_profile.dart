import 'package:fitness_tracker/core/api/api_endpoint.dart';
import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  @override
  void initState() {
    super.initState();
    // Refresh session data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userSessionServiceProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSessionService = ref.watch(userSessionServiceProvider);

    final userName =
        userSessionService.getCurrentUserFullName() ?? 'User';
    final userEmail =
        userSessionService.getCurrentUserEmail() ?? '';
    final phoneNumber =
        userSessionService.getCurrentUserPhoneNumber() ?? '';
    final profileImageUrl =
        userSessionService.getCurrentUserProfilePicture() ?? '';
    
    String? _buildProfileImageUrl(String path) {
      if (path.isEmpty || path == 'default.png') return null;
      if (path.startsWith('http')) return path;
      if (path.startsWith('/public')) {
        return '${ApiEndpoints.serverUrl}${path.replaceFirst('/public', '')}';
      }
      if (path.startsWith('/profile_picture')) return '${ApiEndpoints.serverUrl}$path';
      return '${ApiEndpoints.serverUrl}/profile_picture/$path';
    }

    final profileImageFullUrl = _buildProfileImageUrl(profileImageUrl);
    
    // print('📝 EditProfile build - Photo URL: $profileImageUrl');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Fitness Tracking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              const Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Avatar
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: (profileImageFullUrl != null)
                        ? CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              profileImageFullUrl,
                            ),
                            child: Container(),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Profile fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _profileField(
                      icon: Icons.person,
                      label: 'Full Name',
                      value: userName,
                    ),
                    _profileField(
                      icon: Icons.email,
                      label: 'Email',
                      value: userEmail,
                    ),
                    _profileField(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      value: phoneNumber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}