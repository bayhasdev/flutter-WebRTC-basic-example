import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

Map<String, dynamic> _connectionConfiguration = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ]
};

const _offerAnswerConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

class WebRtcDataChannelViewModel {
  final List<Message> messageList = [];
  StreamController<Message> messageStram = StreamController<Message>();
  RTCDataChannel? _dataChannel;
  RTCPeerConnection? _connection;
  RTCSessionDescription? _sdp;

  void _addMessage(Message msg) {
    messageList.add(msg);
    messageStram.sink.add(msg);
  }

  Future<void> offerConnection() async {
    _connection = await _createPeerConnection();
    await _createDataChannel();
    RTCSessionDescription offer = await _connection!.createOffer(_offerAnswerConstraints);
    await _connection!.setLocalDescription(offer);
    _sdpChanged();
    messageStram.sink.add(Message.fromSystem("Created offer"));
  }

  Future<void> answerConnection(RTCSessionDescription offer) async {
    _connection = await _createPeerConnection();
    await _connection!.setRemoteDescription(offer);
    final answer = await _connection!.createAnswer(_offerAnswerConstraints);
    await _connection!.setLocalDescription(answer);
    _sdpChanged();
    _addMessage(Message.fromSystem("Created Answer"));
  }

  Future<void> acceptAnswer(RTCSessionDescription answer) async {
    if (_connection == null) return;
    await _connection!.setRemoteDescription(answer);
    _addMessage(Message.fromSystem("Answer Accepted"));
  }

  Future<void> sendMessage(String message) async {
    if (_dataChannel == null) return;
    await _dataChannel!.send(RTCDataChannelMessage(message));
    _addMessage(Message.fromUser("ME", message));
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final con = await createPeerConnection(_connectionConfiguration);
    con.onIceCandidate = (candidate) {
      _addMessage(Message.fromSystem("New ICE candidate"));
      _sdpChanged();
    };
    con.onDataChannel = (channel) {
      _addMessage(Message.fromSystem("Recived data channel"));
      _addDataChannel(channel);
    };
    return con;
  }

  void _sdpChanged() async {
    if (_connection == null) return;
    _sdp = await _connection!.getLocalDescription();
    Clipboard.setData(ClipboardData(text: json.encode(_sdp?.toMap())));
    _addMessage(Message.fromSystem("${_sdp?.type} SDP is coppied to the clipboard"));
  }

  Future<void> _createDataChannel() async {
    if (_connection == null) return;
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel = await _connection!.createDataChannel("textchat-chan", dataChannelDict);
    _addMessage(Message.fromSystem("Created data channel"));
    _addDataChannel(channel);
  }

  void _addDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    _dataChannel!.onMessage = (data) {
      _addMessage(Message.fromUser("OTHER", data.text));
    };
    _dataChannel!.onDataChannelState = (state) {
      _addMessage(Message.fromSystem("Data channel state: $state"));
    };
  }

  void dispose(filename) async {
    messageStram.close();
    await _dataChannel?.close();
    await _connection?.close();
  }
}

@immutable
class Message {
  final String sender;
  final bool isSystem;
  final String message;

  Message(this.sender, this.isSystem, this.message);
  Message.fromUser(this.sender, this.message) : isSystem = false;
  Message.fromSystem(this.message)
      : this.sender = "System",
        isSystem = true;
}
