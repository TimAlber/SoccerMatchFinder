import 'package:flutter/material.dart';
import 'package:soccer_finder/home/places_list.dart';
import 'package:soccer_finder/home/places_map.dart';

class Places extends StatefulWidget {
  const Places({Key? key}) : super(key: key);

  @override
  State<Places> createState() => _PlacesState();
}

class _PlacesState extends State<Places> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list)),
              Tab(icon: Icon(Icons.map)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PlacesList(),
            PlacesMap(),
          ],
        ),
      ),
    );
  }
}
