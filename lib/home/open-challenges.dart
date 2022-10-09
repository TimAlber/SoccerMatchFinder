import 'package:flutter/material.dart';

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
          title: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.favorite)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            //MyHomePage(),
            //FavoritePage(),
          ],
        ),
      ),
    );
  }
}
