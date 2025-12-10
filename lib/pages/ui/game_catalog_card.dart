import 'package:flutter/material.dart';
import '../../models/board_game.dart';
import '../../config/app_theme.dart';

/// Reusable card widget for displaying games in the catalog
/// Features wood texture and sleek selection animations
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        // Wood Background
        gradient: LinearGradient(
          colors: isSelected
              ? [
                  const Color(0xFF4E342E),
                  const Color(0xFF3E2723),
                ] // Darker when selected
              : [
                  const Color(0xFF6D4C41),
                  const Color(0xFF5D4037),
                ], // Standard Wood
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        // Sleek selection border (Gold glow when selected)
        border: Border.all(
          color: isSelected ? const Color(0xFFFFD54F) : const Color(0xFF8D6E63),
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.5 : 0.2),
            blurRadius: isSelected ? 12 : 6,
            offset: isSelected ? const Offset(0, 6) : const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game Image Placeholder
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ), // Slightly less to fit border
                child: Image.network(
                  game.thumbnailUrl.isEmpty
                      ? 'https://via.placeholder.com/300'
                      : game.thumbnailUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(Icons.casino, color: Colors.white54),
                    ),
                  ),
                ),
              ),
              // Selection Indicator (Animated Scale)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF388E3C), // Green check
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Distribute space
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFFECB3), // Cream color text
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.category,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoBadge(
                        icon: Icons.people,
                        text: '${game.minPlayers}-${game.maxPlayers}',
                      ),
                      _InfoBadge(
                        icon: Icons.access_time,
                        text: '${game.playingTime}m',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for small info pills at bottom of card
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBadge({Key? key, required this.icon, required this.text})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFFFFD54F)), // Gold icon
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFFFD54F), // Gold text
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
