import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';
import 'package:intl/intl.dart';

class SingleChallange extends StatefulWidget {
  final String challangeID;
  const SingleChallange({Key? key, required this.challangeID}) : super(key: key);

  @override
  State<SingleChallange> createState() => _SingleChallangeState();
}

class _SingleChallangeState extends State<SingleChallange> {
  String? myTeamId;
  var isLoading = false;
  Team? challanger;
  Team? challanged;
  String? place;
  DateTime? time;

  @override
  void initState() {
    print(widget.challangeID);
    getBothTeams();
    super.initState();
  }
  
  Future<void> getBothTeams() async{
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
        .collection('challanges').doc(widget.challangeID).get();

    place = challangeDoc.get('place');
    time = challangeDoc.get('time').toDate();

    final challangerid = challangeDoc.get('challangerID');
    final team1Ref = FirebaseFirestore.instance.collection("teams").doc(challangerid).withConverter<Team>(
      fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
      toFirestore: (team, _) => team.toJson(),
    );
    challanger = await team1Ref.get().then((snapshot) => snapshot.data()!);

    final challangedid = challangeDoc.get('challangedID');
    final team2Ref = FirebaseFirestore.instance.collection("teams").doc(challangedid).withConverter<Team>(
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
      body: !isLoading ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  minRadius: (MediaQuery.of(context).size.width/4) - 8,
                  backgroundColor: Colors.white,
                  backgroundImage: challanger!.linkToPicture.isNotEmpty ? NetworkImage(challanger!.linkToPicture) : null,
                ),
                CircleAvatar(
                  minRadius: (MediaQuery.of(context).size.width/4) - 8,
                  backgroundColor: Colors.white,
                  backgroundImage: challanged!.linkToPicture.isNotEmpty ? NetworkImage(challanged!.linkToPicture) : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Center(child: Text("Herausforderer: ${challanger!.name}")),
                  subtitle: Center(child: Text('Punkte: ${challanger!.points}')),
                ),
                ListTile(
                  title: Center(child: Text("Herausgeforderter: ${challanged!.name}")),
                  subtitle: Center(child: Text('Punkte: ${challanged!.points}')),
                ),
                ListTile(
                  title: Center(child: Text("Ort:")),
                  subtitle: Center(child: Text(place!)),
                ),
                ListTile(
                  title: Center(child: Text("Zeitpunkt:")),
                  subtitle: Center(child: Text(DateFormat('dd.MM.yyyy – kk:mm').format(time!))),
                ),
                if(challanged!.id == myTeamId)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                        foregroundColor: MaterialStateProperty.all(Colors.black),
                        minimumSize:
                        MaterialStateProperty.all(const Size(100, 50))),
                      onPressed: () {  },
                      child: Text('Herausforderung annehmen'),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.grey),
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                            minimumSize:
                            MaterialStateProperty.all(const Size(100, 50))),
                        onPressed: () {  },
                        child: Text('Herausforderung ablehnen'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ) : const Center(child: CircularProgressIndicator()),
    );
  }
}
