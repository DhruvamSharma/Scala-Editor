import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scala_editor/custom_image_picker.dart';
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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({
    super.key,
  });

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

  // TODO 2: Add a variable for image that we are going to select
  // and assign null for initialisation
  final _image = ValueNotifier<XFile?>(null);

  // TODO 6: Create a function to receive the selected file and change the state
  void _onImageSelected(XFile file) {
    _image.value = file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _buildBackground(MediaQuery.of(context).size.height / 2),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: kToolbarHeight,
            child: SafeArea(child: _buildHeader(context)),
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
                  width: 10.0,
                ),
              ),
              child: _buildPhotoWithFilter(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: _buildFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return ValueListenableBuilder(
      valueListenable: _image,
      builder: (context, xFile, child) {
        if (xFile == null) {
          return const SizedBox();
        } else {
          return FilterSelector(
            filters: _filters,
            onFilterChange: (Color color) {
              _onFilterChanged(color);
            },
          );
        }
      },
    );
  }

  Widget _buildBackground(double height) {
    return ValueListenableBuilder(
      valueListenable: _image,
      builder: (_, image, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            image: _image.value != null
                ? DecorationImage(
              image: FileImage(
                File(_image.value!.path),
              ),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: child,
        );
      },
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
        child: Container(
          decoration: BoxDecoration(color: _filterColor.value.withOpacity(0.0)),
        ),
      ),
    );
  }

  // TODO 4: reconfigure the function to take account of _image
  Widget _buildPhotoWithFilter() {
    return ValueListenableBuilder(
      valueListenable: _image,
      builder: (_, xFile, child) {
        if (xFile == null) {
          return CustomImagePicker(
            onImagePicked: _onImageSelected,
          );
        } else {
          return ValueListenableBuilder(
            valueListenable: _filterColor,
            builder: (context, color, child) {
              return Image.file(
                File(xFile.path),
                color: color.withOpacity(0.5),
                colorBlendMode: BlendMode.color,
                fit: BoxFit.cover,
              );
            },
          );
        }
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Text(
        'Chroma',
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
