// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/animations.dart';
import '../utils/avatar_urls.dart';
import '../services/profile_service.dart'; 
import '../services/game_service.dart'; 
import '../models/board_game.dart';
import 'ui/manage_favorites_dialog.dart';
import 'ui/game_card.dart';
import 'ui/avatar_selection_dialog.dart';

class UserProfile {
  String displayName;
  String profileImage; // Stores the selected avatar URL
  String aboutMe;
  List<String> preferredGenres;
  String topGenre;
  int ownedGamesCount;
  List<FavoriteGame> favoriteGames;

  UserProfile({
    required this.displayName,
    required this.profileImage,
    required this.aboutMe,
    required this.preferredGenres,
    required this.topGenre,
    required this.ownedGamesCount,
    required this.favoriteGames,
  });

  UserProfile copyWith({
    String? displayName,
    String? profileImage,
    String? aboutMe,
    List<String>? preferredGenres,
    String? topGenre,
    int? ownedGamesCount,
    List<FavoriteGame>? favoriteGames,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      aboutMe: aboutMe ?? this.aboutMe,
      preferredGenres: preferredGenres ?? this.preferredGenres,
      topGenre: topGenre ?? this.topGenre,
      ownedGamesCount: ownedGamesCount ?? this.ownedGamesCount,
      favoriteGames: favoriteGames ?? this.favoriteGames,
    );
  }
}

/// --- Profile Page Widget ---

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfilePage({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  late UserProfile _profile;
  late UserProfile _editedProfile;
  
  // Controllers
  late TextEditingController _displayNameController;
  late TextEditingController _aboutMeController;
  late TextEditingController _topGenreController;
  late TextEditingController _ownedGamesCountController;
  late TextEditingController _newGenreController;

  static const String _defaultProfileImage = ''; 

  @override
  void initState() {
    super.initState();
    _profile = UserProfile(
      displayName: 'Loading...', 
      profileImage: _defaultProfileImage,
      aboutMe: "Tell us about your board game passion!",
      preferredGenres: [], 
      topGenre: 'Strategy', 
      ownedGamesCount: 0, 
      favoriteGames: [],
    );
    _editedProfile = _profile.copyWith();

    _displayNameController = TextEditingController(text: _profile.displayName);
    _aboutMeController = TextEditingController(text: _profile.aboutMe);
    _topGenreController = TextEditingController(text: _profile.topGenre);
    _ownedGamesCountController = TextEditingController(text: _profile.ownedGamesCount.toString());
    _newGenreController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _aboutMeController.dispose();
    _topGenreController.dispose();
    _ownedGamesCountController.dispose();
    _newGenreController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

  void _handleEdit() {
    setState(() {
      _editedProfile = _profile.copyWith(
        preferredGenres: List.from(_profile.preferredGenres), 
        favoriteGames: List.from(_profile.favoriteGames),
        profileImage: _profile.profileImage, // Ensure the current saved image URL is used
      );
      _displayNameController.text = _editedProfile.displayName;
      _aboutMeController.text = _editedProfile.aboutMe;
      _topGenreController.text = _editedProfile.topGenre;
      _ownedGamesCountController.text = _editedProfile.ownedGamesCount.toString();
      _isEditing = true;
    });
  }

  void _handleSave() async { 
    final newProfile = _editedProfile.copyWith(
      displayName: _displayNameController.text,
      aboutMe: _aboutMeController.text,
      topGenre: _topGenreController.text,
      ownedGamesCount: _profile.ownedGamesCount,
      preferredGenres: List.from(_editedProfile.preferredGenres), 
      favoriteGames: List.from(_editedProfile.favoriteGames),
      // Use the potentially new URL from _editedProfile state
      profileImage: _editedProfile.profileImage, 
    );
    
    final favoriteGamesMapList = newProfile.favoriteGames.map((g) => g.toMap()).toList();

    await ProfileService.saveProfileEdits( 
      displayName: newProfile.displayName,
      aboutMe: newProfile.aboutMe,
      preferredGenres: newProfile.preferredGenres,
      topGenre: newProfile.topGenre,
      profileImage: newProfile.profileImage, // Passing the selected URL for saving
      favoriteGames: favoriteGamesMapList, 
    );
    
    setState(() {
      _profile = newProfile;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text("Profile updated!"), backgroundColor: AppColors.success),
    );
  }

  void _handleCancel() {
    setState(() {
      _editedProfile = _profile.copyWith();
      _isEditing = false;
    });
  }

  void _addGenre(String genre) {
    String trimmedGenre = genre.trim();
    if (trimmedGenre.isNotEmpty && !_editedProfile.preferredGenres.contains(trimmedGenre)) {
      setState(() {
        _editedProfile = _editedProfile.copyWith(
          preferredGenres: [..._editedProfile.preferredGenres, trimmedGenre],
        );
      });
      _newGenreController.clear();
    }
  }

  void _removeGenre(String genreToRemove) {
    setState(() {
      _editedProfile = _editedProfile.copyWith(
        preferredGenres: _editedProfile.preferredGenres.where((g) => g != genreToRemove).toList(),
      );
    });
  }

  void _updateProfileState(Map<String, dynamic> data) async {
    if (data.isNotEmpty) {
      final List<String> genres = (data['preferredGenres'] as List?)?.map((e) => e.toString()).toList() ?? [];
      
      // 💡 QUOTA FIX: Get ownedGamesCount directly from the streamed document data
      final int realGameCount = (data['ownedGamesCount'] as num?)?.toInt() ?? 0;
      
      List<FavoriteGame> fetchedFavorites = [];
      if (data['favoriteGames'] != null) {
        fetchedFavorites = (data['favoriteGames'] as List).map((item) {
          return FavoriteGame.fromMap(item as Map<String, dynamic>);
        }).toList();
      }
      
      // Determine the image URL to load/set as the default:
      String savedImageUrl = data['profileImage'] as String? ?? AVATAR_URLS.first; 
      
      if (!_isEditing) {
        setState(() {
          _profile = _profile.copyWith(
            displayName: data['displayName'] as String? ?? _profile.displayName,
            profileImage: savedImageUrl, 
            aboutMe: data['aboutMe'] as String? ?? _profile.aboutMe,
            preferredGenres: genres,
            topGenre: data['topGenre'] as String? ?? _profile.topGenre,
            ownedGamesCount: realGameCount, // Set cached count
            favoriteGames: fetchedFavorites,
          );
          _displayNameController.text = _profile.displayName;
          _aboutMeController.text = _profile.aboutMe;
          _topGenreController.text = _profile.topGenre;
          _ownedGamesCountController.text = realGameCount.toString();
        });
      }
    }
  }

  void _showManageFavoritesDialog() async {
    final List<FavoriteGame>? result = await showDialog<List<FavoriteGame>>(
      context: context,
      builder: (context) => ManageFavoritesDialog(
        currentFavorites: _editedProfile.favoriteGames,
      ),
    );

    if (result != null) {
      setState(() {
        _editedProfile = _editedProfile.copyWith(favoriteGames: result);
      });
    }
  }

  void _showAvatarSelectionDialog() async {
    if (!_isEditing) return; // Only allow avatar changes in edit mode

    final String? resultUrl = await showDialog<String>(
      context: context,
      builder: (context) => const AvatarSelectionDialog(),
    );

    if (resultUrl != null) {
      setState(() {
        // Update the edited profile state with the new URL
        _editedProfile = _editedProfile.copyWith(profileImage: resultUrl);
      });
    }
  }
  
  // --- UI Builder Methods ---

  // 1. Build Header Card - uses modular header components
  Widget _buildHeaderCard(UserProfile currentProfile) {
    return FadeInWidget(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.elevation3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Action buttons row (Edit/Save/Cancel)
            ProfileActionButtons(
              isEditing: _isEditing,
              onEdit: _handleEdit,
              onSave: _handleSave,
              onCancel: _handleCancel,
            ),

            const SizedBox(height: 8),

            // Centered avatar and name
            Center(
              child: Column(
                children: [
                  ProfileAvatar(
                    imageUrl: currentProfile.profileImage,
                    isEditing: _isEditing,
                    onTap: _showAvatarSelectionDialog,
                  ),

                  const SizedBox(height: 12),
                  _isEditing
                      ? SizedBox(
                          width: 260,
                          child: TextField(
                            controller: _displayNameController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), border: OutlineInputBorder()),
                            style: AppTextStyles.heading3,
                          ),
                        )
                      : Text(currentProfile.displayName, style: AppTextStyles.heading3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Build About Me Card
  Widget _buildAboutMeCard(UserProfile currentProfile) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About Me', AppColors.primary),
          const SizedBox(height: 12),
          _isEditing
              ? TextField(
                  controller: _aboutMeController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tell us about yourself...',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                )
              : Text(currentProfile.aboutMe, style: AppTextStyles.bodyLarge.copyWith(height: 1.5)),
        ],
      ),
    );
  }

  // 3. Build Genres Card
  Widget _buildGenresCard(UserProfile currentProfile) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Preferred Genres', AppColors.primary),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _isEditing
                ? SizedBox(width: 200, child: TextField(controller: _topGenreController, decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), hintText: 'Top genre', border: OutlineInputBorder())))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: AppColors.primaryGradient),
                    child: Text('⭐ ${currentProfile.topGenre}', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ...currentProfile.preferredGenres.map((genre) => Container(
                padding: EdgeInsets.only(left: 12, right: _isEditing ? 4 : 12, top: 6, bottom: 6),
                decoration: BoxDecoration(color: AppColors.darkBgSecondary, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primaryDark)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(genre, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                    if (_isEditing)
                      InkWell(onTap: () => _removeGenre(genre), borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.only(left: 8.0, right: 4.0), child: Icon(Icons.close, size: 16, color: AppColors.error))),
                  ],
                ),
              )),
              if (_isEditing)
                SizedBox(width: 120, height: 32, child: TextField(controller: _newGenreController, decoration: InputDecoration(hintText: 'Add genre...', isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), border: const OutlineInputBorder(), hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)), onSubmitted: _addGenre)),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Build Collection Card
  Widget _buildCollectionCard(UserProfile currentProfile) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('My Collection', AppColors.primary),
              if (_isEditing)
                _buildActionButton(
                  onPressed: _showManageFavoritesDialog,
                  icon: Icons.star,
                  text: 'Manage Top 5', 
                  backgroundColor: AppColors.warning, 
                  textColor: Colors.black
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.darkBgSecondary),
                  child: Text('${currentProfile.ownedGamesCount} Games', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: currentProfile.favoriteGames.isEmpty
                ? Center(child: Text("No favorites selected", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var game in currentProfile.favoriteGames)
                          Padding(padding: const EdgeInsets.only(right: 12), child: GameCard(game: game)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // 5. Build Logout Button
  Widget _buildLogoutButton() {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: AppShadows.elevation1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              elevation: 0,
            ),
            child: Text('Logout', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary)),
          ),
        ),
      ),
    );
  }

  // Note: _buildButton method removed - now uses ProfileActionButtons from header module
  
  // Helper for section action buttons (e.g., Manage Top 5)
  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color backgroundColor,
    Color textColor = AppColors.textPrimary,
    Color? borderColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16.0),
      label: Text(text, style: AppTextStyles.bodyMedium),
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backgroundColor,
        minimumSize: const Size(64, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
        ),
        textStyle: AppTextStyles.bodyMedium,
        elevation: 0,
      ),
    );
  }
  
  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.elevation1,
      ),
      padding: const EdgeInsets.all(20.0),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)), margin: const EdgeInsets.only(right: 12.0)),
        Text(title, style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
  
  // --- Main Build Method (Unchanged) ---
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>( 
      stream: ProfileService.getUserProfileStream(),
      builder: (context, snapshot) {
        
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // Use addPostFrameCallback to safely call setState after build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateProfileState(snapshot.data!);
          });
        }

        final currentProfile = _isEditing ? _editedProfile : _profile;

        if (snapshot.connectionState == ConnectionState.waiting && currentProfile.displayName == 'Loading...') {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.darkBg,
          appBar: null,
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox.shrink(),
                      const SizedBox(height: 8),
                      _buildAboutMeCard(currentProfile),
                      const SizedBox(height: 16),
                      _buildGenresCard(currentProfile),
                      const SizedBox(height: 16),
                      _buildCollectionCard(currentProfile),
                      const SizedBox(height: 16),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Manage Favorites Dialog (Unchanged) ---
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
              child: Text("Save Selection", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
            ),
          ],
        );
      },
    );
  }
}

// --- GameCard (Unchanged) ---
class GameCard extends StatelessWidget {
  final FavoriteGame game;
  const GameCard({Key? key, required this.game}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 128, child: ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Stack(children: [Image.network(game.image, width: 128, height: 160, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], width: 128, height: 160, child: const Center(child: Icon(Icons.broken_image)))), Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.2), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter)), alignment: Alignment.bottomLeft, padding: const EdgeInsets.all(8.0), child: Text(game.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))))])));
  }
}

// --- Avatar Selection Dialog (New) ---
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
                backgroundColor: AppColors.darkBgSecondary,
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