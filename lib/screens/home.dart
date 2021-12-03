import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/note.dart';
import '../models/notes_database.dart';
import '../theme/note_colors.dart';

import 'notes_edit.dart';

const c1 = 0xFFFDFFFC,
    c2 = 0xFFFF595E,
    c3 = 0xFF374B4A,
    c4 = 0xFF00B1CC,
    c5 = 0xFFFFD65C,
    c6 = 0xFFB9CACA,
    c7 = 0x80374B4A,
    c8 = 0x3300B1CC,
    c9 = 0xCCFF595E;

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  List<Map<String, dynamic>>? notesData;
  List<int> selectedNoteIds = [];

  Future<List<Map<String, dynamic>>> readDatabase() async {
    try {
      NoteDatabase notesDb = NoteDatabase();
      await notesDb.initDatabase();
      List<Map> notesList = await notesDb.getAllNotes();
      await notesDb.closeDatabase();
      List<Map<String, dynamic>> notesData =
          List<Map<String, dynamic>>.from(notesList);
      notesData.sort((a, b) => (a['title']).compareTo(b['title']));
      return notesData;
    } catch (e) {
      print('Error retrieving notes: ${e}');
      return [{}];
    }
  }

  void afterNavigatorPop() {
    setState(() {});
  }

  void handleNoteListLongPress(int id) {
    setState(() {
      if (selectedNoteIds.contains(id) == false) {
        selectedNoteIds.add(id);
      }
    });
  }

  void handleNoteListTapAfterSelect(int id) {
    setState(() {
      if (selectedNoteIds.contains(id) == true) {
        selectedNoteIds.remove(id);
      }
    });
  }

  void handleDelete() async {
    try {
      NoteDatabase notesDb = NoteDatabase();
      await notesDb.initDatabase();
      for (int id in selectedNoteIds) {
        int result = await notesDb.deleteNote(id);
      }
      await notesDb.closeDatabase();
    } catch (e) {
      print('Error handling deletion: ${e}');
    } finally {
      setState(() {
        selectedNoteIds = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super note',
      home: Scaffold(
        backgroundColor: const Color(c6),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(c2),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: const Text(
            'Super note',
            style: TextStyle(
              color: Color(c5),
            ),
          ),
          actions: [
            (selectedNoteIds.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Color(c1),
                    ),
                    tooltip: 'Delete',
                    onPressed: () => handleDelete(),
                  )
                : Container()),
          ],
        ),
        body: FutureBuilder(
          future: readDatabase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                notesData = snapshot.data as List<Map<String, dynamic>>;
                return Stack(
                  children: <Widget>[
                    AllNoteLists(
                      snapshot.data,
                      selectedNoteIds,
                      afterNavigatorPop,
                      handleNoteListLongPress,
                      handleNoteListTapAfterSelect,
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                print('Error handling database');
              }
            }

            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(c3),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.add,
            color: Color(c5),
          ),
          tooltip: 'New notes',
          backgroundColor: const Color(c4),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesEdit(['new', {}])),
            ).then((dynamic value) {
              afterNavigatorPop();
            });
          },
        ),
      ),
    );
  }
}

class AllNoteLists extends StatelessWidget {
  final data;
  final selectedNoteIds;
  final afterNavigatorPop;
  final handleNoteListLongPress;
  final handleNoteListTapAfterSelect;

  AllNoteLists(
    this.data,
    this.selectedNoteIds,
    this.afterNavigatorPop,
    this.handleNoteListLongPress,
    this.handleNoteListTapAfterSelect,
  );

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        dynamic item = data[index];
        return DisplayNotes(
          item,
          selectedNoteIds,
          (selectedNoteIds.contains(item['id']) == false ? false : true),
          afterNavigatorPop,
          handleNoteListLongPress,
          handleNoteListTapAfterSelect,
        );
      },
    );
  }
}

class DisplayNotes extends StatelessWidget {
  final notesData;
  final selectedNoteIds;
  final selectedNote;
  final callAfterNavigatorPop;
  final handleNoteListLongPress;
  final handleNoteListTapAfterSelect;

  DisplayNotes(
    this.notesData,
    this.selectedNoteIds,
    this.selectedNote,
    this.callAfterNavigatorPop,
    this.handleNoteListLongPress,
    this.handleNoteListTapAfterSelect,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Material(
        elevation: 1,
        color: (selectedNote == false ? const Color(c1) : const Color(c8)),
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
          onTap: () {
            if (selectedNote == false) {
              if (selectedNoteIds.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesEdit(['update', notesData]),
                  ),
                ).then((dynamic value) {
                  callAfterNavigatorPop();
                });
                return;
              } else {
                handleNoteListLongPress(notesData['id']);
              }
            } else {
              handleNoteListTapAfterSelect(notesData['id']);
            }
          },
          onLongPress: () {
            handleNoteListLongPress(notesData['id']);
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: (selectedNote == false
                              ? Color(NoteColors[notesData['noteColor']]!['b']
                                  as int)
                              : const Color(c9)),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: (selectedNote == false
                              ? Text(
                                  notesData['title'][0],
                                  style: const TextStyle(
                                    color: Color(c1),
                                    fontSize: 21,
                                  ),
                                )
                              : const Icon(
                                  Icons.check,
                                  color: Color(c1),
                                  size: 21,
                                )),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        notesData['title'] ?? "",
                        style: const TextStyle(
                          color: Color(c3),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 3,
                      ),
                      Text(
                        notesData['content'] != null
                            ? notesData['content'].split('\n')[0]
                            : "",
                        style: const TextStyle(
                          color: Color(c7),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
