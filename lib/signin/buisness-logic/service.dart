import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';

class AuthService {
  String? getSignedInUserID(){
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      return user.uid;
    } else {
      return null;
    }
  }

  Future<bool> signIn({
    required String email,
    required String pw,
  }) async {
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pw);
      return true;
    } catch (e) {
      Logger().e(e);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String pw,
    required String username
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );
      await credential.user?.updateDisplayName(username);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        return false;
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }

  Future<Team?> addNewTeam({
    required String name,
    required String pw,
  }) async {
    try{
      final team = Team(
        name: name,
        pw: pw,
        points: 0,
        linkToPicture: '',
      );

      final teamsRef = FirebaseFirestore.instance.collection('teams').withConverter<Team>(
        fromFirestore: (snapshot, _) => Team.fromJson(snapshot.data()!),
        toFirestore: (team, _) => team.toJson(),
      );

      final one = await teamsRef.add(team);
      team.id = one.id;
      await teamsRef.doc(team.id).set(team);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teamId', team.id!);

      return team;
    } catch (e){
      Logger().e(e);
      return null;
    }
  }

  Future<bool> addUserToTeam({
    required String userId,
    required String teamId,
  }) async {
    try{
      final playersData = {
        "usedID": userId,
      };
      await FirebaseFirestore.instance.collection('teams').doc(teamId).collection('players').add(playersData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('teamId', teamId);
      return true;
    } catch (e) {
      Logger().e(e);
      return true;
    }
  }
}