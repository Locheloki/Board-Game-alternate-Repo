import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Catalog header with selection counter and add action
class CatalogHeader extends AppBar {
  CatalogHeader({
    Key? key,
    required int selectedCount,
    required VoidCallback onAddSelected,
  }) : super(
    key: key,
    title: const Text("Game Catalog"),
    backgroundColor: AppColors.primary,
    elevation: 0,
    actions: [
      Center(
        child: Text(
          "$selectedCount Selected",
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
      IconButton(
        onPressed: onAddSelected,
        icon: const Icon(Icons.add_circle, color: Colors.white),
        tooltip: "Add selected games",
      ),
    ],
  );
}
