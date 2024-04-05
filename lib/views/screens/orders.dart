import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Order {
  final String orderId;
  final String customerName;
  final String tankerName;
  final int liters;
  final double price;
  final String paymentId;

  Order({
    required this.orderId,
    required this.customerName,
    required this.tankerName,
    required this.liters,
    required this.price,
    required this.paymentId,
  });
}

class Orders extends StatefulWidget {
  static const String routeName = '/Orders';
  const Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  late List<Order> orders;

  @override
  void initState() {
    super.initState();
    orders = [];
    fetchOrders();
  }

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
              customerName: value['buyerDetails']['name'] ?? '',
              tankerName: value['stationDetails']['stationName'] ?? '',
              liters: value['requestedLiters'] ?? 0,
              price: double.parse(value['total'] ?? '0'),
              paymentId: value['paymentId'] ?? '',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Customer Name')),
            DataColumn(label: Text('Tanker Name')),
            DataColumn(label: Text('Liters')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Payment ID')),
          ],
          rows: orders.map<DataRow>((order) {
            return DataRow(cells: [
              DataCell(Text(order.orderId)),
              DataCell(Text(order.customerName)),
              DataCell(Text(order.tankerName)),
              DataCell(Text(order.liters.toString())),
              DataCell(Text(order.price.toString())),
              DataCell(Text(order.paymentId)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
