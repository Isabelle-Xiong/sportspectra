import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sportspectra/config/appid.dart';
import 'package:sportspectra/providers/user_provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:sportspectra/resources/firestore_methods.dart';
import 'package:sportspectra/responsive/responsive_layout.dart';
import 'package:sportspectra/screens/home_screen.dart';
import 'package:sportspectra/widgets/chat.dart';
import 'package:http/http.dart' as http;
import 'package:sportspectra/widgets/custom_button.dart';

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  const BroadcastScreen(
      {super.key, required this.isBroadcaster, required this.channelId});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;
  bool isScreenSharing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initEngine();
  }

  void _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    // adding listners to check when users leave and join
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    // making user join second time to see screen of user
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      _engine.setClientRole(ClientRole.Audience);
    }
    _joinChannel();
  }

  String baseUrl = "https://sportspectra-server-go-flutter.onrender.com";

  String? token;

  // send http request to api (created with golang)

  Future<void> getToken() async {
    print('Fetching token for channel ${widget.channelId}');
    final res = await http.get(
      Uri.parse(baseUrl +
          '/rtc/' +
          widget.channelId +
          '/publisher/userAccount/' +
          Provider.of<UserProvider>(context, listen: false).user.uid +
          '/'),
    );
    // if response is ok, set token
    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)['rtcToken'];
      });
      print('Token fetched successfully: $token');
    } else {
      debugPrint('Failed to fetch the token');
    }
  }

  void _addListeners() {
    _engine.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
      debugPrint('joinChannelSuccess $channel $uid $elapsed');
    }, userJoined: (uid, elapsed) {
      debugPrint('userJoined $uid $elapsed');
      setState(() {
        remoteUid.add(uid);
      });
      // if user goes offline
    }, userOffline: (uid, reason) {
      debugPrint('userOffline $uid $reason');
      // remove user if they go offline
      setState(() {
        remoteUid.removeWhere((element) => element == uid);
      });
    }, leaveChannel: (stats) {
      debugPrint('leaveChannel $stats');
      // when admin leaves channel, everyone clears
      setState(() {
        remoteUid.clear();
      });
      // when token expires, get new token and give engine new token
    }, tokenPrivilegeWillExpire: (token) async {
      await getToken();
      await _engine.renewToken(token);
    }));
  }

  void _joinChannel() async {
    await getToken();
    if (token != null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await [Permission.microphone, Permission.camera].request();
      }

      print(
          'Channel ID: ${widget.channelId}, Type: ${widget.channelId.runtimeType}');
      await _engine.joinChannelWithUserAccount(token, widget.channelId,
          Provider.of<UserProvider>(context, listen: false).user.uid);
    }
  }

  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  _startScreenShare() async {
    final helper = await _engine.getScreenShareHelper(
        appGroup: kIsWeb || Platform.isWindows ? null : 'io.agora');
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    var windowId = 0;
    var random = Random();
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      final windows = _engine.enumerateWindows();
      if (windows.isNotEmpty) {
        final index = random.nextInt(windows.length - 1);
        debugPrint('Screensharing window with index $index');
        windowId = windows[index].id;
      }
    }
    await helper.startScreenCaptureByWindowId(windowId);
    setState(() {
      isScreenSharing = true;
    });
    await helper.joinChannelWithUserAccount(
      token,
      widget.channelId,
      Provider.of<UserProvider>(context, listen: false).user.uid,
    );
  }

  _stopScreenShare() async {
    final helper = await _engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      setState(() {
        isScreenSharing = false;
      });
    }).catchError((err) {
      debugPrint('StopScreenShare $err');
    });
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    // if broadcaster leaves channel, end stream
    if ('${Provider.of<UserProvider>(context, listen: false).user.uid}${Provider.of<UserProvider>(context, listen: false).user.username}' ==
        widget.channelId) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
      // if other viewers leave channel, update view count
      // set to false since we are leaving broadcast screen, so need to be false to decrease view by 1 via isIncrease function.
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return PopScope(
      onPopInvoked: (didPop) async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        bottomNavigationBar: widget.isBroadcaster
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: CustomButton(
                  text: 'End Stream',
                  onTap: _leaveChannel,
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _renderVideo(user),
              if ("${user.uid}${user.username}" == widget.channelId)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _switchCamera,
                      child: const Text('Switch Camera'),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isMuted = !isMuted;
                        });
                        onToggleMute();
                      },
                      child: Text(isMuted ? 'Unmute' : 'Mute'),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isScreenSharing = !isScreenSharing;
                        });
                        isScreenSharing
                            ? _startScreenShare()
                            : _stopScreenShare();
                      },
                      child: Text(
                        isScreenSharing
                            ? 'Stop ScreenSharing'
                            : 'Start Screensharing',
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: Chat(
                  channelId: widget.channelId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _renderVideo(user) {
    print('Remote UIDs: $remoteUid');
    print('Remote UIDs Type: ${remoteUid.runtimeType}');
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: "${user.uid}${user.username}" == widget.channelId
          ? isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : const RtcLocalView.SurfaceView(
                  zOrderMediaOverlay: true,
                  zOrderOnTop: true,
                )
          : isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : remoteUid.isNotEmpty // Check if remoteUid list is not empty
                  ? kIsWeb // Check if running on web
                      ? RtcRemoteView.SurfaceView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        ) // Use RtcRemoteView.SurfaceView for web
                      : RtcRemoteView.TextureView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        ) // Use RtcRemoteView.TextureView for non-web platforms
                  : Container(), // Use empty Container if remoteUid list is empty
    );
  }
}
