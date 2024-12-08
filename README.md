# simple_stomp

A Dart client library for [STOMP](http://stomp.github.io/) messaging protocol.

## Usage

A simple usage example:

```dart
import 'package:simple_stomp/simple_stomp.dart';

Future<void> main() async {
  final stompClient = StompClient(
    config: StompClientOptions(
      host: 'localhost',
      port: 61613,
      login: 'guest',
      passcode: 'guest',
      heartbeat: const Duration(seconds: 5),
      timeout: const Duration(seconds: 5),
    ),
  );

  await stompClient.connect();
}
```

Subscribe to a destination:

```dart
stompClient.subscribe(
  destination: '/topic/foo',
  callback: (frame) {
    print('Received: ${frame.body}');
  },
);
```

Unsubscribe from a destination:

```dart
stompClient.unsubscribe('/topic/foo');
```

Send a message to a destination:

```dart
stompClient.send(
  '/topic/foo',
  'Hello, World!',
);
```

Disconnect from the server:

```dart
stompClient.disconnect();
```

## Roadmap

Take a look at the tracking project for Stomp v1.2 implementation: [Stomp v1.2 feature complete](https://github.com/orgs/flutterings/projects/1/views/2)

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/flutterings/stomp.dart/issues).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
