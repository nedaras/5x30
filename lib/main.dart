import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  databaseFactory = kIsWeb ? databaseFactoryFfiWeb : databaseFactoryFfi;

  final sql = await openDatabase(
    join(await getDatabasesPath(), '.db'),
    onCreate: (db, version) async {
      await db.execute(
        '''CREATE TABLE Folder (
          ID   INTEGER AUTO_INCREMENT PRIMARY KEY,
          Name VARCHAR(64) NOT NULL
        );''',
      );

      await db.execute(
        '''CREATE TABLE Tag (
          ID   INT AUTO_INCREMENT PRIMARY KEY,
          Name VARCHAR(32) NOT NULL UNIQUE
        );''',
      );

      await db.execute(
        '''CREATE TABLE FolderTag (
          FolderID INTEGER,
          TagID    INTEGER,
          PRIMARY KEY (FolderID, TagID),
          FOREIGN KEY (FolderID) REFERENCES Folder(ID) ON DELETE CASCADE,
          FOREIGN KEY (TagId) REFERENCES Tag(ID) ON DELETE CASCADE
        );'''
      );
    },
    version: 1,
  );

  final List<Map<String, dynamic>> result = await sql.query('Folder');
  List<String> folders = result.map((folder) => folder['Name'] as String).toList();

  runApp(MyApp(
    folders: folders,
  ));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.folders});

  final List<String> folders;

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
                        //onChanged:
                            //(value) => setState(() => folders.add(value)),
                      ),
                    ),
                    Folders(folders),
                    ElevatedButton(
                      onPressed: () async {
                        final sql = await openDatabase(
                          join(await getDatabasesPath(), '.db'),
                        );

                        await sql.insert(
                          'Folder',
                          {
                            'Name': 'Lemongym',
                          },
                        );

                        setState(() => folders.add('Lemongym'));
                      },
                      child: Text('Add "Lemongym" folder'),
                    ),
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
