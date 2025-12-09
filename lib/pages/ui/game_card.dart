import 'package:flutter/material.dart';
import './manage_favorites_dialog.dart';

/// Displays a favorite game card in a horizontal scrollable list
class GameCard extends StatelessWidget {
  final FavoriteGame game;
  const GameCard({Key? key, required this.game}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: [
            Image.network(
              game.image,
              width: 128,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                width: 128,
                height: 160,
                child: const Center(child: Icon(Icons.broken_image)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.2),
                      Colors.transparent
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  game.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
