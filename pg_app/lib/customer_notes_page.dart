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
      noteController.clear();
      _fetchNotes();
    } else {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thêm ghi chú thất bại')),
      );
    }
  }

  Future<void> _updateNoteDialog(int noteId, String currentNote) async {
    TextEditingController editController = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa ghi chú'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: 'Ghi chú'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedNote = editController.text;
                await _updateNote(noteId.toString(), updatedNote); // Chuyển đổi noteId sang String
                Navigator.of(context).pop();
                _fetchNotes();
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateNote(String noteId, String updatedNote) async { // Đổi kiểu dữ liệu của noteId sang String
    final response = await http.post(
      Uri.parse('http://buimanhhung.id.vn/edit_note.php'),
      body: {
        'note_id': noteId, // noteId đã được chuyển đổi sang String
        'note': updatedNote,
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      _fetchNotes();
    } else {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật ghi chú thất bại')),
      );
    }
  }

  Future<void> _deleteNoteDialog(int noteId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa ghi chú'),
          content: Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deleteNote(noteId.toString()); // Chuyển đổi noteId sang String
                Navigator.of(context).pop();
                _fetchNotes();
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(String noteId) async { // Đổi kiểu dữ liệu của noteId sang String
    final response = await http.post(
      Uri.parse('http://buimanhhung.id.vn/delete_note.php'),
      body: {
        'note_id': noteId, // noteId đã được chuyển đổi sang String
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      _fetchNotes();
    } else {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa ghi chú thất bại')),
      );
    }
  }

  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(note['noidung']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _updateNoteDialog(int.parse(note['id']), note['noidung']); // Chuyển đổi note['id'] sang int
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteNoteDialog(int.parse(note['id'])); // Chuyển đổi note['id'] sang int
                },
              ),
            ],
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
