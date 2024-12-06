import 'package:stomp/stomp.dart';
import 'package:test/test.dart';

void main() {
  group('Stomp Client', () {
    late StompClient client;
    setUp(() {
      client = StompClient();
    });

    tearDown(() {
      client.disconnect();
    });

    test('should connect to AMQ, subscribe to a queue and receive a message',
        () async {
      await client.connect();

      client.subscribe(
        '/queue/test',
        expectAsync1(
          (StompMessage message) {
            expect(message.body, 'Hello, World!');
          },
          count: 1,
        ),
      );

      client.send('/queue/test', 'Hello, World!');
    });

    test('should connect to AMQ, subscribe to a topic and receive a message',
        () async {
      await client.connect();

      client.subscribe(
        '/topic/test',
        expectAsync1(
          (StompMessage message) {
            expect(message.body, 'Hello, World!');
          },
          count: 1,
        ),
      );

      client.send('/topic/test', 'Hello, World!');
    });
  });
}
