import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../services/user_profile_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeaderWidget extends StatefulWidget {
  final bool isDark;
  final double balance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final UserProfileService profileService;

  const ProfileHeaderWidget({
    super.key,
    required this.isDark,
    required this.balance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.profileService,
  });

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _occupationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileService.name);
    _cityController = TextEditingController(text: widget.profileService.city);
    _occupationController = TextEditingController(
      text: widget.profileService.occupation,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        await widget.profileService.updateProfile(photoPath: picked.path);
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Photo pick error: $e');
    }
  }

  Future<void> _saveProfile() async {
    await widget.profileService.updateProfile(
      name: _nameController.text.trim().isEmpty
          ? 'Pengguna'
          : _nameController.text.trim(),
      city: _cityController.text.trim(),
      occupation: _occupationController.text.trim(),
    );
    if (mounted) setState(() => _isEditing = false);
  }

  String _fmt(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profileService;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withAlpha(102),
                          width: 2,
                        ),
                      ),
                      child: _buildAvatar(profile),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 12,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _isEditing
                    ? _buildEditFields()
                    : _buildProfileInfo(profile),
              ),
              GestureDetector(
                onTap: () {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  'Saldo',
                  'Rp ${_fmt(widget.balance)}',
                  Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'Pemasukan',
                  'Rp ${_fmt(widget.monthlyIncome)}',
                  AppTheme.mint,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'Pengeluaran',
                  'Rp ${_fmt(widget.monthlyExpenses)}',
                  AppTheme.coral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserProfileService profile) {
    if (profile.photoPath != null && !kIsWeb) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            File(profile.photoPath!),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialsAvatar(profile),
          ),
        );
      } catch (_) {}
    }
    return _buildInitialsAvatar(profile);
  }

  Widget _buildInitialsAvatar(UserProfileService profile) {
    return Center(
      child: Text(
        profile.initials,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileInfo(UserProfileService profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.name,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (profile.occupation.isNotEmpty)
          Text(
            profile.occupation,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.white.withAlpha(204),
            ),
          ),
        if (profile.city.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 12,
                color: Colors.white.withAlpha(204),
              ),
              const SizedBox(width: 2),
              Text(
                profile.city,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.white.withAlpha(204),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEditFields() {
    return Column(
      children: [
        _buildEditField(_nameController, 'Nama'),
        const SizedBox(height: 6),
        _buildEditField(_cityController, 'Kota'),
        const SizedBox(height: 6),
        _buildEditField(_occupationController, 'Pekerjaan'),
      ],
    );
  }

  Widget _buildEditField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.nunito(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          fontSize: 12,
          color: Colors.white.withAlpha(153),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        isDense: true,
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: Colors.white.withAlpha(204),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
