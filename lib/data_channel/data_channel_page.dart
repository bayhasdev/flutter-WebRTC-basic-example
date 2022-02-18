import 'dart:convert';
import 'dart:developer';

import 'package:basic_example/data_channel/webrtc_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class DataChannelPage extends StatefulWidget {
  @override
  _DataChannelPageState createState() => _DataChannelPageState();
}

class _DataChannelPageState extends State<DataChannelPage> {
  WebRtcDataChannelViewModel dataChannelViewModel = WebRtcDataChannelViewModel();
  final controller = TextEditingController();
  final msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<RTCSessionDescription?> getSdpFromUser(BuildContext context) async {
    controller.clear();
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 10,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Done"),
            )
          ],
        ),
      ),
    );
    RTCSessionDescription? offer;
    try {
      final offerMap = json.decode(controller.text);
      offer = RTCSessionDescription(
        offerMap["sdp"],
        offerMap["type"],
      );
    } catch (e) {
      log("make sure the format is correct");
    }
    return Future.value(offer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Channel example'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: Text("OFFER"),
                    onPressed: () {
                      dataChannelViewModel.offerConnection();
                    },
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    child: Text("ANSWER"),
                    onPressed: () async {
                      final offer = await getSdpFromUser(context);
                      if (offer == null) return;
                      dataChannelViewModel.answerConnection(offer);
                    },
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                      child: Text("SET REMOTE"),
                      onPressed: () async {
                        final answer = await getSdpFromUser(context);
                        if (answer == null) return;
                        dataChannelViewModel.acceptAnswer(answer);
                      }),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<Message>(
                stream: dataChannelViewModel.messageStram.stream,
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: dataChannelViewModel.messageList.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = dataChannelViewModel.messageList.reversedIndex(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              message.sender,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(message.message),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      await dataChannelViewModel.sendMessage(msgController.text);
                      msgController.clear();
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}

extension<T> on List<T> {
  T reversedIndex(int index) {
    return this[length - index - 1];
  }
}
