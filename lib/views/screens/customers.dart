import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? imageURL;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.imageURL,
  });

  factory User.fromMap(Map<dynamic, dynamic> data, String uid) {
    return User(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      imageURL: data['imageURL'],
    );
  }
}

class Customers extends StatefulWidget {
  static const String routeName = '/Customers';

  const Customers({Key? key}) : super(key: key);

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  late List<User> users;
  late Map<String, int> userOrdersCount;

  @override
  void initState() {
    super.initState();
    users = [];
    fetchUserData();
    userOrdersCount = {};
  }

  void fetchUserData() {
    DatabaseReference userRef = FirebaseDatabase.instance.reference();
    userRef.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values =
          (event.snapshot.value as Map<dynamic, dynamic>?) ?? {};
      values.forEach((key, value) {
        setState(() {
          users.add(User.fromMap(value, key.toString()));
        });
        fetchOrdersCount(key.toString());
      });
    }, onError: (error) {
      print("Failed to fetch user data: $error");
    });
  }

  Future<void> fetchOrdersCount(String tankerId) async {
    try {
      DatabaseReference ordersRef = FirebaseDatabase.instance.reference();
      DatabaseEvent event = await ordersRef
          .child('Order')
          .orderByChild('userId')
          .equalTo(tankerId)
          .once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        int ordersCount = (snapshot.value as Map).length;
        setState(() {
          userOrdersCount[tankerId] = ordersCount;
        });
      } else {
        setState(() {
          userOrdersCount[tankerId] = 0;
        });
      }
    } catch (error) {
      print("Failed to fetch orders count: $error");
    }
  }

  @override
  Widget build(BuildContext context) {

    List<User> filteredUsers = users.where((user) => user.role == 'User').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Photo')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Orders')),
            DataColumn(label: Text('Notification')),
          ],
          rows: filteredUsers.map<DataRow>((user) {
            return DataRow(cells: [
              DataCell(
                CircleAvatar(
                  backgroundImage: user.imageURL != null
                      ? NetworkImage(user.imageURL!)
                      : null,
                ),
              ),
              DataCell(Text(user.name)),
              DataCell(Text(user.email)),
              DataCell(Text(user.phone)),
              DataCell(Text('${userOrdersCount[user.uid] ?? 0}')),
              DataCell(IconButton(
                icon: const Icon(Icons.message, color: Colors.black45,),
                onPressed: () {
                  _showMessageDialog(context, user.uid);
                },
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// function to show message dialog
void _showMessageDialog(BuildContext context, String customerId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String message = '';

      return AlertDialog(
        title: const Text('Send Notification'),
        content: TextField(
          onChanged: (value) {
            message = value;
          },
          decoration: const InputDecoration(hintText: 'Type your Notification'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // get current timestamp
              var timestamp = DateTime.now();

              // save message to Firebase collection
              try {
                await FirebaseFirestore.instance.collection('admin_messages').add({
                  'userId': customerId,
                  'message': message,
                  'timestamp': timestamp,
                });
                print('Message sent successfully.');
              } catch (error) {
                print('Error sending message: $error');
              }

              Navigator.of(context).pop();
            },
            child: const Text('Send'),
          ),
        ],
      );
    },
  );
}