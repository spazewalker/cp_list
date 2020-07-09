import 'package:flutter/material.dart';
import 'data.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


launch(String url) async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
}
void main() => runApp(Home());

class Home extends StatefulWidget {
  Home({Key key, this.title, this.analytics, this.observer}) : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  _HomeState createState() => _HomeState(analytics, observer);
}

class _HomeState extends State<Home> {
  // Analytics
  _HomeState(this.analytics, this.observer);

  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;

  Future<void> _logAppUsage() async {
    await analytics.logEvent(
      name: 'User Logged',
      parameters: <String, dynamic>{
        'Message': 'User open the app',
      },
    );
  }
  
  Future<void> _logAppPage() async {
    await analytics.logEvent(
      name: 'Page',
      parameters: <String, dynamic>{
        'pageId': _selectedIndex,
      },
    );
  }

  // Widgets
  Future<Contests> con = DataLoader().getFuture();
  Contests data;
  int _selectedIndex = 1;

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getData(Future<Contests> c) {
    c.then(_onValue).catchError(_onError);
  }

  void _onValue(Contests tmp) {
    data = tmp;
    onItemTapped(_selectedIndex);
  }

  void _onError(e) {
    print(e);
  }

  // Notifications
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        String url = message['data']['link'];
        print(url);
        launch(url);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        String url = message['data']['link'];
        print(url);
        launch(url);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        String url = message['data']['link'];
        print(url);
        launch(url);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  Widget build(BuildContext context) {
    getData(con);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: Center(child: Icon(Icons.code, color: Colors.black)),
          title: Text("CP LIST"),
          backgroundColor: Colors.black54,
        ),
        body: buildPage(data, _selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.remove_red_eye),
              title: Text('Upcoming'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_arrow),
              title: Text('Live'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_cafe),
              title: Text('About'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: onItemTapped,
        ),
      ),
    );
  }
}

Widget buildPage(Contests contests, int pageId) {
  if (pageId == 0) return upcomingPage(contests);
  if (pageId == 1) return livePage(contests);
  if (pageId == 2)
    return aboutPage();
  else
    return Container(
      child: Center(child: Text("Some Error Occured")),
    );
}

Widget upcomingPage(Contests contests) {
  if (contests != null) {
    return Scrollbar(
      child: new ListView.builder(
        itemCount: contests.upcomingEvents.length,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final count = index;
          return element(contests.upcomingEvents[count]);
        },
      ),
    );
  } else
    return Center(child: CircularProgressIndicator());
}

Widget livePage(Contests contests) {
  if (contests != null) {
    return Scrollbar(
      child: new ListView.builder(
          itemCount: contests.liveEvents.length,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final count = index;
            return element(contests.liveEvents[count]);
          }),
    );
  } else
    return Center(child: CircularProgressIndicator());
}

Widget aboutPage() {
  return Container(
      padding: EdgeInsets.fromLTRB(18, 50, 18, 0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "CP List is an App build just to provide all the online coding competitions happening around the world at your fingertips.\n\nWe Included all the major Sites from around the world, with relevent tags.\n\nThis app is developed using Flutter.\n\nCreated by Shivanshu Tyagi.\n\nMade with 🧡 in India!",
              textAlign: TextAlign.center,
              softWrap: true,
              textScaleFactor: 1.1,
            )
          ]));
}
