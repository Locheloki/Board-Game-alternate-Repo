import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

/// Catalog header with selection counter and add action
/// Designed as a floating wooden plank
class CatalogHeader extends StatelessWidget implements PreferredSizeWidget {
  final int selectedCount;
  final VoidCallback onAddSelected;

  const CatalogHeader({
    Key? key,
    required this.selectedCount,
    required this.onAddSelected,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(80.0); // Increased height for padding

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        margin: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          8,
        ), // 15px padding on sides
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          // Wood Grain Simulation
          gradient: const LinearGradient(
            colors: [
              Color(0xFF5D4037), // Dark Wood
              Color(0xFF4E342E), // Darker Wood
              Color(0xFF3E2723), // Darkest Wood
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.5, 0.9],
          ),
          borderRadius: BorderRadius.circular(16), // Rounded corners
          border: Border.all(
            color: const Color(0xFF8D6E63), // Lighter wood border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Game Catalog",
              style: TextStyle(
                color: Color(0xFFFFECB3), // Amber/Cream text for contrast
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    "$selectedCount Selected",
                    key: ValueKey<int>(selectedCount),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAddSelected,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_circle,
                        color: Color(0xFFFFECB3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
