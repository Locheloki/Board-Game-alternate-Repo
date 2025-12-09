import 'package:flutter/material.dart';
import '../../models/board_game.dart';
import '../../services/game_service.dart';
import '../../config/app_theme.dart';

/// Model for favorite game with display properties
class FavoriteGame {
  final String id;
  final String name;
  final String image;

  FavoriteGame({required this.id, required this.name, required this.image});

  /// Convert FavoriteGame to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  /// Create FavoriteGame from a map (deserialization)
  factory FavoriteGame.fromMap(Map<String, dynamic> map) {
    return FavoriteGame(
      id: map['id'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
    );
  }
}

/// Dialog for managing top 5 favorite games from user's collection
class ManageFavoritesDialog extends StatefulWidget {
  final List<FavoriteGame> currentFavorites;
  const ManageFavoritesDialog({Key? key, required this.currentFavorites}) : super(key: key);

  @override
  State<ManageFavoritesDialog> createState() => _ManageFavoritesDialogState();
}

class _ManageFavoritesDialogState extends State<ManageFavoritesDialog> {
  Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.currentFavorites.map((g) => g.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoardGame>>(
      stream: GameService.getUserCollectionGames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));
        }
        final myGames = snapshot.data ?? [];

        return AlertDialog(
          title: const Text("Select Top 5 Games"),
          content: SizedBox(
            width: double.maxFinite,
            child: myGames.isEmpty
                ? const Text("You have no games in your collection to select.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: myGames.length,
                    itemBuilder: (context, index) {
                      final game = myGames[index];
                      final isSelected = _selectedIds.contains(game.id);
                      return CheckboxListTile(
                        title: Text(game.name),
                        subtitle: Text(game.category),
                        value: isSelected,
                        activeColor: AppColors.primary,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (_selectedIds.length < 5) _selectedIds.add(game.id);
                              else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 5 games allowed"), duration: Duration(milliseconds: 500)));
                            } else {
                              _selectedIds.remove(game.id);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final List<FavoriteGame> selectedFavorites = myGames
                    .where((game) => _selectedIds.contains(game.id))
                    .map((game) => FavoriteGame(id: game.id, name: game.name, image: game.thumbnailUrl))
                    .toList();
                Navigator.pop(context, selectedFavorites);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Save Selection", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
