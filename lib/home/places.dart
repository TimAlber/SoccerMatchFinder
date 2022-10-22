import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:soccer_finder/home/add_place.dart';

import '../models.dart';

class Places extends StatefulWidget {
  const Places({Key? key}) : super(key: key);

  @override
  State<Places> createState() => _PlacesState();
}

class _PlacesState extends State<Places> {
  @override
  Widget build(BuildContext context) {
    final placesQuery = FirebaseFirestore.instance.collection('places').withConverter<Place>(
      fromFirestore: (snapshot, _) => Place.fromJson(snapshot.data()!),
      toFirestore: (place, _) => place.toJson(),
    );

    return Scaffold(
      body: FirestoreListView<Place>(
        query: placesQuery,
        itemBuilder: (context, snapshot) {
          Place place = snapshot.data();
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: place.linkToImage.isNotEmpty ? NetworkImage(place.linkToImage) : null,
                ),
                title: Text(place.name),
                subtitle: Text(place.adress),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  // Todo: open place read view
                },
              ),
              const Divider(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                const AddPlace()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
