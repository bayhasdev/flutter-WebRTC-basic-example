import 'package:basic_example/data_channel/data_channel_page.dart';
import 'package:basic_example/get_user_media_sample.dart';
import 'package:basic_example/loopback_sample.dart';
import 'package:basic_example/signaling/signaling_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const String routeName = '/MainPage';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MainPage'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text('UserMediaSample'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => GetUserMediaSample(),
              )),
            ),
            ListTile(
              title: Text('DataChannelPage'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DataChannelPage(),
              )),
            ),
            ListTile(
              title: Text('LoopBackSample'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LoopBackSample(),
              )),
            ),
            ListTile(
              title: Text('Signaling Page'),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SignalingPage(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
