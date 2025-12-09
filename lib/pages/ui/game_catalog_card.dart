import 'package:flutter/material.dart';
import '../../models/board_game.dart';
import '../../config/app_theme.dart';

/// Reusable card widget for displaying games in the catalog
class GameCatalogCard extends StatelessWidget {
  final BoardGame game;
  final bool isSelected;
  
  const GameCatalogCard({
    required this.game,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgTertiary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isSelected 
            ? Border.all(color: AppColors.primary, width: 3)
            : null,
        boxShadow: AppShadows.elevation2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Image Placeholder
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  game.thumbnailUrl.isEmpty ? 'https://via.placeholder.com/300' : game.thumbnailUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey,
                    child: const Center(child: Icon(Icons.category, color: Colors.white70)),
                  ),
                ),
              ),
              // Selection Indicator
              if (isSelected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  game.category,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${game.minPlayers}-${game.maxPlayers} players',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      '${game.playingTime} min',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
