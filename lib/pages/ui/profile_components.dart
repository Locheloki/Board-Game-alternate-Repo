import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/animations.dart';
import '../../utils/avatar_urls.dart';

/// Reusable avatar display component with optional edit capability
class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isEditing;
  final VoidCallback? onTap;

  const ProfileAvatar({
    Key? key,
    required this.imageUrl,
    this.isEditing = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayUrl = imageUrl.isNotEmpty ? imageUrl : AVATAR_URLS.first;

    return GestureDetector(
      onTap: isEditing ? onTap : null,
      child: ScaleInWidget(
        duration: AppAnimation.fast,
        initialScale: 0.98,
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppShadows.elevation2,
            border: Border.all(color: AppColors.darkBg, width: 2),
          ),
          child: CircleAvatar(
            radius: 64,
            backgroundImage: NetworkImage(displayUrl),
            backgroundColor: AppColors.darkBgSecondary,
          ),
        ),
      ),
    );
  }
}

/// Profile action buttons (Edit, Save, Cancel)
class ProfileActionButtons extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ProfileActionButtons({
    Key? key,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!isEditing)
          ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 16.0),
            label: const Text('Edit'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: AppColors.primary,
              minimumSize: const Size(64, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              textStyle: AppTextStyles.bodyMedium,
              elevation: 0,
            ),
          )
        else ...[
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save, size: 16.0),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: AppColors.success,
              minimumSize: const Size(64, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              textStyle: AppTextStyles.bodyMedium,
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 16.0),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              backgroundColor: Colors.transparent,
              minimumSize: const Size(64, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                side: const BorderSide(color: AppColors.darkBgSecondary),
              ),
              textStyle: AppTextStyles.bodyMedium,
              elevation: 0,
            ),
          ),
        ],
      ],
    );
  }
}
