import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String mail;
  final String uid;
  final String phone;
  final String username;
  final String photourl;
  final String college;

  const UserModel({
    required this.mail,
    required this.uid,
    required this.phone,
    required this.username,
    required this.photourl,
    required this.college,
  });

  Map<String, dynamic> toJson() => {
        'email': mail,
        'uid': uid,
        'photourl': photourl,
        'username': username,
        'phone': phone,
        'college': college,
      };
  static UserModel fromsnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return UserModel(
      mail: snapshot['email'],
      uid: snapshot['uid'],
      phone: snapshot['phone'],
      username: snapshot['username'],
      photourl: snapshot['photourl'],
      college: snapshot['college'],
    );
  }
}
