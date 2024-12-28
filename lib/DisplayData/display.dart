import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:demo/login.dart';
import 'package:demo/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editform.dart';
import 'package:http/http.dart' as http;

class DataDisplay extends StatefulWidget {
  @override
  _FormDataDisplayPageState createState() => _FormDataDisplayPageState();
}

class _FormDataDisplayPageState extends State<DataDisplay> {
  List<Map<String, dynamic>> _unsyncedData = [];
  List<Map<String, dynamic>> _unsyncedDataCopy = [];
  List<Map<String, dynamic>> _syncedData = [];
  String unsyncFilePath = "unsync_data.json";
  bool _isSyncing = false;
  bool _isFetching = false;
  String uploads = 'Loading';
  String status = '';
  bool duplicate = false;
  Color status_color = Colors.green;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> uploadDataWithImage(Map<String, dynamic> jsonData,
      String profileImgPath, String signatureImgPath) async {
    setState(() {
      status = 'Uploading..';
      status_color = Colors.black;
    });
    final profileImgName = profileImgPath.split('/').last;
    final signatureImgName = signatureImgPath.split('/').last;

    File profileimageFile = File(profileImgPath);
    File signatureimageFile = File(signatureImgPath);

    List<int> imageBytes = await profileimageFile.readAsBytes();
    List<int> simageBytes = await signatureimageFile.readAsBytes();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    var request =
        http.MultipartRequest('POST', Uri.parse('${dotenv.env['SAVE_DATA']}'));

    request.fields['jsonData'] = json.encode(jsonData);
    request.fields['username'] = username ?? '';
    request.fields['profileImgName'] = profileImgName;
    request.fields['signatureImgName'] = signatureImgName;
    request.files.add(await http.MultipartFile.fromPath(
      'profileImage',
      profileImgPath,
      filename: profileImgName,
    ));
    request.files.add(await http.MultipartFile.fromPath(
      'signatureImage',
      signatureImgPath,
      filename: signatureImgName,
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    var responseBody = json.decode(response.body);

    if (responseBody['status'] == 'success') {
      print("Upload successful: ${responseBody['message']}");
      setState(() {
        status = responseBody['message'];
        if (status.contains("already")) {
          status_color = Colors.red;
          duplicate = true;
        } else {
          status_color = Colors.green;
          duplicate = false;
        }
      });
    } else {
      print("Upload failed: ${responseBody['message']}");
      setState(() {
        status = responseBody['message'];
      });
      throw Exception('Error uploading data');
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    int totalUploadsRemaining = 1;
    int total = _unsyncedData.length;
    bool uploadFailed = false;
    List<Map<String, dynamic>> unsyncedDataCopy = List.from(_unsyncedData);
    for (var entry in unsyncedDataCopy) {
      try {
        await uploadDataWithImage(
            entry, entry['userPhoto'], entry['signature']);
        setState(() {
          uploads = '$totalUploadsRemaining / $total';
        });
        totalUploadsRemaining++;
        if (!duplicate) {
          _unsyncedData.remove(entry);
          await _saveFormData(_unsyncedData, unsyncFilePath);
        }
        await Future.delayed(const Duration(milliseconds: 500));

        print('Total uploads remaining: $totalUploadsRemaining / $total');
      } catch (e) {
        print('Error uploading data: $e');
        setState(() {
          _isSyncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading data please try again later!'),
            duration: const Duration(seconds: 5),
          ),
        );
        uploadFailed = true;
        break;
      }
    }

    if (uploadFailed) {
      return;
    }

    setState(() {
      _isSyncing = false;
    });

    if (!uploadFailed) {
      _loadData();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => Navigation()),
      // );
    }
  }

  Future<void> _loadData() async {
    try {
      final unsyncDirectory = await getApplicationDocumentsDirectory();
      final unsyncFile = File('${unsyncDirectory.path}/$unsyncFilePath');

      if (await unsyncFile.exists()) {
        final unsyncJsonData = await unsyncFile.readAsString();
        setState(() {
          _unsyncedData =
              List<Map<String, dynamic>>.from(json.decode(unsyncJsonData));
        });
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');
      final url =
          Uri.parse('${dotenv.env['GET_SYNC_DATA']}?username=$username');

      final response = await http.get(url);
      print(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _syncedData = List<Map<String, dynamic>>.from(jsonData);
        });
      } else {
        print(
            'Failed to retrieve synchronized data. Error code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to retrieve synchronized data. Error code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isFetching = true;
    });

    Timer(Duration(seconds: 8), () {
      if (_isFetching) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Fetching is taking longer than expected. Please try again later.'),
          ),
        );
      }
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');
      final url =
          Uri.parse('${dotenv.env['GET_SYNC_DATA']}?username=$username');

      final response = await http.get(url);
      print(response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        await saveDataToFile(jsonData);
        print('Synchronized data retrieved and saved to file.');
      } else {
        print(
            'Failed to retrieve synchronized data. Error code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to retrieve synchronized data. Error code: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }

    setState(() {
      _isFetching = false;
    });
  }

  Future<void> saveDataToFile(dynamic jsonData) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/sync_data.json');
      final encodedData = jsonEncode(jsonData);
      await file.writeAsString(encodedData);
      print('Data saved to file: ${file.path}');
      _loadData();
    } catch (e) {
      print('Error saving data to file: $e');
    }
  }

  Future<void> _saveFormData(
      List<Map<String, dynamic>> dataList, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      final jsonData = json.encode(dataList);
      await file.writeAsString(jsonData);
    } catch (e) {
      print('Error saving form data: $e');
    }
  }

  void _editFormData(
      int index, List<Map<String, dynamic>> dataList, String fileName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFormPage(
          initialData: dataList[index],
          onSave: (updatedData) {
            setState(() {
              dataList[index] = updatedData;
              _saveFormData(dataList, fileName);
            });
          },
        ),
      ),
    );
  }

  Future<void> _deleteFormData(
      int index, List<Map<String, dynamic>> dataList, String fileName) async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this entry?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      setState(() {
        dataList.removeAt(index);
        _saveFormData(dataList, unsyncFilePath);
      });
    }
  }

  void _showDetails(Map<String, dynamic> formData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(Icons.person, 'Name', formData['name']),
                        _buildDetailRow(
                            Icons.email, 'Email', formData['email']),
                        _buildDetailRow(
                            Icons.people, 'Gender', formData['gender']),
                        _buildDetailRow(
                            Icons.phone, 'Mobile No', formData['mobileNo']),
                        _buildDetailRow(
                            Icons.credit_card, 'Adhar No', formData['adharNo']),
                        _buildDetailRow(Icons.group, 'Family Members',
                            formData['familyMembers'].toString()),
                        _buildDetailRow(Icons.person, 'Adults',
                            formData['adults'].toString()),
                        _buildDetailRow(Icons.child_care, 'Children',
                            formData['children'].toString()),
                        _buildDetailRow(
                            Icons.location_on, 'Address', formData['address']),
                        _buildDetailRow(Icons.location_pin, 'Pin Code',
                            formData['pinCode']),
                        _buildDetailRow(Icons.location_pin, 'District',
                            formData['district']),
                        _buildDetailRow(Icons.healing, 'Knows First Aid',
                            formData['knowsFirstAid'].toString()),
                        _buildDetailRow(
                            Icons.medical_services,
                            'Has CPR Training',
                            formData['hasCprTraining'].toString()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', "");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0),
          const SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label + ': ',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                value,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF35374B),
        title: const Text(
          'Form Data',
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
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _syncData,
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xff085F63),
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Sync Data',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: _fetchData,
                  style: ElevatedButton.styleFrom(
                    primary: const Color(0xff363062),
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Fetch Data',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 0,
            ),
            TabBar(
              tabs: [
                Tab(text: 'Unsynchronised Data (${_unsyncedData.length})'),
                Tab(text: 'Synchronised Data (${_syncedData.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _isSyncing
                      ? Column(
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            const CircularProgressIndicator(),
                            Text('Uploading : $uploads '),
                            Text(
                              '\n $status',
                              style: TextStyle(
                                  color: status_color,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        )
                      : (_unsyncedData.isEmpty
                          ? const Center(
                              child: Text('No unsynchronised data available'))
                          : ListView.builder(
                              itemCount: _unsyncedData.length,
                              itemBuilder: (context, index) {
                                final formData = _unsyncedData[index];
                                return Card(
                                  elevation: 3.0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  child: ListTile(
                                    title: Text(formData['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(formData['email']),
                                    onTap: () => _showDetails(formData),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editFormData(
                                              index,
                                              _unsyncedData,
                                              'unsync_data.json'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteFormData(
                                              index,
                                              _unsyncedData,
                                              'unsync_data.json'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )),
                  _isFetching
                      ? Column(
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            const CircularProgressIndicator(),
                            Text('Fetching data..'),
                          ],
                        )
                      : _syncedData.isEmpty
                          ? const Center(
                              child: Text(
                                  'No synchronised data available or \nno internet available to fetch the data!'))
                          : ListView.builder(
                              itemCount: _syncedData.length,
                              itemBuilder: (context, index) {
                                final formData = _syncedData[index];
                                return Card(
                                  elevation: 3.0,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  child: ListTile(
                                    title: Text(formData['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(formData['email']),
                                    onTap: () => _showDetails(formData),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
