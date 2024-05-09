import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class ReportsPage extends StatelessWidget {
  static const String routeName = '/reports';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          var reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              var report = reports[index].data() as Map<String, dynamic>;
              return FutureBuilder<DataSnapshot>(
                future: _fetchUserDataFromRealtimeDatabase(report['userId']),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('User ID: ${report['userId']}'),
                      subtitle: const Text('Loading...'),
                    );
                  }
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text('User ID: ${report['userId']}'),
                      subtitle: const Text('Customer Name: Not found'),
                    );
                  }
                  var userData = userSnapshot.data!.value as Map<dynamic, dynamic>;
                  var customerName = userData['name'] ?? '';

                  var reportText = report['report'];
                  var timestamp = report['timestamp'] as Timestamp;

                  // convert timestamp to DateTime
                  var dateTime = timestamp.toDate();

                  return Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 5, left: 10, right: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: ListTile(
                        title: Text('Report: $reportText'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$customerName'),
                            Text('${_formatDateTime(dateTime)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.message, color: Colors.black45,),
                          onPressed: () {
                            _showMessageDialog(context, report['userId'] );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
}

// get user data from realtime database
Future<DataSnapshot> _fetchUserDataFromRealtimeDatabase(String userId) async {
  try {
    return await FirebaseDatabase.instance.reference().child('users').child(userId).once().then((event) {
      return event.snapshot;
    });
  } catch (error) {
    print("Failed to fetch user data: $error");
    throw error;
  }
}

// function to show notification dialog
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