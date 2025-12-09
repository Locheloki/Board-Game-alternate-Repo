import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_theme.dart';

/// Simple page header for main navigation sections (Collection, Friends, Profile)
class AppHeader extends StatelessWidget {
  final String title;
  final Color? backgroundColor;
  final double elevation;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const AppHeader({
    Key? key,
    required this.title,
    this.backgroundColor,
    this.elevation = 0,
    this.actions,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      backgroundColor: backgroundColor ?? AppColors.primary,
      elevation: elevation,
      actions: actions,
      bottom: bottom,
    );
  }
}

/// Header builder for home page navigation sections
class HomePageHeader {
  static AppBar? build(int selectedIndex, String username) {
    // Return null for all pages - headers removed per UX request
    return null;
  }
}
