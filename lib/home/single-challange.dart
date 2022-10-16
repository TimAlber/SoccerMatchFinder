import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/home/chat.dart';
import 'package:soccer_finder/models.dart';
import 'package:intl/intl.dart';

class SingleChallange extends StatefulWidget {
  final String challangeID;
  const SingleChallange({Key? key, required this.challangeID})
      : super(key: key);

  @override
  State<SingleChallange> createState() => _SingleChallangeState();
}

class _SingleChallangeState extends State<SingleChallange> {
  String? status;
  String? myTeamId;
  var isLoading = false;
  Team? challanger;
  Team? challanged;
  String? place;
  DateTime? time;
  String? output;

  @override
  void initState() {
    print(widget.challangeID);
    getBothTeams();
    super.initState();
  }

  Future<void> getBothTeams() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('teamId') != null) {
      if (mounted) {
        setState(() {
          myTeamId = prefs.getString('teamId')!;
          isLoading = true;
        });
      }
    } else {
      print('Error, no team id found');
    }

    final challangeDoc = await FirebaseFirestore.instance
        .collection('challanges')
        .doc(widget.challangeID)
        .get();

    place = challangeDoc.get('place');
    time = challangeDoc.get('time').toDate();
    status = challangeDoc.get('status');
    output = challangeDoc.get('output');

    final challangerid = challangeDoc.get('challangerID');
    final team1Ref = FirebaseFirestore.instance
        .collection("teams")
        .doc(challangerid)
        .withConverter<Team>(
          fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
          toFirestore: (team, _) => team.toJson(),
        );
    challanger = await team1Ref.get().then((snapshot) => snapshot.data()!);

    final challangedid = challangeDoc.get('challangedID');
    final team2Ref = FirebaseFirestore.instance
        .collection("teams")
        .doc(challangedid)
        .withConverter<Team>(
          fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
          toFirestore: (team, _) => team.toJson(),
        );
    challanged = await team2Ref.get().then((snapshot) => snapshot.data()!);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offenes Spiel'),
      ),
      body: !isLoading
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        minRadius: (MediaQuery.of(context).size.width / 4) - 8,
                        backgroundColor: Colors.white,
                        backgroundImage: challanger!.linkToPicture.isNotEmpty
                            ? NetworkImage(challanger!.linkToPicture)
                            : null,
                      ),
                      CircleAvatar(
                        minRadius: (MediaQuery.of(context).size.width / 4) - 8,
                        backgroundColor: Colors.white,
                        backgroundImage: challanged!.linkToPicture.isNotEmpty
                            ? NetworkImage(challanged!.linkToPicture)
                            : null,
                      ),
                    ],
                  ),
                ),
                getStatusIcon(),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: Center(
                            child: Text("Herausforderer: ${challanger!.name}")),
                        subtitle: Center(
                            child: Text('Punkte: ${challanger!.points}')),
                      ),
                      ListTile(
                        title: Center(
                            child:
                                Text("Herausgeforderter: ${challanged!.name}")),
                        subtitle: Center(
                            child: Text('Punkte: ${challanged!.points}')),
                      ),
                      ListTile(
                        title: Center(child: Text("Ort:")),
                        subtitle: Center(child: Text(place!)),
                      ),
                      ListTile(
                        title: Center(child: Text("Zeitpunkt:")),
                        subtitle: Center(
                            child: Text(DateFormat('dd.MM.yyyy – kk:mm')
                                .format(time!))),
                      ),
                      if (challanged!.id == myTeamId && status == 'PENDING')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Center(
                              child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.grey),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(100, 50))),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('challanges')
                                      .doc(widget.challangeID)
                                      .update({'status': 'ACCEPTED'});
                                  setState(() {
                                    status = 'ACCEPTED';
                                  });
                                },
                                child: Text('Herausforderung annehmen'),
                              ),
                            ),
                            Center(
                              child: TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.grey),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(100, 50))),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('challanges')
                                      .doc(widget.challangeID)
                                      .update({'status': 'DONE'});
                                  setState(() {
                                    status = 'DONE';
                                  });
                                },
                                child: Text('Herausforderung ablehnen'),
                              ),
                            ),
                          ],
                        ),
                      if (status == 'ACCEPTED')
                        Center(
                          child: Column(
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.grey),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(100, 50))),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => _addOutcomeDialog(context, challanger: challanger!, challanged: challanged!),
                                  );
                                },
                                child: Text('Ausgang eintragen'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: TextButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                      MaterialStateProperty.all(Colors.grey),
                                      foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(100, 50))),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Chat(challangeId: widget.challangeID,)),
                                    );
                                  },
                                  child: Text('Chat öffnen'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if(status == 'DONE' && output!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Center(
                            child: Text(
                              'Ausgang: ${output!}',
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            )
                          ),
                        ),
                      if(status == 'DONE' && output!.isEmpty)
                        const Center(
                            child: Text(
                                'Spiel wurde abgesagt'
                            )
                        ),
                    ],
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget getStatusIcon(){
    switch(status) {
      case "PENDING": {
        return const Icon(Icons.open_in_new);
      }
      case "ACCEPTED": {
        return const Icon(Icons.done);
      }
      case "DONE": {
        return const Icon(Icons.done_all);
      }
      default: {
        return const Icon(Icons.error);
      }
    }
  }

  Widget _addOutcomeDialog(BuildContext context,
      {required Team challanger, required Team challanged}) {
    final outcomeTextFieldController1 = TextEditingController();
    final outcomeTextFieldController2 = TextEditingController();
    return AlertDialog(
      title: const Text('Ausgang eintragen:'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextField(
            keyboardType: TextInputType.number,
            controller: outcomeTextFieldController1,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Tore die ${challanger.name} gemacht hat',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: outcomeTextFieldController2,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Tore die ${challanged.name} gemacht hat',
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
            final innerOutput = '${outcomeTextFieldController1.text} - ${outcomeTextFieldController2.text}';
            FirebaseFirestore.instance
                .collection('challanges')
                .doc(widget.challangeID)
                .update({'output': innerOutput});
            FirebaseFirestore.instance
                .collection('challanges')
                .doc(widget.challangeID)
                .update({'status': 'DONE'});
            setState(() {
              status = 'DONE';
              output = innerOutput;
            });
            Navigator.of(context).pop();
          },
          child: const Text('Ok'),
        )
      ],
    );
  }
}
