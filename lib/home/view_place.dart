import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:soccer_finder/models.dart';
import 'package:latlong2/latlong.dart';

class ViewPlace extends StatefulWidget {
  final Place place;
  const ViewPlace({Key? key, required this.place}) : super(key: key);

  @override
  State<ViewPlace> createState() => _ViewPlaceState();
}

class _ViewPlaceState extends State<ViewPlace> {
  bool isTeamInThisPlace = false;

  @override
  void initState() {
    super.initState();
  }

  Future getIfTeamAtPlace() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: FlutterMap(
                options: MapOptions(
                  zoom: 12,
                  center: LatLng(widget.place.lat, widget.place.lon)
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                        Marker(
                          point: LatLng(widget.place.lat, widget.place.lon),
                          width: 20,
                          height: 20,
                          builder: (context) =>
                          const Icon(Icons.place_sharp),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Image.network(
                  widget.place.linkToImage,
                  fit: BoxFit.cover,
                  width: 180.0,
                  height: 180.0,
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Center(child: Text("Name:")),
                  subtitle: Center(child: Text(widget.place.name)),
                ),
                ListTile(
                  title: Center(child: Text("Adresse:")),
                  subtitle: Center(child: Text(widget.place.adress)),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 60.0),
              child: Row(
                children: [
                  const Text("Spielt unser Team auf diesem Platz: "),
                  Checkbox(
                    checkColor: Colors.white,
                    value: isTeamInThisPlace,
                    onChanged: (bool? value) {
                      setState(() {
                        isTeamInThisPlace = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
