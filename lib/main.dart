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
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
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
      name: 'User_Logged',
      parameters: <String, dynamic>{
        'Message': 'User opened the app',
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
  bool flag = false;

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _logAppPage();
    });
  }

  void getData(Future<Contests> c) {
    c.then(_onValue).catchError(_onError);
  }

  void _onValue(Contests tmp) {
    data = tmp;
    if (!flag) {
      showInSnackBar();
      flag = true;
    }
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
    _logAppUsage();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        String url = message['data'].link;
        print(url);
        launch(url);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        String url = message['data']['link'].link;
        print(url);
        launch(url);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        String url = message['data']['link'].link;
        print(url);
        launch(url);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar() {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        backgroundColor: Colors.teal[300],
        elevation: 1.5,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 6),
        content: new Text(
            "Long Press any item in Upcoming page to add it to your Calender",
            style: TextStyle(color: Colors.black,),
            )));
  }

  @override
  Widget build(BuildContext context) {
    getData(con);
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Center(child: Icon(Icons.code, color: Colors.white38)),
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
          selectedItemColor: Colors.teal[300],
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
    if(isnormal){
      return Scrollbar(
      child: new ListView.builder(
        itemCount: contests.u.length,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final count = index;
          return elementl(contests.u[count]);
        },
      ),
    );
    }
    else{return Scrollbar(
      child: new ListView.builder(
        itemCount: contests.upcomingEvents.length,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final count = index;
          return elementl(contests.upcomingEvents[count]);
        },
      ),
    );}
  } else
    return Center(child: CircularProgressIndicator());
}

// Widget livePage(Contests contests) {
//   if (contests != null) {
//     return Scrollbar(
//       child: new ListView.builder(
//           itemCount: contests.liveEvents.length,
//           physics: AlwaysScrollableScrollPhysics(),
//           itemBuilder: (context, index) {
//             final count = index;

//             return element(contests.liveEvents[count]);
//           }),
//     );
//   } else
//     return Center(child: CircularProgressIndicator());
// }

Widget livePage(Contests contests) {
  if (contests != null) {
    if(isnormal){return Scrollbar(
      child: new ListView.builder(
          itemCount: contests.liveEvents.length,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final count = index;
            
            return element(contests.l[count]);
          }),
    );}
    else
    {return Scrollbar(
      child: new ListView.builder(
          itemCount: contests.liveEvents.length,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final count = index;
            
            return element(contests.liveEvents[count]);
          }),
    );}
  } else
    return Center(child: CircularProgressIndicator());
}

bool isnormal = false;

changed(bool value){
  isnormal = value;
}

Widget aboutPage() {
  return Container(
      padding: EdgeInsets.fromLTRB(18, 20, 18, 0),
      constraints: BoxConstraints(maxHeight: double.infinity),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,children: [Text("Normal Sorting"),Container(width: 10),Switch(value: isnormal, onChanged: changed)]),
            Container(height: 50,child: Center(child: Text("\"Normal Sorting\" refers to arranging the events by their starting time.",textAlign: TextAlign.center,)),),
            Container(height: 50,child: Center(child: Text("This Preference is not retained, as we are not using the local storage",textAlign: TextAlign.center,)),),
            Divider(color: Colors.white,endIndent: 5,),
            Container(constraints: BoxConstraints(maxHeight: 10),),
            Container(height: 20,),
            Text(
              "CP List is an App build just to provide all the online coding competitions happening around the world at your fingertips.\n\nWe Included all the major Sites from around the world, with relevent tags.\n\nYou can add these events in your Calender by long-pressing on the event in Upcoming tab.\n\nThis app is developed using Flutter.\n\nCreated by Shivanshu Tyagi.\n\nMade with 🧡 in India!",
              textAlign: TextAlign.center,
              softWrap: true,
              textScaleFactor: 1.1,
            )
          ]));
}
