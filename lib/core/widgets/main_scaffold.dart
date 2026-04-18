import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _getIndex(String location) {
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/feed')) return 2;
    if (location.startsWith('/events')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getIndex(location),
        selectedItemColor: Colors.black38,
        unselectedItemColor: Colors.black26,
        showUnselectedLabels: true,

        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/projects');
              break;
            case 2:
              context.go('/feed');
              break;
            case 3:
              context.go('/events');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
