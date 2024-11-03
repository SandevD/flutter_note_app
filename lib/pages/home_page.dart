import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_simple_note/models/note.dart';
import 'package:my_simple_note/services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final List<Color> _noteColors = [
    Colors.lightBlueAccent.withOpacity(0.9),
    Colors.lightGreenAccent.withOpacity(0.9),
    Colors.amberAccent.withOpacity(0.9),
    Colors.pinkAccent.withOpacity(0.9),
    Colors.orangeAccent.withOpacity(0.9),
    Colors.purpleAccent.withOpacity(0.9),
    Colors.tealAccent.withOpacity(0.9),
  ];

  final List<Color> _recentColors = []; // Track recently used colors

  String? _note;

  Color _getRandomColor() {
    List<Color> availableColors = _noteColors
        .where((color) => !_recentColors.contains(color))
        .toList();

    if (availableColors.isEmpty) {
      _recentColors.clear();
      availableColors = List.from(_noteColors);
    }

    final color = availableColors[Random().nextInt(availableColors.length)];
    _recentColors.add(color);

    if (_recentColors.length > 3) {
      _recentColors.removeAt(0); // Keep only the last 3 used colors
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'My Simple Note',
          style: TextStyle(fontSize: 28, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/3209/3209265.png'),
            ),
          ),
        ],
      ),
      floatingActionButton: _addNoteButton(),
      body: _noteList(),
    );
  }

  Widget _addNoteButton() {
    return FloatingActionButton(
      onPressed: () {
        _showAddNoteModal(context);
      },
      backgroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  void _showAddNoteModal(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: MediaQuery.of(context).viewInsets,
          child: _buildAddNoteModal(context, titleController, contentController),
        );
      },
    );
  }

  Widget _buildAddNoteModal(
      BuildContext context, TextEditingController titleController, TextEditingController contentController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Note',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Note Title',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          TextField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: 'Note Content',
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              String noteTitle = titleController.text.trim();
              String noteContent = contentController.text.trim();
              if (noteContent.isNotEmpty) {
                setState(() {
                  _databaseService.addNotes(noteTitle, noteContent);
                });
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteList() {
    return FutureBuilder(
      future: _databaseService.getNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching notes"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            Note note = snapshot.data![index];
            return _noteCard(note, context);
          },
        );
      },
    );
  }

  Widget _noteCard(Note note, BuildContext context) {
    final randomColor = _getRandomColor();

    return GestureDetector(
      onTap: () {
        _showEditModal(context, note);
      },
      child: Container(
        decoration: BoxDecoration(
          color: randomColor,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  note.title.length > 10 ? '${note.title.substring(0, 10)}...' : note.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // White background
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(100.0), // Rounded corners
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context, note.id);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                note.content,
                style: const TextStyle(color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _databaseService.deleteNoteById(noteId);
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditModal(BuildContext context, Note note) {
    TextEditingController titleController =
    TextEditingController(text: note.title);
    TextEditingController contentController =
    TextEditingController(text: note.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: MediaQuery.of(context).viewInsets,
          child: _buildEditModal(
              context, note, titleController, contentController),
        );
      },
    );
  }

  Widget _buildEditModal(
      BuildContext context,
      Note note,
      TextEditingController titleController,
      TextEditingController contentController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Edit Note',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Edit Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: contentController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Edit Content'),
          ),
          const SizedBox(height: 20),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String titleContent = titleController.text.trim();
                    String noteContent = contentController.text.trim();
                    if (noteContent.isNotEmpty) {
                      setState(() {
                        _databaseService.updateNotes(note.id, titleContent, noteContent);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]),
        ],
      ),
    );
  }
}
