import 'dart:convert';
import 'dart:io';
import 'package:demo/Home/fields.dart';
import 'package:demo/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _formData = FormData();
  final ImagePicker _picker = ImagePicker();
  final ImagePicker _spicker = ImagePicker();
  File? _userPhoto;
  File? _signPhoto;
  bool knowsFirstAid = false;
  bool knowsCPR = false;
  List<String> genderOptions = ['Male', 'Female', 'Other'];
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

  String? _selectedGender;
  String? _selectedDistrict;

  Future<void> _saveFormData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_formData.familyMembers != _formData.adults! + _formData.children!) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Number of adults and children must add up to the number of family members'),
          ),
        );
        return;
      }
    }

    if (_userPhoto == null || _signPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload Photos'),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/unsync_data.json');

      List<Map<String, dynamic>> formDataList = [];

      if (await file.exists()) {
        final jsonData = await file.readAsString();
        print("jsonData $jsonData");
        if (jsonData != "") {
          final List<dynamic> decodedData = json.decode(jsonData);
          formDataList =
              decodedData.map((data) => data as Map<String, dynamic>).toList();
        }
      }

      _formData.hasCprTraining = knowsCPR;
      _formData.knowsFirstAid = knowsFirstAid;

      final formDataMap = _formData.toJson();
      print("_formData.knowsFirstAid: ${_formData.knowsFirstAid}");

      if (formDataMap != null) {
        formDataList.add(formDataMap);

        final jsonData = json.encode(formDataList);
        await file.writeAsString(jsonData);
      } else {
        print("Error: _formData.toJson() returned null");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully!'),
        ),
      );

      _formKey.currentState!.reset();
      setState(() {
        _formData.knowsFirstAid = false;
        _formData.hasCprTraining = false;
        _userPhoto = null;
        _signPhoto = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter proper details!'),
        ),
      );
    }
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
        '${(await getTemporaryDirectory()).path}/${username}_${type}_${timestamp}.$originalExtension';

    final compressedImage = File(compressedImagePath);
    await compressedImage.writeAsBytes(bytes);

    return compressedImage;
  }

  Future<void> _uploadUserPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      final int fileSize = await image.length();

      // Check if file size is greater than 3 MB
      if (fileSize > 3 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size cannot be greater than 3 MB'),
          ),
        );
        return;
      }

      final compressedImage = await _compressImage(image, "profilePic");

      setState(() {
        _userPhoto = compressedImage;
        _formData.userPhotoPath = _userPhoto?.path;
      });
    }
  }

  Future<void> _clickUserPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final compressedImage =
          await _compressImage(File(pickedFile.path), "profilePic");

      setState(() {
        _userPhoto = compressedImage;
        _formData.userPhotoPath = _userPhoto?.path;
      });
    }
  }

  Future<void> _uploadSignPhoto() async {
    final spickedFile = await _spicker.pickImage(source: ImageSource.gallery);

    if (spickedFile != null) {
      final File image = File(spickedFile.path);
      final int fileSize = await image.length();

      if (fileSize > 3 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size cannot be greater than 3 MB'),
          ),
        );
        return;
      }

      final scompressedImage = await _compressImage(image, "signature");

      setState(() {
        _signPhoto = scompressedImage;
        _formData.signaturePath = scompressedImage?.path;
      });
    }
  }

  Future<void> _clickSignPhoto() async {
    final spickedFile = await _spicker.pickImage(source: ImageSource.camera);

    if (spickedFile != null) {
      final scompressedImage =
          await _compressImage(File(spickedFile.path), "signature");

      setState(() {
        _signPhoto = scompressedImage;
        _formData.signaturePath = scompressedImage?.path;
      });
    }
  }

  void _removeUserPhoto() {
    setState(() {
      _userPhoto = null;
    });
  }

  void _removeSignPhoto() {
    setState(() {
      _signPhoto = null;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', "");
    await prefs.setString('email', "");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF35374B),
        title: const Text(
          'Add Details',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.account_circle),
            color: const Color(0xFFFB6BBC4),
            iconColor: Colors.white,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: const Text('Logout'),
                  onTap: () {
                    logout();
                    runApp(Login());
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                      onSaved: (value) => _formData.name = value!,
                    ),
                    TextFormField(
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
                      onSaved: (value) => _formData.email = value!,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.people),
                      ),
                      items: genderOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select gender';
                        }
                        return null;
                      },
                      onSaved: (value) => _formData.gender = value!,
                    ),
                    TextFormField(
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
                      onSaved: (value) => _formData.mobileNo = value!,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Adhar No',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
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
                      onSaved: (value) => _formData.adharNo = value!,
                      keyboardType: TextInputType.number,
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
                      decoration: const InputDecoration(
                        labelText: 'No of Family Members',
                        prefixIcon: Icon(Icons.group),
                      ),
                      keyboardType: TextInputType.number,
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
                      onSaved: (value) =>
                          _formData.familyMembers = int.parse(value!),
                    ),
                    TextFormField(
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
                      onSaved: (value) => _formData.adults = int.parse(value!),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'No of Children',
                        prefixIcon: Icon(Icons.child_care),
                      ),
                      keyboardType: TextInputType.number,
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
                      onSaved: (value) =>
                          _formData.children = int.parse(value!),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9 ,.\-#]+$').hasMatch(value)) {
                          return 'Address can only contain certain symbols';
                        }
                        if (value.length > 250) {
                          return 'Address must be 250 characters or less';
                        }
                        return null;
                      },
                      onSaved: (value) => _formData.address = value!,
                    ),
                    TextFormField(
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
                      onSaved: (value) => _formData.pinCode = value!,
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      decoration: const InputDecoration(
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
                      onSaved: (value) => _formData.district = value!,
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
                          value: _formData.knowsFirstAid,
                          onChanged: (value) {
                            print("CHECK BOX ${value!}");
                            setState(() {
                              _formData.knowsFirstAid = value;
                              knowsFirstAid = value;
                            });
                            print("CHECK BOX ${_formData.knowsFirstAid}");
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.medical_services),
                        const SizedBox(width: 8),
                        const Text('Knows about CPR?'),
                        Checkbox(
                          value: _formData.hasCprTraining,
                          onChanged: (value) {
                            setState(() {
                              _formData.hasCprTraining = value!;
                              knowsCPR = value;
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
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Upload User Photo'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clickUserPhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Click User Photo'),
                    ),
                    if (_userPhoto != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Image.file(_userPhoto!)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _removeUserPhoto,
                          ),
                        ],
                      ),
                    ] else
                      const Text(
                        'Please upload user photo',
                        style: TextStyle(color: Colors.red),
                      ),
                    const Text('Upload Signature',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: _uploadSignPhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Upload User Signature'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clickSignPhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Click User Signature'),
                    ),
                    if (_signPhoto != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Image.file(_signPhoto!)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _removeSignPhoto,
                          ),
                        ],
                      ),
                    ] else
                      const Text(
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
                    'Submit',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
