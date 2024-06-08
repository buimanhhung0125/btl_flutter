import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerNotesPage extends StatefulWidget {
  final Map<String, dynamic> customerInfo;
  final List<dynamic> orders;

  CustomerNotesPage({required this.customerInfo, required this.orders});

  @override
  _CustomerNotesPageState createState() => _CustomerNotesPageState();
}

class _CustomerNotesPageState extends State<CustomerNotesPage> {
  List<dynamic> notes = [];
  TextEditingController noteController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://buimanhhung.id.vn/get_customer_notes.php'),
      body: {
        'phone': widget.customerInfo['sdt'].toString(),
      },
    );

    final data = jsonDecode(response.body);
    // final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    setState(() {
      notes = data['notes'];
      isLoading = false;
    });
  }

  Future<void> _addNote() async {
    final response = await http.post(
      Uri.parse('http://buimanhhung.id.vn/add_note.php'),
      body: {
        'phone': widget.customerInfo['sdt'].toString(),
        'note': noteController.text,
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        notes.add(data['note']);
        noteController.clear();
      });
    }
  }

  Future<void> _updateNote(int noteId, String updatedNote) async {
    final response = await http.post(
      Uri.parse('http://buimanhhung.id.vn/edit_note.php'),
      body: {
        'note_id': noteId.toString(),
        'note': updatedNote,
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        final index = notes.indexWhere((note) => note['id'] == noteId);
        if (index != -1) {
          notes[index]['note'] = updatedNote;
        }
      });
    }
  }

  Future<void> _deleteNote(int noteId) async {
    final response = await http.post(
      Uri.parse('http://buimanhhung.id.vn/delete_note.php'),
      body: {
        'note_id': noteId.toString(),
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        notes.removeWhere((note) => note['id'] == noteId);
      });
    }
  }

  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        TextEditingController editController =
            TextEditingController(text: note['noidung']);
        return ListTile(
          title: TextField(
            controller: editController,
            decoration: InputDecoration(border: InputBorder.none),
            onSubmitted: (newValue) {
              _updateNote(note['id'], newValue);
            },
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteNote(note['id']);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi Chú Khách Hàng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Tên: ${widget.customerInfo['tenkh']}'),
            Text('Số điện thoại: ${widget.customerInfo['sdt']}'),
            Text('Ngày sinh: ${widget.customerInfo['ngaysinh']}'),
            Text('Địa chỉ: ${widget.customerInfo['diachi']}'),
            SizedBox(height: 20),
            Text('Ghi chú:'),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildNotesList(),
            ),
            TextField(
              controller: noteController,
              decoration: InputDecoration(labelText: 'Thêm ghi chú'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addNote,
              child: Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}
