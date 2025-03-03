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
          surface: Colors.black,
          onSurface: Colors.white,
          onSurfaceVariant: Color(0xFF9898A0),
          primary: Color(0xFFE3B00B),
          surfaceContainer: Color(0xFF1A1A1E),
        ),
      ),
      home: const Scaffold(resizeToAvoidBottomInset: true, body: Home()),
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

  bool _showAddFolder = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(child: Container(color: Colors.red)),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder_copy),
                    onPressed: () => setState(() => _showAddFolder = true),
                    iconSize: 28.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_document),
                    onPressed: () => {},
                    iconSize: 28.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        if (_showAddFolder)
        Align(
          alignment: Alignment.bottomCenter, 
          child: Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () => setState(() => _showAddFolder = false),
                      ),
                      const Text("New Folder"),
                      TextButton(
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold, 
                          ),
                        ),
                        onPressed: () => {},
                      ),
                    ],
                  ),

                  const Input(hintText: "New Folder"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Input extends StatelessWidget {
  const Input({super.key, this.hintText, this.onChanged, this.controller});

  final String? hintText;

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
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        controller: controller,
        onChanged: onChanged,
      ),
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
