import 'package:flutter/material.dart';
import '../../core/utils/animation_utils.dart';
import '../home/home_screen.dart';
import '../recent/recent_screen.dart';
import '../shelf/shelf_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../files/my_files_screen.dart';
import '../more/more_screen.dart';

/// MainScreen - Container with bottom navigation
/// 
/// 6 tabs:
/// - Home: Dashboard with sections
/// - Recent: Recently read books
/// - My Shelf: All books with filters
/// - Bookmarks: Grouped bookmarks
/// - My Files: Browse PDF files
/// - More: Profile, settings, about
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Global keys untuk mengakses state dari child screens
  final GlobalKey<State> _homeKey = GlobalKey<State>();
  final GlobalKey<State> _recentKey = GlobalKey<State>();
  
  // Tab screens with keys
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(key: _homeKey),
      RecentScreen(key: _recentKey),
      const ShelfScreen(),
      const BookmarksScreen(),
      const MyFilesScreen(),
      const MoreScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Trigger reload pada screen yang di-tap
    _reloadCurrentScreen();
  }
  
  void _reloadCurrentScreen() {
    // Call reload method pada screen yang aktif
    if (_currentIndex == 0 && _homeKey.currentState != null) {
      // HomeScreen reload
      (_homeKey.currentState as dynamic)._loadBooks();
    } else if (_currentIndex == 1 && _recentKey.currentState != null) {
      // RecentScreen reload
      (_recentKey.currentState as dynamic)._loadRecentBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppAnimations.fast, // 150ms fade-through
        switchInCurve: AppAnimations.fadeInCurve,
        switchOutCurve: AppAnimations.fadeOutCurve,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Recent',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'My Shelf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'My Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_vert_outlined),
            activeIcon: Icon(Icons.more_vert),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
