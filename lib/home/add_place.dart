import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:soccer_finder/signin/buisness-logic/service.dart';

class AddPlace extends StatefulWidget {
  const AddPlace({Key? key}) : super(key: key);

  @override
  State<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  final nameTextController = TextEditingController();
  final adressTextController = TextEditingController();
  final MapController mapController = new MapController();
  XFile? picture;
  Location? location;
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Füge einen Platz hinzu'),
      ),
      body: !isLoading
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        zoom: 12,
                        center: location != null
                            ? LatLng(location!.latitude, location!.longitude)
                            : LatLng(52.518611, 13.408333),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            if (location != null)
                              Marker(
                                point: LatLng(
                                    location!.latitude, location!.longitude),
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
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: nameTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Name des Platzes',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      controller: adressTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Adresse des Platzes',
                      ),
                      onSubmitted: (value) async {
                        try {
                          List<Location> locations =
                              await locationFromAddress(value);
                          if (locations.isNotEmpty) {
                            setState(() {
                              location = locations.first;
                              mapController.move(
                                  LatLng(
                                      location!.latitude, location!.longitude),
                                  12);
                            });
                          } else {
                            location = null;
                            showErrorAlert(
                                context,
                                "Ich kann diese Adresse nicht finden.",
                                Text("Probiere mal eine bessere Adresse"));
                          }
                        } catch (e) {
                          location = null;
                          showErrorAlert(
                              context,
                              "Ich kann diese Adresse nicht finden.",
                              Text("Probiere mal eine bessere Adresse"));
                        }
                      },
                    ),
                  ),
                  if (picture != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipOval(
                        child: Image.file(
                          File(picture!.path),
                          fit: BoxFit.cover,
                          width: 180.0,
                          height: 180.0,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.grey),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                            minimumSize:
                                MaterialStateProperty.all(const Size(100, 50))),
                        onPressed: () {
                          showModalSheet();
                        },
                        child: picture == null
                            ? Text('Platz Bild hinzufügen')
                            : Text('Platz Bild ändern')),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.black),
                          minimumSize:
                              MaterialStateProperty.all(const Size(100, 50))),
                      onPressed: () {
                        if (nameTextController.text.isEmpty ||
                            adressTextController.text.isEmpty ||
                            picture == null ||
                            location == null) {
                          showErrorAlert(
                              context,
                              "Bitte fülle alles aus und füge ein Bild hinzu.",
                              Text(
                                  "Um den Platz hinzuzufügen brauchen wir einen Namen, eine Adresse die wir finden konnten und ein Bild."));
                          return;
                        }
                        setState(() {
                          isLoading = true;
                        });
                        AuthService()
                            .addNewPlace(
                                name: nameTextController.text,
                                adress: adressTextController.text,
                                placePicture: picture!,
                                lat: location!.latitude,
                                lon: location!.longitude)
                            .then((value) => {
                                  if(mounted){
                                    setState(() {
                                      isLoading = false;
                                      Navigator.pop(context);
                                    }),
                                  }
                                });
                      },
                      child: Text('Platz Hinzufügen'),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void showModalSheet() {
    showModalBottomSheet<void>(
      elevation: 10,
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Platzbild mit Kamera machen'),
              onTap: () {
                final ImagePicker _picker = ImagePicker();
                _picker.pickImage(source: ImageSource.camera).then((value) => {
                      setState(() {
                        picture = value;
                        Navigator.of(context).pop();
                      }),
                    });
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Platzbild aus Gallery wählen'),
              onTap: () {
                final ImagePicker _picker = ImagePicker();
                _picker.pickImage(source: ImageSource.gallery).then((value) => {
                      setState(() {
                        picture = value;
                        Navigator.of(context).pop();
                      }),
                    });
              },
            )
          ],
        );
      },
    );
  }

  void showErrorAlert(BuildContext context, String text, Widget body) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(text), content: body));
  }
}
