import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// Background message handler for FCM
Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    // Subscribe to a topic for general notifications
    messaging.subscribeToTopic("messaging");

    // Retrieve the FCM token
    messaging.getToken().then((value) {
      print('FCM Token: $value');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Message received");
      print('Notification body: ${event.notification?.body}');
      print('Data payload: ${event.data}');

      // Check if the message is part of a campaign
      if (event.data.containsKey('campaign_id')) {
        _handleCampaignNotification(event);
      } else {
        _showNotificationDialog(
          title: event.notification?.title ?? 'Notification',
          body: event.notification?.body ?? 'No message body',
        );
      }
    });

    // Handle when a notification is clicked
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
      if (message.data.containsKey('campaign_id')) {
        _handleCampaignNotification(message);
      }
    });
  }

  // Function to handle campaign notifications
  void _handleCampaignNotification(RemoteMessage message) {
    String campaignId = message.data['campaign_id'] ?? 'Unknown Campaign';
    String campaignName = message.data['campaign_name'] ?? 'Unnamed Campaign';

    print('Campaign Notification Received: ID = $campaignId, Name = $campaignName');

    // Show a dialog specifically for campaign notifications
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Campaign Notification"),
          content: Text(
              'You have received a notification from the campaign: $campaignName'),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to display a general notification dialog
  void _showNotificationDialog({required String title, required String body}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Firebase Messaging'),
      ),
      body: Center(
        child: Text("Welcome to the Messaging Tutorial with Campaign Handling"),
      ),
    );
  }
}