import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

/// Sliver header for collection page with pinned title
class CollectionSliverHeader extends StatelessWidget {
  final String title;
  final double expandedHeight;
  final VoidCallback? onBackPressed;

  const CollectionSliverHeader({
    Key? key,
    required this.title,
    this.expandedHeight = 120,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.primary,
      expandedHeight: expandedHeight,
      pinned: true,
      elevation: 0,
      leading: onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed,
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        centerTitle: true,
      ),
    );
  }
}
