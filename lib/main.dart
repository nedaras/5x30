import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  databaseFactory = kIsWeb ? databaseFactoryFfiWeb : databaseFactoryFfi;

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '5x30',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE3B00B),
          surfaceContainer: Color(0xFF1A1A1E),
        ),
      ),
      home: const Scaffold(
        resizeToAvoidBottomInset: false,
        body: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    // todo: idk can we make this sync?
    // problem is simple user can quickly do smth before we get them folders
    getDatabase()
        .then((db) => db.query('Folder'))
        .then(
          (result) => setState(() {
            _folders =
                result.map((folder) => folder['Name'] as String).toList();
          }),
        );
  }

  List<String> _folders = [];
  String _input = "";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scrollbar(
          // todo: offset scroll indicator widget by footers height
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0 + 60.0,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        // 64 chars is max for folder name
                        child: Search(
                          //onChanged: (value) => setState(() => _input = value),
                          onChanged:
                              (value) => setState(() => _folders.add(value)),
                        ),
                      ),
                      Folders(_folders),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                width: double.infinity,
                height: 48.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.folder_copy,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28.0,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.edit_document,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
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
    return Column(
      children: List.generate(_folders.length, (i) {
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
      }),
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: borderRadius,
      ),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

Future<Database> getDatabase() async {
  // todo: check how much mem is this thing doing if not that much just cache it
  return openDatabase(
    join(await getDatabasesPath(), '.db'),
    onCreate: (db, version) async {
      await db.execute('''CREATE TABLE Folder (
          ID   INTEGER AUTO_INCREMENT PRIMARY KEY,
          Name VARCHAR(64) NOT NULL
        );''');

      await db.execute('''CREATE TABLE Tag (
          ID   INT AUTO_INCREMENT PRIMARY KEY,
          Name VARCHAR(32) NOT NULL UNIQUE
        );''');

      await db.execute('''CREATE TABLE FolderTag (
          FolderID INTEGER,
          TagID    INTEGER,
          PRIMARY KEY (FolderID, TagID),
          FOREIGN KEY (FolderID) REFERENCES Folder(ID) ON DELETE CASCADE,
          FOREIGN KEY (TagId) REFERENCES Tag(ID) ON DELETE CASCADE
        );''');
    },
    version: 1,
  );
}
