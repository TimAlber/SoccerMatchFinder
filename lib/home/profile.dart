import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  User? user;
  Team? myTeam;
  var isloading = false;

  @override
  void initState() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    user = auth.currentUser;
    getMyTeam();
    super.initState();
  }

  Future getMyTeam() async {
    String? myTeamId;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('teamId') != null) {
      if (mounted) {
        setState(() {
          myTeamId = prefs.getString('teamId')!;
          isloading = true;
        });
      }
    } else {
      print('Error, no team id found');
    }

    final teamRef = FirebaseFirestore.instance.collection("teams").doc(myTeamId).withConverter<Team>(
      fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
      toFirestore: (team, _) => team.toJson(),
    );
    myTeam = await teamRef.get().then((snapshot) => snapshot.data()!);
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (myTeam == null || user == null || isloading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const Text(
              'Dein Profil:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            CircleAvatar(
              minRadius: (MediaQuery.of(context).size.width/4) - 8,
              backgroundColor: Colors.white,
              backgroundImage: user!.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            ),
            ListTile(
              title: Center(child: const Text('Username:')),
              subtitle: Center(child: Text(user!.displayName!)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      minimumSize:
                      MaterialStateProperty.all(const Size(100, 50))),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: Text('Logout'),
              ),
            ),
            const Divider(thickness: 12),
            const Text(
              'Dein Team:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            CircleAvatar(
              minRadius: (MediaQuery.of(context).size.width/4) - 8,
              backgroundColor: Colors.white,
              backgroundImage: myTeam!.linkToPicture.isNotEmpty ? NetworkImage(myTeam!.linkToPicture) : null,
            ),
            ListTile(
              title: const Center(child: Text('Team Name:')),
              subtitle: Center(child: Text(myTeam!.name)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    minimumSize:
                    MaterialStateProperty.all(const Size(100, 50))),
                onPressed: (){

                },
                child: Text('Team wechseln'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
