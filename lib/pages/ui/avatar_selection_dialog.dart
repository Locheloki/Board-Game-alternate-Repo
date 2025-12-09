import 'package:flutter/material.dart';
import '../../utils/avatar_urls.dart';

/// Dialog for selecting a user avatar from a grid of available options
class AvatarSelectionDialog extends StatelessWidget {
  const AvatarSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Your Avatar"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: AVATAR_URLS.length,
          itemBuilder: (context, index) {
            final url = AVATAR_URLS[index];
            return GestureDetector(
              onTap: () => Navigator.pop(context, url), // Return the selected URL
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(url),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null), // Return null if cancelled
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
