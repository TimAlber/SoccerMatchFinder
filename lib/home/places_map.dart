import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soccer_finder/geolocator/geolocator.dart';
import '../models.dart';

class PlacesMap extends StatefulWidget {
  const PlacesMap({Key? key}) : super(key: key);

  @override
  State<PlacesMap> createState() => _PlacesMapState();
}

class _PlacesMapState extends State<PlacesMap> {
  var _isloading = false;
  List<Place>? places;
  List<Marker>? markers;
  Position? devicePosition;
  Timer? timer;

  @override
  void initState() {
    getPlaces();

    timer = Timer.periodic(
        const Duration(seconds: 1),
            (Timer t) => {
          determinePosition().then((position) => {
            setState(() {
              devicePosition = position;
              print(devicePosition);
            }),
          }),
        });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future getPlaces() async {
    setState(() {
      _isloading = true;
    });
    final placesQuery = FirebaseFirestore.instance.collection('places').withConverter<Place>(
      fromFirestore: (snapshot, _) => Place.fromJson(snapshot.data()!),
      toFirestore: (place, _) => place.toJson(),
    );

    places = (await placesQuery.get()).docs.map((e) => e.data()).toList();
    markers = places!.map((e) =>
        Marker(
        point: LatLng(e.lat, e.lon),
        width: 20,
        height: 20,
        builder: (context) =>
        const Icon(Icons.place_sharp),
    )).toList();

    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_isloading){
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      options: MapOptions(
          zoom: 5,
          center: devicePosition != null ? LatLng(devicePosition!.latitude, devicePosition!.longitude) : LatLng(52.5200, 13.4050)
      ),
      children: [
        TileLayer(
          urlTemplate:
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            ...markers!,
            if(devicePosition != null)
              Marker(
                point: LatLng(devicePosition!.latitude, devicePosition!.longitude),
                width: 20,
                height: 20,
                builder: (context) => const Icon(Icons.circle, color: Colors.blue,),
              ),
          ],
        ),
      ],
    );
  }
}
