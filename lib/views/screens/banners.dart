import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Banners extends StatefulWidget {
  static const String routeName = '/Banners';
  const Banners({super.key});

  @override
  State<Banners> createState() => _BannersState();
}

class _BannersState extends State<Banners> {

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://myfuelz.appspot.com',
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // image
  dynamic _image;

  String? fileName;

  // retrieve banners
  List<String> banners = [];

  // retrieve banners from Firestore
  Future<void> retrieveBanners() async {
    QuerySnapshot querySnapshot = await _firestore.collection('banners').get();
    setState(() {
      banners = querySnapshot.docs.map((doc) => doc['image'] as String).toList();
    });
  }


  deleteBanner(String bannerUrl) async {
    // extract file name from URL
    String fileName = bannerUrl.split('/').last;


    await _firestore.collection('banners').where('image', isEqualTo: bannerUrl).get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });


    await _storage.ref().child('Banners').child(fileName).delete();


    // update banners list
    setState(() {
      banners.remove(bannerUrl);
      retrieveBanners();
    });
  }



  @override
  void initState() {
    super.initState();

    retrieveBanners();
  }

  pickImage() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  uploadToStorage(dynamic image) async {
    Reference ref = _storage.ref().child('Banners').child(fileName!);

    UploadTask uploadTask = ref.putData(image);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadToFirestore() async {
    EasyLoading.show();
    if (_image != null) {
      String imageUrl = await uploadToStorage(_image);

      await _firestore.collection('banners').doc(fileName).set({
        'image': imageUrl,
      }).whenComplete(() {
        EasyLoading.dismiss();

        setState(() {
          _image = null;

          retrieveBanners();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Banners',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      height: 160,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: _image != null
                          ? Image.memory(
                        _image,
                        fit: BoxFit.cover,
                      )
                          : const Center(child: Text('Banner')),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        pickImage();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: const EdgeInsets.all(15.0),
                        fixedSize: const Size(70, 35),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.blue.shade900,
                      ),
                      child: const Icon(Icons.add),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  uploadToFirestore();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.all(15.0),
                  fixedSize: const Size(100, 35),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: Colors.blue.shade900,
                ),
                child: const Text('Save'),
              ),
            ],
          ),

          // display banners
          banners.isEmpty
              ? const Text('No banners available.')
              :
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return Container(
                width: 250,
                height: 200,
                child: Card(
                  child: Stack(
                    children: [
                      Image.network(
                        banners[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text('Error loading image'),
                          );
                        },
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: ElevatedButton(
                          onPressed: () {
                            deleteBanner(banners[index]);
                          },
                          style: ElevatedButton.styleFrom(),
                          child: const Icon(Icons.delete, color: Colors.red,),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}
