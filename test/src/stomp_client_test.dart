import 'dart:async';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:stomp/src/client_options.dart';
import 'package:stomp/src/command.dart';
import 'package:stomp/src/exceptions.dart';
import 'package:stomp/src/frame.dart';
import 'package:stomp/src/headers.dart';
import 'package:stomp/src/tcp.dart';
import 'package:stomp/stomp.dart';
import 'package:test/test.dart';

class MockStompTcpClient extends Mock implements StompTcpClient {}

class MockStompMessageHandler extends Mock {
  void call(StompMessage message);
}

void main() {
  group('client', () {
    late StompClient client;
    late StompTcpClient tcpClient;
    late StreamController<Uint8List> controller;

    setUpAll(() {
      registerFallbackValue(Duration.zero);
    });

    setUp(() {
      controller = StreamController<Uint8List>();

      tcpClient = MockStompTcpClient();
      when(() => tcpClient.onReceive)
          .thenAnswer((_) => controller.stream.asBroadcastStream());
      when(() => tcpClient.connect(any(), any(), any())).thenAnswer((_) async {
        return;
      });

      client = StompClient(
        tcpClient: tcpClient,
      );
    });

    tearDown(() {
      controller.close();

      reset(tcpClient);
    });

    group('connect', () {
      test('should call the tcp client to connect to the server', () async {
        controller.add(ServerFrame.connected().toBytes());

        await client.connect();

        verify(() =>
            tcpClient.connect(kDefaultHost, kDefaultPort, kDefaultTimeout));
      });

      test('should thow exception when there is a connection error', () async {
        controller.add(ServerFrame.error('An error occured').toBytes());

        expect(() => client.connect(), throwsA(isA<StompException>()));
      });
    });
  });
}
