import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';
import 'package:soccer_finder/signin/buisness-logic/service.dart';

class ChallangeThem extends StatefulWidget {
  final Team team;
  final Function callback;
  const ChallangeThem({Key? key, required this.team, required this.callback}) : super(key: key);

  @override
  State<ChallangeThem> createState() => _ChallangeThemState();
}

class _ChallangeThemState extends State<ChallangeThem> {
  var _isloading = false;
  List<Place>? places;
  Place? firstPlace;
  DateTime? selectedDate;
  String? myTeamId;

  @override
  void initState() {
    getPlaces();
    super.initState();
  }

  void getPlaces() async {
    setState(() {
      _isloading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    myTeamId = prefs.getString('teamId')!;

    final placesQuery = FirebaseFirestore.instance.collection('places').withConverter<Place>(
      fromFirestore: (snapshot, _) => Place.fromJson(snapshot.data()!),
      toFirestore: (place, _) => place.toJson(),
    );
    places = (await placesQuery.get()).docs.map((e) => e.data()).toList();
    firstPlace = places!.first;
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Neue Herausforderung"),
      ),
      body: !_isloading ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Text("Bitte wähle einen Platz:", style: TextStyle(fontSize: 25),),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Container(
                width: 270.0,
                child: DropdownButton<Place>(
                  isExpanded: true,
                  value: firstPlace,
                  icon: const Icon(Icons.sports_soccer),
                  onChanged: (Place? value) {
                    setState(() {
                      firstPlace = value!;
                    });
                  },
                  items: places!.map<DropdownMenuItem<Place>>((Place value) {
                    return DropdownMenuItem<Place>(
                      value: value,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(value.linkToImage),
                        ),
                        title: Text(value.name),
                        subtitle: Text(value.adress),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Text("Bitte wähle einen Zeitpunkt:", style: TextStyle(fontSize: 25),),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    minimumSize: MaterialStateProperty.all(const Size(100, 50))),
                onPressed: () async {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime(2050),
                      onConfirm: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      locale: LocaleType.de);
                },
                child: Text('Wähle ein Termin'),
              ),
            ),
            if(selectedDate != null)
            Text(DateFormat('dd.MM.yyyy – kk:mm').format(selectedDate!), style: TextStyle(fontSize: 25),),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    minimumSize: MaterialStateProperty.all(const Size(100, 50))),
                onPressed: () async {
                  if (selectedDate == null || firstPlace == null) {
                    showErrorAlert(context, "Bitte wähle einen Platz und einen Zeitpunkt fest.",SizedBox.shrink());
                    return;
                  }
                  setState(() {
                    _isloading = true;
                  });
                  AuthService().addChallange(
                    challanger: myTeamId!,
                    challanged: widget.team.id!,
                    time: selectedDate!,
                    place: firstPlace!.id!,
                  );
                  widget.callback();
                  setState(() {
                    _isloading = false;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            )
          ],
        ),
      ) : const Center(child: CircularProgressIndicator()),
    );
  }

  void showErrorAlert(BuildContext context, String text, Widget body) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(text), content: body));
  }
}
