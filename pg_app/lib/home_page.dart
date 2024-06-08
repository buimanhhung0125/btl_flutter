import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'customer_notes_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController phoneController = TextEditingController();
  Map<String, dynamic>? customerInfo;
  List<dynamic> orders = [];

  Future<void> _fetchCustomerInfo(String phone) async {
    final response = await http.post(
      Uri.parse('http://buimanhhung.id.vn/get_customer_info.php'),
      body: {
        'phone': phone,
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      setState(() {
        customerInfo = data['customer'];
        orders = data['orders'];
      });
    } else {
      setState(() {
        customerInfo = null;
        orders = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy khách hàng')),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Chủ'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Nhập số điện thoại'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fetchCustomerInfo(phoneController.text),
              child: Text('Tìm kiếm'),
            ),
            SizedBox(height: 20),
            customerInfo != null ? _buildCustomerInfo() : Text('Không có dữ liệu khách hàng'),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerNotesPage(
              customerInfo: customerInfo!,
              orders: orders,
            ),
          ),
        );
      },
      child: Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Tên: ${customerInfo!['tenkh']}'),
              Text('Số điện thoại: ${customerInfo!['sdt']}'),
              Text('Ngày sinh: ${customerInfo!['ngaysinh']}'),
              Text('Địa chỉ: ${customerInfo!['diachi']}'),
              SizedBox(height: 20),
              Text('Lịch sử mua hàng:'),
              _buildOrdersTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Tên SP')),
          DataColumn(label: Text('SL')),
          // DataColumn(label: Text('Giá')),
          // DataColumn(label: Text('Tổng')),
          DataColumn(label: Text('Ngày mua')),
        ],
        rows: orders.map((order) {
          return DataRow(cells: [
            DataCell(Text(order['tensp'].toString())),
            DataCell(Text(order['soluong'].toString())),
            // DataCell(Text(order['gia'].toString())),
            // DataCell(Text(order['thanhtien'].toString())),
            DataCell(Text(order['ngaymua'])),
          ]);
        }).toList(),
      ),
    );
  }
}
