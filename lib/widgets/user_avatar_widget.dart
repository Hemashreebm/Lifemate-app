import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/profile_service.dart';

/// Reusable, unified User Avatar widget for Lifemate.
///
/// Ensures strict visual rendering rules:
/// 1. If photoURL is provided and non-empty -> NetworkImage CircleAvatar.
/// 2. Else if custom single emoji avatar string -> FittedBox centered emoji text.
/// 3. Else extract uppercase initials (e.g. "HB") from user's full name.
///    Guards against showing generic labels like "Pro", "Profile", or "Default".
/// 4. Fallback to clean Material person icon.
///
/// Guaranteed zero overflow, zero clipping, and zero unwanted text.
class UserAvatarWidget extends StatelessWidget {
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const UserAvatarWidget({
    super.key,
    this.radius = 34,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl.trim()),
        backgroundColor: backgroundColor ?? Colors.white.withAlpha(51),
      );
    }

    final profileService = ProfileService.instance;
    final avatarStr = profileService.avatar.trim();

    // Check if custom emoji string (e.g. "🎯", "🎨", "⭐")
    if (avatarStr.isNotEmpty &&
        avatarStr != 'Profile' &&
        avatarStr != 'Student' &&
        avatarStr != 'Professional' &&
        avatarStr != 'Default' &&
        avatarStr != 'Pro' &&
        avatarStr.length <= 2) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withAlpha(51),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            avatarStr,
            style: TextStyle(fontSize: radius * 0.95),
          ),
        ),
      );
    }

    // Extract initials from name (e.g., "Hemashree B M" -> "HB")
    final name = profileService.name.trim();
    String initials = '';
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    // Never display generic labels "PRO", "PR", "DE" as initials
    if (initials.isNotEmpty &&
        initials != 'PR' &&
        initials != 'PRO' &&
        initials != 'DE') {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withAlpha(51),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: radius * 0.75,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      );
    }

    // Fallback: Material Person Icon
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withAlpha(51),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: radius * 1.1,
        color: iconColor ?? Colors.white,
      ),
    );
  }
}
