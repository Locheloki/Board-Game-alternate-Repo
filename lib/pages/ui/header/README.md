# Header Module Organization

The `lib/pages/ui/header/` folder contains modular, reusable header components for the application.

## File Structure

```
lib/pages/ui/header/
├── index.dart                    # Main entry point - exports all header components
├── app_header.dart               # AppHeader widget + HomePageHeader builder
├── catalog_header.dart           # CatalogHeader with selection counter
├── collection_sliver_header.dart # CollectionSliverHeader for scrollable views
├── profile_header.dart           # ProfilePageHeader + ProfileAvatar + ProfileActionButtons
└── README.md                     # This file
```

## Components

### AppHeader

Standard header widget for simple page headers.

```dart
import 'ui/header/index.dart';

AppBar header = AppBar(
  title: "Page Title",
  backgroundColor: AppColors.primary,
  actions: [...],
);
```

### HomePageHeader

Builder for home page navigation section headers (Collection, Friends, Profile).

```dart
AppBar? header = HomePageHeader.build(selectedIndex, username);
```

### CatalogHeader

Catalog-specific header with selection counter and add action.

```dart
CatalogHeader(
  selectedCount: 3,
  onAddSelected: () { ... },
)
```

### CollectionSliverHeader

Scrollable/pinned header for collection views using SliverAppBar.

```dart
CollectionSliverHeader(
  title: "My Games",
  expandedHeight: 120,
  onBackPressed: () => Navigator.pop(context),
)
```

### ProfilePageHeader

Minimal header for profile page (transparent, hidden height).

```dart
const ProfilePageHeader()
```

### ProfileAvatar

Reusable avatar display with optional edit capability.

```dart
ProfileAvatar(
  imageUrl: user.profileImage,
  isEditing: isEditMode,
  onTap: () => showAvatarSelector(),
)
```

### ProfileActionButtons

Edit/Save/Cancel buttons for profile editing.

```dart
ProfileActionButtons(
  isEditing: isEditMode,
  onEdit: handleEdit,
  onSave: handleSave,
  onCancel: handleCancel,
)
```

## Usage

Import everything from the header module:

```dart
import 'pages/ui/header/index.dart';
```

Or import specific components:

```dart
import 'pages/ui/header/app_header.dart';
import 'pages/ui/header/profile_header.dart';
```

## Design Principles

- **Modular**: Each header type is self-contained in its own file
- **Consistent**: All headers use `AppColors` and `AppTextStyles` from the theme
- **Reusable**: Components can be composed and used across different pages
- **Mobile-First**: Touch-friendly with no hover effects
- **Accessible**: Proper contrast ratios and clear visual hierarchy

## Future Enhancements

- Add animated header transitions
- Create header variant states (loading, error, success)
- Add more specialized headers for different page types
- Implement header theming variants
