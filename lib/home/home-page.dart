import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/home/challenge-others.dart';
import 'package:soccer_finder/home/old-games.dart';
import 'package:soccer_finder/home/open-challenges.dart';
import 'package:soccer_finder/home/profile.dart';

import '../signin/ui/choose-team.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Widget body = const ChallengeOthers();
  var topic = 'Andere Teams herausfordern';

  @override
  void initState() {
    openChooseTeamIfNeeded();
    super.initState();
  }

  Future<void> openChooseTeamIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getString('teamId') != null){
      print('All Good');
    } else {
      print('Error, no team id found');
      openChooseTeamPage();
    }
  }

  void openChooseTeamPage(){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
          const ChooseTeam()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic),
      ),
      body: body,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Optionen'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Andere Teams herausfordern'),
              onTap: () {
                setState(() {
                  body = const ChallengeOthers();
                  topic = 'Andere Teams herausfordern';
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.playlist_add_check),
              title: const Text('Offene Herausforderungen'),
              onTap: () {
                setState(() {
                  body = const OpenChallenges();
                  topic = 'Offene Herausforderungen';
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.stars_outlined),
              title: const Text('Vergangene Spiele ansehen'),
              onTap: () {
                setState(() {
                  body = const OldGames();
                  topic = 'Vergangene Spiele ansehen';
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil und Team'),
              onTap: () {
                setState(() {
                  body = const Profile();
                  topic = 'Profil und Team';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
