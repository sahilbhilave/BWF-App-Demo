import 'package:demo/About/about.dart';
import 'package:demo/DisplayData/display.dart';
import 'package:demo/Home/home.dart';
import 'package:demo/Media/feed.dart';
import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // backgroundColor: const Color(0xFF557A46),
      //   // title: const Text(
      //   //   'BWF',
      //   //   style: TextStyle(
      //   //     fontSize: 24.0,
      //   //     color: Color(0xFFF2EE9D),
      //   //   ),
      //   // ),
      //   centerTitle: true,
      //   actions: [
      //     PopupMenuButton(
      //       icon: Icon(Icons.account_circle),
      //       color: const Color(0xFFF2EE9D),
      //       itemBuilder: (BuildContext context) {
      //         return [
      //           PopupMenuItem(
      //             child: Text('Profile'),
      //             onTap: () {
      //               // Navigate to the profile page
      //               // You need to implement the navigation logic here
      //               // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
      //             },
      //           ),
      //           PopupMenuItem(
      //             child: Text('Settings'),
      //             onTap: () {
      //               // Navigate to the settings page
      //               // You need to implement the navigation logic here
      //               // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
      //             },
      //           ),
      //         ];
      //       },
      //     ),
      //   ],
      // ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [DataDisplay(), FormPage(), const FeedPage(), About()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF35374B),
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFF2EE9D),
        unselectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            backgroundColor: const Color(0xFF35374B),
            icon: Icon(Icons.analytics),
            label: 'Collected Data',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF35374B),
            icon: Icon(
              Icons.details,
            ),
            label: 'Add Details',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF35374B),
            icon: Icon(Icons.info),
            label: 'News',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF35374B),
            icon: Icon(Icons.question_mark),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          'Home Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
