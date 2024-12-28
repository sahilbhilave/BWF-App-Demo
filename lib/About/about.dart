import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AboutPage(),
    );
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF35374B),
        title: Text(
          'About The Project',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSection(
              icon: Icons.assignment,
              title: 'Objective Of The Project',
              text:
                  'To make the community aware of the importance of First Aid and make First Aid Kits available to general communities.',
            ),
            _buildSection(
              icon: Icons.done_all,
              title: 'Outcome Of The Project',
              text:
                  'Enhance familiarity with First Aid and First Aid kits.\nReduction in the number of serious patients.',
            ),
            _buildSection(
              icon: Icons.local_hospital,
              title: 'Need For The Project',
              text:
                  'It is important to conduct awareness sessions in remote and rural regions as First Aid kits are crucial in emergencies, reducing the risk of minor injuries worsening.\nFirst aid training also boosts people\'s confidence to assist in accidents or injuries, helping alleviate or stabilize the situation.\nAvailability of Quality First Aid kits and awareness regarding ‘First Aid’ will certainly help beneficiaries save themselves from irreversible damage in emergency situations and before reaching healthcare facilities.',
            ),
            _buildSection(
              icon: Icons.people,
              title: 'Target Population',
              text:
                  'Needy households in remote regions where access to health facilities is limited or not easily available.',
            ),
            _buildSection(
              icon: Icons.assignment_turned_in,
              title: 'Solution To Address\n The Issues?',
              text:
                  'Availability of Quality First Aid Kits and awareness regarding First Aid would help reduce damage in Emergency situations like wounds, trauma, or burns.',
            ),
            _buildSection(
              icon: Icons.compare_arrows,
              title: 'How Does It Differ From\nOther Programs?',
              text:
                  'Here, First Aid kits will be distributed directly to households rather than to communities. It will involve one-on-one interaction with every household, and training will be given to the women of the family.',
            ),
            _buildSection(
              icon: Icons.lightbulb_outline,
              title: 'Why Is This Project\nInnovative?',
              text:
                  'The project aims to make citizens capable of handling emergency situations to a certain extent before reaching out to healthcare facilities by providing them with awareness regarding First Aid and First Aid kits. Especially, women will be trained regarding the use of the kit so that instead of being worried, she can deliver primary first aid care to the affected family member.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required IconData icon, required String title, required String text}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Color(0XFF161A30), size: 30),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF31304D),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: RichText(
              text: TextSpan(
                children: [
                  for (var line in text.split('\n'))
                    WidgetSpan(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        dense: true,
                        leading: Icon(Icons.arrow_right),
                        title: Text(
                          line,
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
