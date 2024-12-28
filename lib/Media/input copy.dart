import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _imageURLController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _userPhoto;
  String image = '';
  bool _isLoading = false;

  Future<File?> _compressImage(File image, String type) async {
    final List<int> bytes = (await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 80,
    )) as List<int>;

    final String originalExtension = image.path.split('.').last;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('email');

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String compressedImagePath =
        '${(await getTemporaryDirectory()).path}/${username}_${timestamp}.$originalExtension';

    final compressedImage = File(compressedImagePath);
    await compressedImage.writeAsBytes(bytes);

    return compressedImage;
  }

  Future<void> uploadDataWithImage() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        String title = _titleController.text;
        String description = _descriptionController.text;
        String imageURL = _imageURLController.text;

        final profileImgName = image.split('/').last;
        File profileimageFile = File(image);
        List<int> imageBytes = await profileimageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? email = prefs.getString('email');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://discreteconsultants.com/api/save_feed_data.php'),
        );

        request.fields['title'] = title;
        request.fields['description'] = description;
        request.fields['imageName'] = profileImgName;
        request.fields['email'] = email ?? '';
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: profileImgName,
          ),
        );

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          print('Data uploaded successfully');
          Navigator.of(context).pop(true);
        } else {
          print('Server error: ${response.body}');
          throw Exception('Failed to upload data: ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
        if (_userPhoto == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please upload image'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('There was a problem $e'),
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadUserPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final compressedImage =
          await _compressImage(File(pickedFile.path), "profilePic");

      setState(() {
        _userPhoto = compressedImage;
        image = _userPhoto?.path ?? '';
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
        image = _userPhoto?.path ?? '';
      });
    }
  }

  void _removeUserPhoto() {
    setState(() {
      _userPhoto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9 ,.\-#]+$').hasMatch(value)) {
                      return 'Title can only contain certain symbols';
                    }
                    if (value.length > 250) {
                      return 'Title must be 250 characters or less';
                    }
                    if (value.length < 5) {
                      return 'Title must be at least 5 characters';
                    }

                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }

                    if (value.length > 50000) {
                      return 'Description must be 50000 characters or less';
                    }
                    if (value.length < 10) {
                      return 'Description must more than 10 characters';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        'Please upload a photo',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: uploadDataWithImage,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xfff35374B),
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
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
