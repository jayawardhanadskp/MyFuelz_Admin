import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// fetch user data
class User {
  final String uid;
  final String role;

  User({
    required this.uid,
    required this.role,

  });

  factory User.fromMap(Map<dynamic, dynamic> data, String uid) {
    return User(
      uid: uid,
      role: data['role'] ?? '',
    );
  }
}

// fetch order
class Order {
  final String orderId;

  Order({
    required this.orderId,

  });
}

class DashboardScreen extends StatefulWidget {

  static const String routeName = '/DashboardScreen';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  late List<User> users;
  late List<User> tankers;
  late List<Order> orders;

  @override
  void initState() {
    users = [];
    tankers = [];
    orders = [];
    fetchOrders();
    fetchUserData();
    fetchTankersData();
    super.initState();
  }

  // fetch cutomers
  void fetchUserData() {
    DatabaseReference userRef = FirebaseDatabase.instance.reference();
    userRef.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values =
          (event.snapshot.value as Map<dynamic, dynamic>?) ?? {};
      values.forEach((key, value) {
        setState(() {
          users.add(User.fromMap(value, key.toString()));
        });

      });
    }, onError: (error) {
      print("Failed to fetch user data: $error");
    });
  }

  // fetch tankers
  void fetchTankersData() {
    DatabaseReference tankerRef = FirebaseDatabase.instance.reference();
    tankerRef.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values =
          (event.snapshot.value as Map<dynamic, dynamic>?) ?? {};
      values.forEach((key, value) {
        setState(() {
          tankers.add(User.fromMap(value, key.toString()));
        });

      });
    }, onError: (error) {
      print("Failed to fetch tanker data: $error");
    });
  }

  // fetch orders
  void fetchOrders() {
    DatabaseReference ordersRef = FirebaseDatabase.instance.reference().child('Order');
    ordersRef.once().then((snapshot) {
      DataSnapshot dataSnapshot = snapshot.snapshot;
      Map<dynamic, dynamic>? values = dataSnapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((key, value) {
          setState(() {
            orders.add(Order(
              orderId: key.toString(),

            ));
          });
        });
      }
    }).catchError((error) {
      print("Failed to fetch orders: $error");
    });
  }

  @override
  Widget build(BuildContext context) {

    // get count of customers
    List<User> filteredUsers = users.where((user) => user.role == 'User').toList();
    int totalCustomers = filteredUsers.length;

    // get count of tankers
    List<User> filteredTankers = tankers.where((tanker) => tanker.role == 'Tanker').toList();
    int totalTankers = filteredTankers.length;

    // get count of orders
    int totalOrders = orders.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Column(
        children: [
          Image.asset('assets/images/dashbord.jpeg',),

          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blue.shade900.withOpacity(0.4),
                                  spreadRadius: 7,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3)
                              )
                            ]
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              border: Border.all(color: Colors.blue.shade900),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 15.0,right: 15.0, top: 15.0),
                                child: Text('Total Customers', style: TextStyle(color: Colors.white, fontSize: 25),),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(totalCustomers!.toString(), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),),
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blue.shade900.withOpacity(0.4),
                                  spreadRadius: 7,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3)
                              )
                            ]
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              border: Border.all(color: Colors.blue.shade900),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 15.0,right: 15.0, top: 15.0),
                                child: Text('Total Tankers', style: TextStyle(color: Colors.white, fontSize: 25),),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(totalTankers!.toString(), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),),
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.blue.shade900.withOpacity(0.4),
                                  spreadRadius: 7,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3)
                              )
                            ]
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              border: Border.all(color: Colors.blue.shade900),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 15.0,right: 15.0, top: 15.0),
                                child: Text('Total Orders', style: TextStyle(color: Colors.white, fontSize: 25),),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(totalOrders!.toString(), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),),
                              )

                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
      
    );
  }
}
