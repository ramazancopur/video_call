import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:video_call/models/meeting_details.dart';
import 'package:video_call/pages/home_screen.dart';
import 'package:video_call/utils/user.utils.dart';
import 'package:video_call/widgets/control_panel.dart';
import 'package:video_call/widgets/remote_connection.dart';

class MeetingPage extends StatefulWidget {
  final String? meetingId;
  final String? name;
  final MeetingDetail meetingDetail;

  const MeetingPage({
    Key? key,
    this.meetingId,
    this.name,
    required this.meetingDetail,
  }) : super(key: key);

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {'audio': true, 'video': true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect(),
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  void startMeeting() async {
    final String userId = await loadUserId();
    meetingHelper = WebRTCMeetingHelper(url: "http://192.168.1.33:4000", meetingId: widget.meetingId, userId: userId, name: widget.name);

    MediaStream localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = localStream;

    meetingHelper!.stream = localStream;

    meetingHelper!.on(
      "open",
      context,
      (ev, context) {
        setState(
          () {
            isConnectionFailed = false;
          },
        );
      },
    );

    meetingHelper!.on(
      "connection",
      context,
      (ev, context) {
        setState(
          () {
            isConnectionFailed = false;
          },
        );
      },
    );

    meetingHelper!.on(
      "user-left",
      context,
      (ev, context) {
        setState(
          () {
            isConnectionFailed = false;
          },
        );
      },
    );

    meetingHelper!.on(
      "video-toggle",
      context,
      (ev, context) {
        setState(
          () {},
        );
      },
    );

    meetingHelper!.on(
      "audio-toggle",
      context,
      (ev, context) {
        setState(
          () {},
        );
      },
    );

    meetingHelper!.on(
      "meeting-ended",
      context,
      (ev, context) {
        onMeetingEnd();
      },
    );

    meetingHelper!.on(
      "connection-setting-changed",
      context,
      (ev, context) {
        setState(
          () {
            isConnectionFailed = false;
          },
        );
      },
    );

    meetingHelper!.on(
      "stream-changed",
      context,
      (ev, context) {
        setState(
          () {
            isConnectionFailed = false;
          },
        );
      },
    );

    setState(() {});
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
    startMeeting();
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  bool isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    }
  }

  _buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
                crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
                children: List.generate(meetingHelper!.connections.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(1),
                    child: RemoteConnection(
                      renderer: meetingHelper!.connections[index].renderer,
                      connection: meetingHelper!.connections[index],
                    ),
                  );
                }),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Katılımcı bekleniyor!',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        Positioned(
            bottom: 10,
            right: 0,
            child: SizedBox(
              width: 150,
              height: 200,
              child: RTCVideoView(_localRenderer),
            )),
      ],
    );
  }

  void goToHomePage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
