import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'widgets/feed_screen.dart';
import 'widgets/map_screen.dart';
import 'bloc/feed_bloc.dart';
import 'bloc/map_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RunRallyApp());
}

class RunRallyApp extends StatelessWidget {
  const RunRallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: ColorPalette.primaryGreen,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FeedBloc()),
        BlocProvider(create: (context) => MapBloc()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'RunRally',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                // TODO: user profile screen
              },
            ),
          ],
          backgroundColor: ColorPalette.primaryGreen,
        ),
        body: _getScreen(_currentIndex),
        bottomNavigationBar: _getBottomNavigationBar(),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const FeedScreen();
      case 1:
        return const MapScreen();
      default:
        return Container();
    }
  }

  Widget _getBottomNavigationBar() {
    return BottomNavigationBar(
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
      selectedItemColor: ColorPalette.primaryGreen,
    );
  }
}
