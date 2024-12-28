import 'dart:convert';
import 'dart:io';

import 'package:demo/Home/fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditFormPage extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSave;

  EditFormPage({required this.initialData, required this.onSave});

  @override
  _EditFormPageState createState() => _EditFormPageState();
}

class _EditFormPageState extends State<EditFormPage> {
  late Map<String, dynamic> _formData;
  final ImagePicker _picker = ImagePicker();
  File? _userPhoto;
  File? _signPhoto;
  final _formKey = GlobalKey<FormState>();
  List<String> districtOptions = [
    'Anantnag',
    'Bandipora',
    'Baramulla',
    'Budgam',
    'Doda',
    'Ganderbal',
    'Jammu',
    'Kathua',
    'Kishtwar',
    'Kulgam',
    'Kupwara',
    'Poonch',
    'Pulwama',
    'Rajouri',
    'Ramban',
    'Reasi',
    'Samba',
    'Shopian',
    'Srinagar',
    'Udhampur'
  ];
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData;
    _initializeImages();
  }

  void _initializeImages() async {
    print(_formData['userPhoto']);
    if (_formData.containsKey('userPhoto') && _formData['userPhoto'] != null) {
      setState(() {
        _userPhoto = File(_formData['userPhoto']);
      });
    }

    if (_formData.containsKey('signature') && _formData['signature'] != null) {
      setState(() {
        _signPhoto = File(_formData['signature']);
      });
    }
  }

  void _saveFormData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_formData['familyMembers'] !=
          _formData['adults']! + _formData['children']!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Number of adults and children must add up to the number of family members'),
          ),
        );
        return;
      }

      String jsonData = jsonEncode(_formData);

      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/unsync_data.json';

      File file = File(filePath);
      await file.writeAsString(jsonData);

      widget.onSave(_formData);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Form Data'),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Person Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextFormField(
                        initialValue: _formData['name'],
                        onChanged: (value) {
                          setState(() {
                            _formData['name'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (!RegExp(r'^[a-zA-Z\s]*$').hasMatch(value)) {
                            return 'Name should only contain letters and blank spaces';
                          }
                          if (value.length > 50) {
                            return 'Name must be 50 characters or less';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['email'],
                        onChanged: (value) {
                          setState(() {
                            _formData['email'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          if (value.length > 250) {
                            return 'Email must be 250 characters or less';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['gender'],
                        onChanged: (value) {
                          setState(() {
                            _formData['gender'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.people),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select gender';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['mobileNo'],
                        onChanged: (value) {
                          setState(() {
                            _formData['mobileNo'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Mobile No',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (value.contains(RegExp(r'[^\d]')) ||
                              value.length != 10) {
                            return 'Mobile number must contain only 10 digits';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['adharNo'],
                        onChanged: (value) {
                          setState(() {
                            _formData['adharNo'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Adhar No',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Aadhar number';
                          }
                          if (value.contains(RegExp(r'[^\d]')) ||
                              value.length != 12) {
                            return 'Adhar number must contain only 12 digits';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Household Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextFormField(
                        initialValue: _formData['familyMembers']?.toString(),
                        onChanged: (value) {
                          setState(() {
                            _formData['familyMembers'] =
                                int.tryParse(value) ?? 0;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'No of Family Members',
                          prefixIcon: Icon(Icons.group),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of family members';
                          }
                          if (value.contains(RegExp(r'[^\d]'))) {
                            return 'Only numbers are allowed';
                          }
                          if (value.length > 3) {
                            return 'Input smaller number';
                          }
                        },
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        initialValue: _formData['adults']?.toString(),
                        onChanged: (value) {
                          setState(() {
                            _formData['adults'] = int.tryParse(value) ?? 0;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'No of Adults',
                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of adults';
                          }
                          if (value.contains(RegExp(r'[^\d]'))) {
                            return 'Only numbers are allowed';
                          }
                          if (value.length > 3) {
                            return 'Input smaller number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['children']?.toString(),
                        onChanged: (value) {
                          setState(() {
                            _formData['children'] = int.tryParse(value) ?? 0;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'No of Children',
                          prefixIcon: Icon(Icons.child_care),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of children';
                          }
                          if (value.contains(RegExp(r'[^\d]'))) {
                            return 'Only numbers are allowed';
                          }
                          if (value.length > 3) {
                            return 'Input smaller number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        initialValue: _formData['address'],
                        onChanged: (value) {
                          setState(() {
                            _formData['address'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9 ,.\-#]+$')
                              .hasMatch(value)) {
                            return 'Address can only contain certain symbols';
                          }
                          if (value.length > 250) {
                            return 'Address must be 250 characters or less';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData['pinCode'],
                        onChanged: (value) {
                          setState(() {
                            _formData['pinCode'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Pin Code',
                          prefixIcon: Icon(Icons.location_pin),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your pin code';
                          }
                          if (value.contains(RegExp(r'[^\d]'))) {
                            return 'Only numbers are allowed';
                          }
                          if (value.length != 6) {
                            return 'Pincode must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _formData['district'],
                        decoration: InputDecoration(
                          labelText: 'District',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        items: districtOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedDistrict = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select district';
                          }
                          return null;
                        },
                        onSaved: (value) => _formData['district'] = value!,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Other Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.healing),
                          const SizedBox(width: 8),
                          const Text('Knows First Aid?'),
                          Checkbox(
                            value: _formData['knowsFirstAid'] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _formData['knowsFirstAid'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.medical_services),
                          const SizedBox(width: 8),
                          const Text('Has CPR Training?'),
                          Checkbox(
                            value: _formData['hasCprTraining'] ?? false,
                            onChanged: (value) {
                              setState(() {
                                _formData['hasCprTraining'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Upload Photos',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: _uploadUserPhoto,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Upload User Photo'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _clickUserPhoto,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Click User Photo'),
                      ),
                      if (_userPhoto != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: Image.file(_userPhoto!)),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: _removeUserPhoto,
                            ),
                          ],
                        ),
                      ] else
                        Text(
                          'Please upload user photo',
                          style: TextStyle(color: Colors.red),
                        ),
                      const Text('Upload Signature',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: _uploadSignPhoto,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Upload User Signature'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _clickSignPhoto,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Click User Signature'),
                      ),
                      if (_signPhoto != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: Image.file(_signPhoto!)),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: _removeSignPhoto,
                            ),
                          ],
                        ),
                      ] else
                        Text(
                          'Please upload user signature',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveFormData,
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xff161A30),
                      onPrimary: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Save Data',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<File?> _compressImage(File image, String type) async {
    final List<int> bytes = (await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 80,
    )) as List<int>;

    final String originalExtension = image.path.split('.').last;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String compressedImagePath =
        '${(await getTemporaryDirectory()).path}/${username}_${type}_$timestamp.$originalExtension';

    final compressedImage = File(compressedImagePath);
    await compressedImage.writeAsBytes(bytes);

    return compressedImage;
  }

  Future<void> _uploadUserPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File? compressedImage = await _compressImage(
        File(pickedFile.path),
        "profilePic",
      );

      int fileSizeInBytes = await compressedImage!.length();
      double fileSizeInMb = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMb > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected image exceeds 3 MB limit.'),
          ),
        );
      } else {
        setState(() {
          _userPhoto = compressedImage;
          _formData['userPhoto'] = compressedImage.path;
        });
      }
    }
  }

  Future<void> _clickUserPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final compressedImage =
          await _compressImage(File(pickedFile.path), "profilePic");

      setState(() {
        _userPhoto = compressedImage;
        _formData['userPhoto'] = compressedImage!.path;
      });
    }
  }

  Future<void> _uploadSignPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File? compressedImage = await _compressImage(
        File(pickedFile.path),
        "signature",
      );

      // Check the file size before setting the state
      int fileSizeInBytes = await compressedImage!.length();
      double fileSizeInMb = fileSizeInBytes / (1024 * 1024);
      if (fileSizeInMb > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected image exceeds 3 MB limit.'),
          ),
        );
      } else {
        setState(() {
          _signPhoto = compressedImage;
          _formData['signature'] = compressedImage.path;
        });
      }
    }
  }

  Future<void> _clickSignPhoto() async {
    final spickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (spickedFile != null) {
      final compressedImage =
          await _compressImage(File(spickedFile.path), "signature");

      setState(() {
        _signPhoto = compressedImage;
        _formData['signature'] = compressedImage!.path;
      });
    }
  }

  void _removeUserPhoto() {
    setState(() {
      _userPhoto = null;
      _formData['userPhoto'] = null;
    });
  }

  void _removeSignPhoto() {
    setState(() {
      _signPhoto = null;
      _formData['signature'] = null;
    });
  }
}
