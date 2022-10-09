import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer_finder/models.dart';
import 'package:uuid/uuid.dart';

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
    required String username,
    required XFile? profilePicture,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );
      await credential.user?.updateDisplayName(username);

      if(profilePicture != null){
        File file = File(profilePicture.path);
        final storageRef = FirebaseStorage.instance.ref();
        final newProfilePictureRef = storageRef.child("user/${const Uuid().v1()}.jpg");
        await newProfilePictureRef.putFile(file);
        await credential.user?.updatePhotoURL(await newProfilePictureRef.getDownloadURL());
      }

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
    required XFile? teamPic,
  }) async {
    try{

      String? teamPicUrl;
      if(teamPic != null){
        File file = File(teamPic.path);
        final storageRef = FirebaseStorage.instance.ref();
        final newProfilePictureRef = storageRef.child("teams/${const Uuid().v1()}.jpg");
        await newProfilePictureRef.putFile(file);
        teamPicUrl = await newProfilePictureRef.getDownloadURL();
      }

      final team = Team(
        name: name,
        pw: pw,
        points: 0,
        linkToPicture: teamPicUrl ?? '',
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

  Future<bool> addChallange({
    required String challanger,
    required String challanged,
  }) async {
    try{
      final challangeData = {
        "challangerID": challanger,
        "challangedID": challanged,
        "place" : '',
        "status": 'PENDING',
        "output": '',
      };

      final doc = await FirebaseFirestore.instance.collection('challanges').add(challangeData);
      doc.update({'challangeID': doc.id});
      return true;
    } catch (e){
      Logger().e(e);
      return false;
    }
  }
}