import 'dart:io';
import 'package:fitness_tracker/core/api/api_endpoint.dart';
import 'package:fitness_tracker/core/services/storage/user_session_service.dart';
import 'package:fitness_tracker/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
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
  String? _publishedProfileImageUrl;
  String? _cachedProfileImageUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _initialName = '';
  String _initialEmail = '';
  String _initialPhone = '';
  bool _hasPendingChanges = false;
  double? _calculatedBMI;
  String _bmiCategory = '';

  @override
  void initState() {
    super.initState();
    // Refresh session data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userSessionServiceProvider);
    });

    final userSessionService = ref.read(userSessionServiceProvider);
    _syncControllersFromSession(userSessionService);

    _nameController.addListener(_updateDirtyFlag);
    _emailController.addListener(_updateDirtyFlag);
    _phoneController.addListener(_updateDirtyFlag);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _syncControllersFromSession(UserSessionService userSessionService) {
    _initialName = userSessionService.getCurrentUserFullName() ?? '';
    _initialEmail = userSessionService.getCurrentUserEmail() ?? '';
    _initialPhone = userSessionService.getCurrentUserPhoneNumber() ?? '';

    _nameController.text = _initialName;
    _emailController.text = _initialEmail;
    _phoneController.text = _initialPhone;

    _hasPendingChanges = false;
  }

  void _updateDirtyFlag() {
    final nameChanged = _nameController.text.trim() != _initialName.trim();
    final emailChanged = _emailController.text.trim() != _initialEmail.trim();
    final phoneChanged = _phoneController.text.trim() != _initialPhone.trim();
    final hasChanges = nameChanged || emailChanged || phoneChanged;
    if (hasChanges != _hasPendingChanges && mounted) {
      setState(() {
        _hasPendingChanges = hasChanges;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This feature requires permission to access your camera or gallery. Please enable it in your device settings.',
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

      // If upload successful, update UI immediately
      if (result != null && mounted) {
        setState(() {
          _selectedMedia.clear();
          _publishedProfileImageUrl = result;
          _cachedProfileImageUrl = null;
        });

        ref.invalidate(userSessionServiceProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile picture')),
        );
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

        // If upload successful, update UI immediately
        if (result != null && mounted) {
          setState(() {
            _selectedMedia.clear();
            _publishedProfileImageUrl = result;
            _cachedProfileImageUrl = null;
          });

          ref.invalidate(userSessionServiceProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile picture')),
          );
        }
      }
    } catch (e) {
      debugPrint('Gallery Error $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to access gallery. Please try using the camera instead.')),
        );
      }
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.grey[800],
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.white),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }



  void _showPasswordDialog() {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter your password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveProfileUpdates();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text('Enter your password to confirm:'),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password')),
        );
      }
      return;
    }

    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId() ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete account right now')),
        );
      }
      return;
    }

    final success = await ref.read(authViewModelProvider.notifier).deleteCustomer(userId, password);

    if (!mounted) return;

    if (success) {
      await userSessionService.clearSession();
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
      // Navigate to login screen after deletion
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      });
    } else {
      final errorMessage = ref.read(authViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Failed to delete account'),
        ),
      );
    }
  }

  Future<void> _saveProfileUpdates() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final userId = userSessionService.getCurrentUserId() ?? '';
    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update profile right now')),
        );
      }
      return;
    }

    final updatedName = _nameController.text.trim();
    final updatedEmail = _emailController.text.trim();
    final updatedPhone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password')),
        );
      }
      return;
    }

    final nameChanged = updatedName != _initialName.trim();
    final emailChanged = updatedEmail != _initialEmail.trim();
    final phoneChanged = updatedPhone != _initialPhone.trim();

    if (updatedName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
      }
      return;
    }

    if (updatedEmail.isEmpty || !updatedEmail.contains('@')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email')),
        );
      }
      return;
    }

    if (phoneChanged) {
      final phoneRegex = RegExp(r'^\d{10}$');
      if (updatedPhone.isEmpty || !phoneRegex.hasMatch(updatedPhone)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number must be exactly 10 digits'),
            ),
          );
        }
        return;
      }
    }

    final success = await ref.read(authViewModelProvider.notifier).updateUser(
          userId: userId,
          fullName: nameChanged ? updatedName : null,
          email: emailChanged ? updatedEmail : null,
          phoneNumber: phoneChanged ? updatedPhone : null,
          password: password,
        );

    if (success && mounted) {
      ref.invalidate(userSessionServiceProvider);
      setState(() {
        _initialName = updatedName;
        _initialEmail = updatedEmail;
        _initialPhone = updatedPhone;
        _hasPendingChanges = false;
        _passwordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } else if (mounted) {
      final errorMessage = ref.read(authViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Failed to update profile'),
        ),
      );
    }
  }

  void _calculateBMI() {
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter height (feet) and weight')),
      );
      return;
    }

    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid height (feet) and weight')),
      );
      return;
    }

    final heightInMeters = height * 0.3048;
    final bmi = weight / (heightInMeters * heightInMeters);

    String category;
    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi < 25) {
      category = 'Normal weight';
    } else if (bmi < 30) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    setState(() {
      _calculatedBMI = bmi;
      _bmiCategory = category;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('BMI calculated successfully!')),
    );
  }

  Color _getBMIColor() {
    if (_calculatedBMI == null) return Colors.cyan;

    if (_calculatedBMI! < 18.5) {
      return Colors.blue;
    } else if (_calculatedBMI! < 25) {
      return Colors.green;
    } else if (_calculatedBMI! < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSessionService = ref.watch(userSessionServiceProvider);

    final userName = _nameController.text.isNotEmpty
      ? _nameController.text
      : (userSessionService.getCurrentUserFullName() ?? 'User');
    final sessionProfileImageUrl =
        userSessionService.getCurrentUserProfilePicture() ?? '';
    
    // Use published URL if available, otherwise use session URL
    final profileImageUrl = _publishedProfileImageUrl ?? sessionProfileImageUrl;
    
    String? buildProfileImageUrl(String path) {
      if (path.isEmpty || path == 'default.png') return null;
      if (path.startsWith('http')) return path;
      if (path.startsWith('/public')) {
        return '${ApiEndpoints.serverUrl}${path.replaceFirst('/public', '')}';
      }
      if (path.startsWith('/profile_picture')) return '${ApiEndpoints.serverUrl}$path';
      return '${ApiEndpoints.serverUrl}/profile_picture/$path';
    }

    final profileImageFullUrl = buildProfileImageUrl(profileImageUrl);
    
    // Cache the URL to prevent unnecessary widget rebuilds
    if (profileImageFullUrl != _cachedProfileImageUrl) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _cachedProfileImageUrl = profileImageFullUrl;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Avatar + camera icon
                    Stack(
                      children: [
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
                        child: _selectedMedia.isNotEmpty
                            ? CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                backgroundImage: FileImage(_selectedMedia.first),
                              )
                            : (_cachedProfileImageUrl != null)
                                ? ClipOval(
                                    child: Image.network(
                                      _cachedProfileImageUrl!,
                                      key: ValueKey(_cachedProfileImageUrl),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      cacheWidth: 240,
                                      cacheHeight: 240,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: 120,
                                          height: 120,
                                          color: Colors.white,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              color: Colors.cyan,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        debugPrint('Error loading profile image: $error');
                                        return CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Colors.white,
                                          child: Text(
                                            userName.isNotEmpty
                                                ? userName[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
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
                              color: Colors.cyan,
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Profile fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _editableProfileField(
                      icon: Icons.person,
                      label: 'Full Name',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                    ),
                    _editableProfileField(
                      icon: Icons.email,
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _editableProfileField(
                      icon: Icons.phone,
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),
                    // BMI Section Header
                    const Row(
                      children: [
                        Icon(Icons.monitor_weight, color: Colors.cyan, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Health Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _editableProfileField(
                      icon: Icons.height,
                      label: 'Height (ft)',
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                    ),
                    _editableProfileField(
                      icon: Icons.monitor_weight,
                      label: 'Weight (kg)',
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                    ),
                    _editableProfileField(
                      icon: Icons.cake,
                      label: 'Age (years)',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // Calculate BMI Button
                    ElevatedButton.icon(
                      onPressed: _calculateBMI,
                      icon: const Icon(Icons.calculate, color: Colors.white),
                      label: const Text(
                        'Calculate BMI',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // BMI Result Display
                    if (_calculatedBMI != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getBMIColor().withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getBMIColor(), width: 2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite, color: _getBMIColor(), size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  'Your BMI',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _calculatedBMI!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _getBMIColor(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _bmiCategory,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getBMIColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_hasPendingChanges)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: _showPasswordDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: _showDeleteConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withAlpha(30),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editableProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.cyan.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.cyan, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
