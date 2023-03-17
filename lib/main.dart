import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scala_editor/filter_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.black));
    super.initState();
  }

  final _filters = [
    Colors.white,
    ...List.generate(
      Colors.primaries.length,
      (index) => Colors.primaries[(index * 4) % Colors.primaries.length],
    )
  ];

  final _filterColor = ValueNotifier<Color>(Colors.white);

  void _onFilterChanged(Color value) {
    _filterColor.value = value;
  }

  static const String _imageLink = 'https://docs.flutter.dev/cookbook/img-files/effects/instagram-buttons/millenial-dude.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        clipBehavior: Clip.none,
        children: [

          Center(
            child: Container(
              height: MediaQuery.of(context).size.height/2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    _imageLink,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 56,
            child: SafeArea(child: _buildHeader()),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(60),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _filterColor.value,
                    width: 2.0,
                  )),
              child: _buildPhotoWithFilter(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: FilterSelector(
              filters: _filters,
              onFilterChange: (Color color) {
                _onFilterChanged(color);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWithFilter() {
    return ValueListenableBuilder(
      valueListenable: _filterColor,
      builder: (context, color, child) {
        return Image.network(
          _imageLink,
          color: color.withOpacity(0.5),
          colorBlendMode: BlendMode.color,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Text(
        'Chroma Editor',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
