import 'package:flutter/material.dart';
import 'package:soccer_finder/home/challanged_teams.dart';
import 'package:soccer_finder/home/other_challanged_tems.dart';

class OpenChallenges extends StatefulWidget {
  const OpenChallenges({Key? key}) : super(key: key);

  @override
  State<OpenChallenges> createState() => _OpenChallengesState();
}

class _OpenChallengesState extends State<OpenChallenges> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.logout)),
              Tab(icon: Icon(Icons.login)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChallangedTeams(),
            OtherChallangedTeams(),
          ],
        ),
      ),
    );
  }
}
