import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/notes_database.dart';
import '../theme/note_colors.dart';

const c1 = 0xFFFDFFFC,
    c2 = 0xFFFF595E,
    c3 = 0xFF374B4A,
    c4 = 0xFF00B1CC,
    c5 = 0xFFFFD65C,
    c6 = 0xFFB9CACA,
    c7 = 0x80374B4A;

class NotesEdit extends StatefulWidget {
  final args;

  const NotesEdit(this.args);
  _NotesEdit createState() => _NotesEdit();
}

class _NotesEdit extends State<NotesEdit> {
  String noteTitle = '';
  String noteContent = '';
  String noteColor = 'red';

  TextEditingController _titleTextController = TextEditingController();
  TextEditingController _contentTextController = TextEditingController();

  void handleTitleTextChange() {
    setState(() {
      noteTitle = _titleTextController.text.trim();
    });
  }

  void handleNoteTextChange() {
    setState(() {
      noteContent = _contentTextController.text.trim();
    });
  }

  void handleColor(currentContext) {
    showDialog(
      context: currentContext,
      builder: (context) => ColorPalette(
        parentContext: currentContext,
      )
    ).then((colorName) {
      if (colorName != null) {
        setState(() {
          noteColor = colorName;
        });
      }
    });
  }

  void handleBackButton() async {
    if (noteTitle.isEmpty) {
      if (noteContent.isEmpty) {
        Navigator.pop(context);
        return;
      }

      String title = noteContent.split('\n')[0];
      if (title.length > 31) {
        title = title.substring(0, 31);
      }

      setState(() {
        noteTitle = title;
      });
    }

    // Save new note
    if (widget.args[0] == 'new') {
      Note noteObj = Note(
        title: noteTitle,
        content: noteContent,
        noteColor: noteColor,
      );

      try {
        await _insertNote(noteObj);
      } catch(e) {
        print('Error saving new note: ${e}');
      } finally {
        Navigator.pop(context);
        return;
      }
    // Update note
    } else if (widget.args[0] == 'update') {
      Note noteObj = Note(
        id: widget.args[1]['id'],
        title: noteTitle,
        content: noteContent,
        noteColor: noteColor,
      );

      try {
        await _updateNote(noteObj);
      } catch(e) {
        print('Error updating note: ${e}');
      } finally {
        Navigator.pop(context);
        return;
      }
    }

    Note noteObj = Note(
      title: noteTitle,
      content: noteContent,
      noteColor: noteColor,
    );
    try {
      await _insertNote(noteObj);
    } catch(e) {
      print('Error inserting row: ${e}');
    } finally {
      Navigator.pop(context);
      return;
    }
  }

  Future<void> _insertNote(Note note) async {
    NoteDatabase notesDb = NoteDatabase();
    await notesDb.initDatabase();
    int result = await notesDb.insertNote(note);
    await notesDb.closeDatabase();
  }

  Future<void> _updateNote(Note note) async {
    NoteDatabase notesDb = NoteDatabase();
    await notesDb.initDatabase();
    int result = await notesDb.updateNote(note);
    await notesDb.closeDatabase();
  }

  @override
  void initState() {
    super.initState();
    noteTitle = (widget.args[0] == 'new' ? '' : widget.args[1]!['title']);
    noteContent = (widget.args[0] == 'new' ? '' : widget.args[1]!['content']);
    noteColor = (widget.args[0] == 'new' ? 'red' : widget.args[1]!['noteColor']);

    _titleTextController.text = (widget.args[0] == 'new' ? '' : widget.args[1]!['title']);
    _contentTextController.text = (widget.args[0] == 'new' ? '' : widget.args[1]!['content']);
    _titleTextController.addListener(handleTitleTextChange);
    _contentTextController.addListener(handleNoteTextChange);
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(NoteColors[noteColor]!['l']??0),
      appBar: AppBar(
        backgroundColor: Color(NoteColors[noteColor]!['b']??1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(c1),
          ),
          tooltip: 'Back',
          onPressed: handleBackButton,
        ),
        title: NoteTitleEntry(_titleTextController),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.color_lens,
              color: Color(c1),
            ),
            tooltip: 'Color palette',
            onPressed: () => handleColor(context),
          ),
        ],
      ),
      body: NoteEntry(_contentTextController),
    );
  }
}

class NoteTitleEntry extends StatelessWidget {
  final _textFieldController;

  NoteTitleEntry(this._textFieldController);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textFieldController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.all(0),
        counter: null,
        counterText: "",
        hintText: 'Title',
        hintStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ),
      maxLength: 31,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
        height: 1.5,
        color: Color(c1),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }
}

class NoteEntry extends StatelessWidget {
  final _textFieldController;

  NoteEntry(this._textFieldController);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _textFieldController,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        decoration: null,
        style: const TextStyle(
          fontSize: 19,
          height: 1.5,
        ),
      ),
    );
  }
}

class ColorPalette extends StatelessWidget {
  final parentContext;

  const ColorPalette({
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(c1),
      clipBehavior: Clip.hardEdge,
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: MediaQuery.of(context).size.width * 0.02,
          runSpacing: MediaQuery.of(context).size.width * 0.02,
          children: NoteColors.entries.map((entry) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(entry.key),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.12,
                height: MediaQuery.of(context).size.width * 0.12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.06),
                  color: Color(entry.value['b']??1),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
