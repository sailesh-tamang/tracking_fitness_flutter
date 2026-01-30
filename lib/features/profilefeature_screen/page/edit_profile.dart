import 'dart:io';
import 'package:fitness_tracker/core/api/api_endpoint.dart';
import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:fitness_tracker/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:fitness_tracker/features/profilefeature_screen/widgets/media_picker_buttom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {

  final List<File> _selectedMedia = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Refresh session data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userSessionServiceProvider);
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This feature requires permission to access your camera or gallery. Please enable it in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _selectedMedia.clear();
        _selectedMedia.add(File(photo.path));
      });
      final result = await ref
          .read(authViewModelProvider.notifier)
          .uploadPhoto(File(photo.path));
      
      // If upload successful, rebuild widget to fetch updated profile image from session
      if (result != null && mounted) {
        // print('🎥 Camera upload successful: $result');
        // Wait a moment to ensure SharedPreferences is updated
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _selectedMedia.clear();
        });
        // Force rebuild the parent to fetch updated profileImageUrl
        ref.invalidate(userSessionServiceProvider);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedMedia.clear();
          _selectedMedia.add(File(image.path));
        });
        final result = await ref
            .read(authViewModelProvider.notifier)
            .uploadPhoto(File(image.path));
        
        // If upload successful, rebuild widget to fetch updated profile image from session
        if (result != null && mounted) {
          // print('🖼️ Gallery upload successful: $result');
          // Wait a moment to ensure SharedPreferences is updated
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {
            _selectedMedia.clear();
          });
          // Force rebuild the parent to fetch updated profileImageUrl
          ref.invalidate(userSessionServiceProvider);
        }
      }
    } catch (e) {
      debugPrint('Gallery Error $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to access gallery. Please try using the camera instead.')),
        );
      }
    }
  }

  void _showMediaPicker() {
    MediaPickerBottomSheet.show(
      context,
      onCameraTap: _pickFromCamera,
      onGalleryTap: _pickFromGallery,
    );
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
      appBar: AppBar(
        title: const Text('Fitness Tracking'),
        backgroundColor: Colors.teal,
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
                ),
              ),

              const SizedBox(height: 24),

              // Avatar + camera icon
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
                    child: _selectedMedia.isNotEmpty
                        ? CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: FileImage(_selectedMedia.first),
                          )
                        : (profileImageFullUrl != null)
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
                                ),)
                              ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      onTap: _showMediaPicker,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
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
                      onEdit: () {
                       
                      },
                    ),
                    _profileField(
                      icon: Icons.email,
                      label: 'Email',
                      value: userEmail,
                      onEdit: () {
                        
                      },
                    ),
                    _profileField(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      value: phoneNumber,
                      onEdit: () {
                        
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
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
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.teal),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}