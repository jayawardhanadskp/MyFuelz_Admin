import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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

class Tankers extends StatefulWidget {
  static const String routeName = '/Tankers';

  const Tankers({Key? key}) : super(key: key);

  @override
  State<Tankers> createState() => _TankersState();
}

class _TankersState extends State<Tankers> {
  late List<User> tankers;
  late Map<String, int> tankerOrdersCount;
  late Map<String, double> tankerAvgRating;

  @override
  void initState() {
    super.initState();
    tankers = [];
    fetchTankersData();
    tankerOrdersCount = {};
    tankerAvgRating = {};
  }

  void fetchTankersData() {
    DatabaseReference tankerRef = FirebaseDatabase.instance.reference();
    tankerRef.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values =
          (event.snapshot.value as Map<dynamic, dynamic>?) ?? {};
      values.forEach((key, value) {
        setState(() {
          tankers.add(User.fromMap(value, key.toString()));
        });
        fetchOrdersCount(key.toString());
        fetchAvgRating(key.toString());
      });
    }, onError: (error) {
      print("Failed to fetch tanker data: $error");
    });
  }

  Future<void> fetchOrdersCount(String tankerId) async {
    try {
      DatabaseReference ordersRef = FirebaseDatabase.instance.reference();
      DatabaseEvent event = await ordersRef
          .child('Order')
          .orderByChild('stationId')
          .equalTo(tankerId)
          .once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        int ordersCount = (snapshot.value as Map).length;
        setState(() {
          tankerOrdersCount[tankerId] = ordersCount;
        });
      } else {
        setState(() {
          tankerOrdersCount[tankerId] = 0;
        });
      }
    } catch (error) {
      print("Failed to fetch orders count: $error");
    }
  }

  Future<void> fetchAvgRating(String tankerId) async {
    try {
      double totalRating = 0;
      int numRatings = 0;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('serviceProviderId', isEqualTo: tankerId)
          .get();

      querySnapshot.docs.forEach((doc) {
        totalRating += doc['rating'];
        numRatings++;
      });

      double avgRating = numRatings > 0 ? totalRating / numRatings : 0;

      setState(() {
        tankerAvgRating[tankerId] = avgRating;
      });
    } catch (error) {
      print("Failed to fetch average rating: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<User> filteredTankers =
    tankers.where((tanker) => tanker.role == 'Tanker').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tankers'),
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
            DataColumn(label: Text('Avg. Rating')),
            DataColumn(label: Text('Notification')),
          ],
          rows: filteredTankers.map<DataRow>((tanker) {
            return DataRow(cells: [
              DataCell(
                CircleAvatar(
                  backgroundImage: NetworkImage(tanker.imageURL ?? ''),
                ),

              ),
              DataCell(Text(tanker.name)),
              DataCell(Text(tanker.email)),
              DataCell(Text(tanker.phone)),
              DataCell(Text('${tankerOrdersCount[tanker.uid] ?? 0}')),
              DataCell(
                RatingBar(
                  initialRating: tankerAvgRating[tanker.uid] ?? 0,
                  itemSize: 20,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber),
                    half: Icon(Icons.star_half, color: Colors.amber),
                    empty: Icon(Icons.star_border, color: Colors.amber),
                  ),
                  onRatingUpdate: (rating) {

                  },
                ),
              ),
              DataCell(IconButton(
                icon: const Icon(Icons.message, color: Colors.black45,),
                onPressed: () {
                  _showMessageDialog(context, tanker.uid);
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