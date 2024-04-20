import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedbackPage extends StatelessWidget {
  static const String routeName = '/FeedbackPage';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('app_feedbacks').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        var feedbackDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: feedbackDocs.length,
          itemBuilder: (context, index) {
            var feedback = feedbackDocs[index].data() as Map<String, dynamic>;
            return FutureBuilder<DataSnapshot>(
              future: _fetchUserDataFromRealtimeDatabase(feedback['userId']),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('User ID: ${feedback['userId']}'),
                    subtitle: const Text('Loading...'),
                  );
                }
                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return ListTile(
                    title: Text('User ID: ${feedback['userId']}'),
                    subtitle: const Text('Customer Name: Not found'),
                  );
                }
                var userData = userSnapshot.data!.value as Map<dynamic, dynamic>;
                var customerName = userData['name'] ?? '';

                // format timestamp to display date time format
                var timestamp = (feedback['timestamp'] as Timestamp).toDate();
                var formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);

                // retrieve rating
                var rating = feedback['rating'] != null ? feedback['rating'].toDouble() : 0.0;

                // display images
                var imageUrls = feedback['imageUrls'] != null ? List<String>.from(feedback['imageUrls']) : [];

                // feedback status
                var status = feedback['status'] != null ? feedback['status'] : 'pending';

                return ListTile(
                  title: Text(' $customerName'),
                  subtitle: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${feedback['feedback']}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 5,),
                          RatingBar.builder(
                            initialRating: rating,
                            minRating: 0,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {

                            },
                          ),
                          const SizedBox(height: 5,),

                          Text(' $formattedTimestamp'),

                          const SizedBox(height: 5,),

                          Text(
                            ' $status',
                            style: TextStyle(
                              color: status == 'approved' ? Colors.green : status == 'rejected' ? Colors.red : Colors.black,
                            ),
                          ),


                          const SizedBox(height: 8),


                        ],
                      ),

                      const SizedBox(width: 80,),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: imageUrls.map((imageUrl) =>
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ImageScreen(imageUrl: imageUrl)));
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                child: Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                        ).toList(),
                      ),
                      const SizedBox(width: 20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          ElevatedButton(
                            onPressed: () {
                              _updateFeedbackStatus(feedbackDocs[index].reference, 'rejected');
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red
                            ),
                            child: const Text('Reject', style: TextStyle(color: Colors.white),),
                          ),

                          const SizedBox(width: 10,),

                          ElevatedButton(
                            onPressed: () {
                              _updateFeedbackStatus(feedbackDocs[index].reference, 'approved');
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green
                            ),
                            child: const Text('Approve' , style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

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

  Future<void> _updateFeedbackStatus(DocumentReference feedbackRef, String status) async {
    try {
      await feedbackRef.update({'status': status});
      print('Feedback status updated successfully to $status');
    } catch (error) {
      print('Error updating feedback status: $error');
    }
  }
}

class ImageScreen extends StatelessWidget {
  final String imageUrl;

  ImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
