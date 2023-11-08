import 'package:flutter/material.dart';

void main() => runApp(const RunRallyApp());

//Color palette
const primaryGreen = Color(0xFF4CAF50); // Main color
const lightGreen = Color(0xFF8BC34A); // Secondary color 1
const darkGreen = Color(0xFF388E3C); // Secondary color 2
const accentBlue = Color(0xFF2196F3); // Accent color 1
const accentAmber = Color(0xFFFFC107); // Accent color 2

class RunRallyApp extends StatelessWidget {
  const RunRallyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: primaryGreen,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RunRally',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // user profile screen
            },
          ),
        ],
        backgroundColor: primaryGreen, // app bar background
      ),
      body: _getScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: primaryGreen,
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const FeedScreen(key: Key('FeedScreen'));
      case 1:
        return const MapScreen(key: Key('MapScreen'));
      default:
        return Container();
    }
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No runs recorded',
        style: TextStyle(fontSize: 20, color: primaryGreen),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Map Screen',
        style: TextStyle(fontSize: 20, color: primaryGreen),
      ),
    );
  }
}