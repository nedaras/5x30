import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final List<String> _folders = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '5x30',
      theme: ThemeData(
        // todo: add like a theme idk
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.all(12.0),
          child: StatefulBuilder(
            builder:
                (ctx, setState) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Search(
                        onChanged:
                            (value) => setState(() => _folders.add(value)),
                      ),
                    ),
                    Folders(_folders),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

class Search extends StatelessWidget {
  const Search({super.key, this.onChanged, this.controller});

  final Function(String)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Color(0xFF9898A0)),
          //border: InputBorder.none,
        ),
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }
}

class Folders extends StatelessWidget {
  const Folders(this._folders, {super.key});

  final List<String> _folders;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (ctx, i) {
          double top = 0.0;
          double bottom = 0.0;

          if (i == 0) top = 12.0;
          if (i == _folders.length - 1) bottom = 12.0;

          return Folder(
            title: _folders[i],
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(top),
              bottom: Radius.circular(bottom),
            ),
          );
        },
      ),
    );
  }
}

class Folder extends StatelessWidget {
  const Folder({
    super.key,
    required this.title,
    this.borderRadius = BorderRadius.zero,
  });

  final String title;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48.0,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1E),
        borderRadius: borderRadius,
      ),
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
