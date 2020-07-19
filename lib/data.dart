import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';


class DataLoader {
  String _url =
      "https://clist.by/api/v1/contest/?format=json&username=Shivty&api_key=e1ed3bc32e0283cf13003c6289acfda869ad6384&limit=20000&end__gt="+DateTime.now().add(Duration(hours: -2)).toString()+"&filtered=true&order_by=end";
  Contests data;

  Future<Contests> getFuture() {
    return _fetch(_url);
  }

  Future<Contests> _fetch(String url) async {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return Contests.fromJson((response.body));
    } else {
      throw Exception('Failed to load Data');
    }
  }
}

class Meta {
  int limit;
  String next;
  int offset;
  String previous;
  int total_count;

  Meta.fromJson(Map<String, dynamic> jsonMap) {
    this.limit = jsonMap['limit'];
    this.next = jsonMap['next'];
    this.offset = jsonMap['offset'];
    this.previous = jsonMap['previous'];
    this.total_count = (jsonMap['total_count']);
  }
}

class Contest {
  int id;
  String event;
  DateTime start;
  DateTime end;
  DateTime duration;
  String site;
  String href;
  Color color;
  bool isLive = false;

  Contest.fromJson(Map<String, dynamic> jsonMap) {
    this.id = jsonMap['id'];
    this.event = jsonMap["event"];
    this.href = jsonMap["href"];
    try {
      this.site = jsonMap['resource']['name'];
    } catch (e) {}
    try {
      this.start = DateTime.tryParse(jsonMap["start"]+'Z').toLocal();
      this.end = DateTime.tryParse(jsonMap["end"]+'Z').toLocal();
    } catch (e) {
      // print(e);
    }
    if (DateTime.now().compareTo(this.start.toLocal()) > 0) {
      this.isLive = true;
    }
    if (this.site == 'topcoder.com')
      this.color = Colors.lightBlue.shade300;
    else if (this.site == 'kaggle.com')
      this.color = Colors.orange.shade300;
    else if (this.site == 'codechef.com')
      this.color = Colors.brown.shade300;
    else if (this.site == 'hackerearth.com')
      this.color = Colors.indigo.shade300;
    else if (this.site == 'spoj.com')
      this.color = Colors.deepOrange.shade100;
    else if (this.site == 'ctftime.org')
      this.color = Colors.grey.shade400;
    else if (this.site == 'e-olymp.com')
      this.color = Colors.cyan.shade500;
    else if (this.site == 'projecteuler.net')
      this.color = Colors.purpleAccent.shade200;
    else if (this.site == 'codeforces.com')
      this.color = Colors.red.shade300;
    else if (this.site == 'codingcompetitions.withgoogle.com') {
      this.color = Colors.yellow.shade300;
      this.site = 'Google';
    } else {
      this.color = Colors.green.shade100;
    }
  }
}

class Contests {
  Meta meta;
  List<Contest> events;
  List<Contest> liveEvents;
  List<Contest> upcomingEvents;
  List<Contest> l=[];
  List<Contest> u=[];

  List<Contest> topcoder = [],
      codechef = [],
      hackerearth = [],
      codeforces = [],
      google = [],
      kaggle = [],
      ctftime = [],
      spoj = [],
      eolymp = [],
      other = [],
      topcoderl = [],
      codechefl = [],
      pe = [],
      hackerearthl = [],
      codeforcesl = [],
      googlel = [],
      kagglel = [],
      ctftimel = [],
      spojl = [],
      pel = [],
      eolympl = [],
      otherl = [];

  Contests.fromJson(String jsonStr) {
    final _map = jsonDecode(jsonStr);
    this.events = [];
    this.meta = new Meta.fromJson(_map['meta']);
    final _objects = _map['objects'];
    for (var i = 0; i < this.meta.total_count; i++) {
      this.events.add(new Contest.fromJson(_objects[i]));
      if(this.events.last.isLive){this.l.add(this.events.last);}
      if(!this.events.last.isLive){this.u.add(this.events.last);}
    }
    for (var i = 0; i < meta.total_count; i++) {
      if (events[i].isLive == false) {
        if (events[i].site == 'topcoder.com')
          topcoder.add(events[i]);
        else if (events[i].site == 'kaggle.com')
          kaggle.add(events[i]);
        else if (events[i].site == 'codechef.com')
          codechef.add(events[i]);
        else if (events[i].site == 'hackerearth.com')
          hackerearth.add(events[i]);
        else if (events[i].site == 'codeforces.com')
          codeforces.add(events[i]);
        else if (events[i].site == 'Google')
          google.add(events[i]);
        else if (events[i].site == 'ctftime.org')
          ctftime.add(events[i]);
        else if (events[i].site == 'spoj.com')
          spoj.add(events[i]);
        else if (events[i].site == 'projecteuler.net')
          pe.add(events[i]);
        else if (events[i].site == 'e-olymp.com')
          eolymp.add(events[i]);
        else
          other.add(events[i]);
      } else {
        if (events[i].site == 'topcoder.com')
          topcoderl.add(events[i]);
        else if (events[i].site == 'kaggle.com')
          kagglel.add(events[i]);
        else if (events[i].site == 'codechef.com')
          codechefl.add(events[i]);
        else if (events[i].site == 'hackerearth.com')
          hackerearthl.add(events[i]);
        else if (events[i].site == 'codeforces.com')
          codeforcesl.add(events[i]);
        else if (events[i].site == 'Google')
          googlel.add(events[i]);
        else if (events[i].site == 'ctftime.org')
          ctftimel.add(events[i]);
        else if (events[i].site == 'spoj.com')
          spojl.add(events[i]);
        else if (events[i].site == 'projecteuler.net')
          pel.add(events[i]);
        else if (events[i].site == 'e-olymp.com')
          eolympl.add(events[i]);
        else
          otherl.add(events[i]);
      }
    }
    upcomingEvents = codeforces +
        google +
        hackerearth +
        codechef +
        topcoder +
        kaggle +
        ctftime+
        spoj+
        pe+
        eolymp+
        other;
    liveEvents = codeforcesl +
        googlel +
        hackerearthl +
        codechefl +
        topcoderl +
        kagglel +
        ctftimel+
        spojl+
        pel+
        eolympl+
        otherl;
  }
}

Card elementl(Contest contest) {
  return Card(
    elevation: 2.0,
    color: Colors.black45,
    child: OutlineButton(
      onPressed: () async {
        String url = contest.href;

        if (await canLaunch(url)) {
          await launch(url, forceSafariVC: false);
        } else {
          throw 'Could not launch $url';
        }
      },
      onLongPress: (){
        final Event event = Event(
            title: contest.event,
            description: 'Coding Compitition added by cp_list app.',
            location: contest.href,
            startDate: contest.start.toLocal(),
            endDate: contest.end.toLocal(),
          );
      Add2Calendar.addEvent2Cal(event);
      } ,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.all(10),
            leading: Icon(Icons.laptop_mac),
            title: Text(contest.event,textScaleFactor: 1.1,),
          ),
          ListTile(
            title: Text(getStringtoPrintl(contest),textScaleFactor: 0.8,),
            trailing: Container(
              decoration: BoxDecoration(
                  color: contest.color,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              padding: EdgeInsets.all(5),
              child: Text(
                contest.site,
                softWrap: false,
                style: TextStyle(color: Colors.black),
                textScaleFactor: 0.8,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Card element(Contest contest) {
  return Card(
    elevation: 2.0,
    color: Colors.black45,
    child: OutlineButton(
      onPressed: () async {
        String url = contest.href;

        if (await canLaunch(url)) {
          await launch(url, forceSafariVC: false);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.all(10),
            leading: Icon(Icons.laptop_mac),
            title: Text(contest.event,textScaleFactor: 1.1,),
          ),
          ListTile(
            title: Text(getStringtoPrint(contest),textScaleFactor: 0.8,),
            trailing: Container(
              decoration: BoxDecoration(
                  color: contest.color,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              padding: EdgeInsets.all(5),
              child: Text(
                contest.site,
                softWrap: false,
                style: TextStyle(color: Colors.black),
                textScaleFactor: 0.8,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

String getStringtoPrintl(Contest contest) {
  if (int.parse(timeLeft(contest.end).split(' ')[0]) < 0) {
    return "Contest Ended";
  } else
    return ('Starts at: ' +
        printTime(contest.start.toLocal()) +
        '\nStarts in: ' +
        timeLeft(contest.start.toLocal()))+
        '\nDuration: '+ duration(contest.end.difference(contest.start));
}

String getStringtoPrint(Contest contest) {
  if (int.parse(timeLeft(contest.end).split(' ')[0]) < 0) {
    return "Contest Ended";
  } else
    return ('Started at: ' +
        printTime(contest.start.toLocal()) +
        '\nEnds in: ' +
        timeLeft(contest.end.toLocal()))+
        '\nDuration: '+ duration(contest.end.difference(contest.start));;
}

String timeLeft(DateTime endTime) {
  Duration duration = endTime.difference(DateTime.now());
  if (duration > Duration(hours: 24)) {
    return duration.inDays.toString() + " days "+(duration.inHours%24).toString() + " hrs";
  } else if (duration > Duration(minutes: 60)) {
    return (duration.inHours).toString() +
        " hr " +
        (duration.inMinutes % 60).toString() +
        " min ";
  } else if (duration < Duration(minutes: 60)) {
    return (duration.inMinutes).toString() +
        " min " +
        (duration.inSeconds % 60).toString() +
        " sec";
  } else {
    return (duration).toString();
  }
}

String duration(Duration duration) {
  if(duration.inMinutes%60==0){
     return (duration.inHours).toString()+" hrs";
  } else {
     return (duration.inHours).toString()+':'+(duration.inMinutes).toString()+" hrs";
  }
}

String printTime(DateTime time) {
  time = time.toLocal();
  return (time.day).toString() +
      "-" +
      (time.month).toString() +
      "-" +
      (time.year).toString() +
      " " +
      (time.hour).toString() +
      ":" +
      (time.minute).toString();
}

String printdate(DateTime time) {
  time = time.toLocal();
  return (time.year).toString() +
      "-" +
      (time.month).toString() +
      "-" +
      (time.day).toString();
}
