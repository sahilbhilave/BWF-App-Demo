import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'package:demo/Media/input.dart';
import 'package:demo/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeedPage extends StatefulWidget {
  const FeedPage();

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late Future<List<Map<String, dynamic>>> _fetchBlogs;
  late PageController _pageController;
  int _currentPage = 0;
  bool _showMyUploads = false;
  String email = '';

  @override
  void initState() {
    super.initState();
    _fetchBlogs = fetchBlogs();
    _pageController = PageController();
  }

  void fetch() {
    setState(() {
      _fetchBlogs = fetchBlogs();
    });
  }

  Future<List<Map<String, dynamic>>> fetchBlogs() async {
    Completer<List<Map<String, dynamic>>> completer = Completer();
    Timer timeout = Timer(Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.completeError('Timeout');
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
    });

    try {
      final response = await http.get(
        _showMyUploads
            ? Uri.parse('${dotenv.env['FETCH_FEED_DATA']}?email=$email')
            : Uri.parse('${dotenv.env['FETCH_FEED_DATA']}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        completer.complete(jsonData.cast<Map<String, dynamic>>());
      } else if (response.statusCode == 404) {
        completer.completeError('No data available');
      } else {
        completer.completeError('Failed to load data');
      }
    } catch (e) {
      completer.completeError(e.toString());
    } finally {
      timeout.cancel();
    }

    return completer.future;
  }

  Future<void> deleteFeed(String id) async {
    print('$id');
    Completer<void> completer = Completer();
    Timer timeout = Timer(Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.completeError('Timeout');
      }
    });

    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this feed?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final response = await http.post(
          Uri.parse('${dotenv.env['DELETE_FEED_DATA']}'),
          body: {'id': id},
        );

        print(id);

        if (response.statusCode == 200) {
          completer.complete();
          setState(() {
            _fetchBlogs = fetchBlogs();
          });
        } else {
          completer.completeError('Failed to delete data');
        }
      } catch (e) {
        completer.completeError('Failed to delete data: $e');
      } finally {
        timeout.cancel();
      }
    } else {
      completer.completeError('Deletion cancelled');
    }

    return completer.future;
  }

  void toggleUploads() {
    setState(() {
      _showMyUploads = !_showMyUploads;
      _fetchBlogs = fetchBlogs();
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', "");
    await prefs.setString('username', "");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffB6BBC4),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Feed'),
        backgroundColor: Color(0xFF35374B),
        actions: [
          ElevatedButton(
            onPressed: fetch,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xfff161A30)),
            ),
            child: Text(
              'Refresh',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          ElevatedButton(
            onPressed: toggleUploads,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xfff161A30)),
            ),
            child: Text(
              _showMyUploads ? 'All Uploads' : 'My Uploads',
              style: TextStyle(color: Colors.white),
            ),
          ),
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
      body: FutureBuilder(
        future: _fetchBlogs,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          } else {
            List<Map<String, dynamic>> jsonData = snapshot.data ?? [];
            if (jsonData.isEmpty) {
              return Center(child: Text('No data available'));
            }
            return Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: jsonData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return buildCard(context, jsonData[index]);
                  },
                ),
                if (_currentPage > 0)
                  Positioned(
                    left: 30,
                    top: MediaQuery.of(context).padding.top + 30,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff161A30).withOpacity(0.5),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (_currentPage < jsonData.length - 1)
                  Positioned(
                    right: 30,
                    top: MediaQuery.of(context).padding.top + 30,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff161A30).withOpacity(0.5),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormPage()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Color(0xff31304D),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget buildCard(BuildContext context, Map<String, dynamic> data) {
    DateTime createdAt = DateTime.parse(data['date']);
    String formattedDate = DateFormat('d MMMM y').format(createdAt);

    bool isCurrentUser = data['data_given_by'] == email;

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCurrentUser)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red, // Background color
                    ),
                    child: IconButton(
                      onPressed: () {
                        deleteFeed(data['id'].toString());
                      },
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Colors.white, // Icon color
                      ),
                    ),
                  ),
                ],
              ),
            if (!isCurrentUser) SizedBox(height: 50),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullScreenImagePage(imageUrl: data['image']),
                  ),
                );
              },
              child: Image.network(
                data['image'] ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['title'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              'By: ${data['data_given_by']}',
              style: const TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 0),
            Text(
              'Created At: $formattedDate',
              style: const TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              data['description'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
