import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io';

import '../api/notification.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../api/device_info_api.dart';
// import '../api/device_info_api.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class ImageApp extends StatefulWidget {
  static const routeName = '/image_screen';

  @override
  _ImageAppState createState() => _ImageAppState();
}

class _ImageAppState extends State<ImageApp> {
  final List<String> names = [
    "person",
    "bicycle",
    "car",
    "motorcycle",
    "airplane",
    "bus",
    "train",
    "truck",
    "boat",
    "traffic light",
    "fire hydrant",
    "stop sign",
    "parking meter",
    "bench",
    "bird",
    "cat",
    "dog",
    "horse",
    "sheep",
    "cow",
    "elephant",
    "bear",
    "zebra",
    "giraffe",
    "backpack",
    "umbrella",
    "handbag",
    "tie",
    "suitcase",
    "frisbee",
    "skis",
    "snowboard",
    "sports ball",
    "kite",
    "baseball bat",
    "baseball glove",
    "skateboard",
    "surfboard",
    "tennis racket",
    "bottle",
    "wine glass",
    "cup",
    "fork",
    "knife",
    "spoon",
    "bowl",
    "banana",
    "apple",
    "sandwich",
    "orange",
    "broccoli",
    "carrot",
    "hot dog",
    "pizza",
    "donut",
    "cake",
    "chair",
    "couch",
    "potted plant",
    "bed",
    "dining table",
    "toilet",
    "tv",
    "laptop",
    "mouse",
    "remote",
    "keyboard",
    "cell phone",
    "microwave",
    "oven",
    "toaster",
    "sink",
    "refrigerator",
    "book",
    "clock",
    "vase",
    "scissors",
    "teddy bear",
    "hair drier",
    "toothbrush",
  ];
  var selectedName = 'Person';
  final client = MqttServerClient('119.17.253.45', '1883');
// ignore: prefer_const_declarations
  String imageUrl = '';
  var status = 0;
  var textTitle = '';
  Future<int> main() async {
    client.logging(on: false);
    client.keepAlivePeriod = 5;
    client.connectTimeoutPeriod = 2000;
    client.autoReconnect = true;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
    final phoneName = await DeviceInfoApi.getPhoneInfo();

    final connMess = MqttConnectMessage()
        .withClientIdentifier(phoneName)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('Client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('Client exception: $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('Socket exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Client connected');
    } else {
      print(
          'Client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
      exit(-1);
    }
    const subTopic = 'test/t2';

    print('Subscribing to the $subTopic topic');
    client.subscribe(subTopic, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Received message: topic is ${c[0].topic}, payload is $pt');
      textTitle = pt;
      Noti.showBigTextNotification(
          id: 1,
          title: 'Smart camera',
          body: pt,
          fln: flutterLocalNotificationsPlugin);
      setState(() {
        var random = new Random();
        imageUrl = 'http://119.17.253.45/live/test.jpg?t=' +
            random.nextInt(100).toString();
      });
    });

    client.published!.listen((MqttPublishMessage message) {
      print(
          'Published topic: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });

    const pubTopic = 'test/t1';
    final builder = MqttClientPayloadBuilder();
    builder.addString('${phoneName}');
    print('From ${client.clientIdentifier}');
    print('Subscribing to the $pubTopic topic');
    client.subscribe(pubTopic, MqttQos.exactlyOnce);

    print('Publishing our topic');
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!,
        retain: true);

    print('Sleeping....');
    await MqttUtilities.asyncSleep(80);

    print('Unsubscribing');
    client.unsubscribe(subTopic);
    client.unsubscribe(pubTopic);

    await MqttUtilities.asyncSleep(2);
    print('Disconnecting');
    client.disconnect();

    return 0;
  }

  void publishMess(String topic) {
    const pubTopic = 'test/t1';
    final builder = MqttClientPayloadBuilder();
    builder.addString(topic);
    client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!,
        retain: true);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    client.disconnect();
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      client.disconnect();
      print('OnDisconnected callback is solicited, this is correct');
    }
    exit(-1);
  }

  /// The successful connect callback
  void onConnected() {
    print('OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    print('Ping response client callback invoked');
  }

  @override
  void initState() {
    // TODO: implement initState
    // awesomeNotification();

    super.initState();
    main();
    Noti.initialize(flutterLocalNotificationsPlugin);
  }

  // void updateImage() {
  //   setState(() {
  //     imageUrl = 'http://119.17.253.45/live/test.jpg?t=1668011071105';
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nghiên cứu khoa học UIT'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Card(
              elevation: 6,
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 300,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          textTitle == '' ? selectedName : textTitle,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // ValueListenableBuilder(
                        //     valueListenable: imageUrl,
                        //     builder: (context, String value, Widget? child) {
                        //       setState(() {});
                        // return
                        imageUrl == ''
                            ? Container(
                                height: 150,
                                child: Image.asset(
                                  'assets/image/waiting.png',
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                height: 200,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 230,
              alignment: Alignment.center,
              child: names.length > 0
                  ? ListView.builder(
                      itemCount: names.length,
                      itemBuilder: ((context, index) {
                        return ListTile(
                          title: Text('${names[index]}'),
                          onTap: () {
                            setState(() {
                              selectedName = names[index];
                              publishMess(selectedName);
                            });
                          },
                        );
                      }))
                  : Center(child: Text('No name in list.')),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Theme.of(context).buttonColor,
              //         foregroundColor: Colors.black,
              //       ),
              //       child: const Text('Open Door'),
              //       onPressed: (() => publishMess('Open')),
              //     ),
              // SizedBox(
              //   width: 10,
              // ),
              // ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Theme.of(context).buttonColor,
              //       foregroundColor: Colors.black,
              //     ),
              //     child: const Text('Update Image'),
              //     onPressed: () {
              //       Noti.showBigTextNotification(
              //           title: 'Message title',
              //           body: "Your long body",
              //           fln: FlutterLocalNotificationsPlugin());
              //     }
              //     // => setState(() {
              //     //   var random = new Random();
              //     //   imageUrl = 'http://119.17.253.45/live/test.jpg?t=' +
              //     //       random.nextInt(100).toString();
              //     //   textTitle;
              //     // }),
              //     ),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
