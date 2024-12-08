import 'dart:async';
import 'dart:typed_data';

import 'package:simple_stomp/src/client_options.dart';
import 'package:simple_stomp/src/command.dart';
import 'package:simple_stomp/src/exceptions.dart';
import 'package:simple_stomp/src/frame.dart';
import 'package:simple_stomp/src/headers.dart';
import 'package:simple_stomp/src/message.dart';
import 'package:simple_stomp/src/tcp.dart';

typedef StompMessageHandler = void Function(StompMessage message);

class StompClient {
  StompClient({
    this.options = const StompClientOptions(),
    StompTcpClient? tcpClient,
  }) : _tcpClient = tcpClient ?? StompTcpClientSocket();

  final StompClientOptions options;
  final StompTcpClient _tcpClient;
  late StreamSubscription<Uint8List>? _subscription;

  Stream<Uint8List>? _tcpStream;
  final Map<String, StompMessageHandler> _handlers = {};
  final Map<String, String> _subscriptionsMap = {};

  Stream<Uint8List>? get rawStream => _tcpStream;

  Future<void> connect() async {
    final completer = Completer<void>();
    await _tcpClient.connect(options.host, options.port, options.timeout);
    _tcpStream = _tcpClient.onReceive;

    _subscription = _tcpStream!.listen(
      (data) {
        final frame = ServerFrame.parse(String.fromCharCodes(data));
        if (frame.command == ServerCommand.CONNECTED) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
        if (frame.command == ServerCommand.MESSAGE) {
          final destination = frame.headers[StompHeaders.destination];
          final handler = _handlers[destination!];
          if (handler != null) {
            handler(StompMessage(frame.headers, frame.body!));
          }
        }
        if (frame.command == ServerCommand.ERROR) {
          _tcpClient.close();
          if (!completer.isCompleted) {
            completer.completeError(StompException(frame.body!));
          }
        }
      },
      onDone: () {
        _tcpClient.close();
        if (!completer.isCompleted) {
          completer.completeError(StompException('Connection closed'));
        }
      },
      onError: (error) {
        print('Error: $error');
        _tcpClient.close();
        if (!completer.isCompleted) {
          completer.completeError(StompException('Connection error'));
        }
      },
    );
    _tcpClient.add(ClientFrame.connect(
      options.host,
      options.login,
      options.passcode,
    ).toBytes());

    await completer.future;
  }

  Future<void> subscribe(
    String destination,
    StompMessageHandler handler,
  ) async {
    _handlers[destination] = handler;
    final id = _subscriptionsMap.length.toString();
    _subscriptionsMap[destination] = id;
    _tcpClient.add(ClientFrame.subscribe(destination, id).toBytes());
  }

  Future<void> unsubscribe(
    String destination,
  ) async {
    final id = _subscriptionsMap['destination'];

    if (id == null) {
      throw Exception('No subscription found for destination: $destination');
    }
    _tcpClient.add(ClientFrame.unsubscribe(id).toBytes());

    _subscriptionsMap.remove(destination);
    _handlers.remove(destination);
  }

  void send(String destination, String body) {
    _tcpClient.add(ClientFrame.send(destination, body).toBytes());
  }

  void disconnect() {
    _tcpClient.add(ClientFrame.disconnect().toBytes());

    _subscription?.cancel();
    _subscriptionsMap.clear();
    _handlers.clear();

    _tcpClient.close();
  }
}
