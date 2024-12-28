import 'dart:convert';
import 'dart:io';

class FormData {
  String name = '';
  String email = '';
  String gender = '';
  String mobileNo = '';
  String adharNo = '';
  int familyMembers = 0;
  int adults = 0;
  int children = 0;
  String address = '';
  String pinCode = '';
  bool knowsFirstAid = false;
  bool hasCprTraining = false;
  String? userPhotoPath;
  String? signaturePath;
  String district = '';
  String databy = '';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'mobileNo': mobileNo,
      'adharNo': adharNo,
      'familyMembers': familyMembers,
      'adults': adults,
      'children': children,
      'address': address,
      'pinCode': pinCode,
      'knowsFirstAid': knowsFirstAid,
      'hasCprTraining': hasCprTraining,
      'userPhoto': userPhotoPath,
      'signature': signaturePath,
      'by': databy,
      'district': district
    };
  }
}
