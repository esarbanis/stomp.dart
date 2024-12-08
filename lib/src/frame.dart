import 'dart:typed_data';

import 'package:simple_stomp/src/command.dart';
import 'dart:convert';

import 'package:simple_stomp/src/headers.dart';

abstract class Frame {
  Frame({
    required this.command,
    this.headers = const {},
    this.body,
  }) : assert(_isValidCommand(command, body),
            'Body is not allowed for command ${command.value}');

  final Command command;
  final Map<String, String> headers;
  final String? body;

  static bool _isValidCommand(Command command, String? body) {
    const commandsWithBody = {'SEND', 'MESSAGE', 'ERROR'};
    return commandsWithBody.contains(command.value) ||
        body == null ||
        body.isEmpty;
  }

  static String _escape(String value) {
    return value
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll(':', '\\c');
  }

  String get headersStr {
    return headers.entries.map((entry) {
      final key = _escape(entry.key);
      final value = _escape(entry.value);
      return '$key:$value';
    }).join('\n');
  }

  Uint8List toBytes() => utf8.encode(toString());

  @override
  String toString() {
    final headerStr = headersStr;
    final bodyStr = body ?? '';
    return '${command.value}\n$headerStr\n\n$bodyStr\x00';
  }
}

class HeartbeatFrame {
  static List<int> generate() {
    return utf8.encode('\n');
  }
}

class ClientFrame extends Frame {
  ClientFrame._({
    required ClientCommand super.command,
    super.headers,
    super.body,
  });

  factory ClientFrame.connect(String host, String? login, String? passcode) {
    return ClientFrame._(
      command: ClientCommand.CONNECT,
      headers: {
        StompHeaders.acceptVersion: '1.2',
        StompHeaders.host: host,
        if (login != null) StompHeaders.login: login,
        if (passcode != null) StompHeaders.passcode: passcode,
      },
    );
  }

  factory ClientFrame.send(String destination, String body) {
    return ClientFrame._(
      command: ClientCommand.SEND,
      headers: {
        StompHeaders.destination: destination,
      },
      body: body,
    );
  }

  factory ClientFrame.subscribe(String destination, String id) {
    return ClientFrame._(
      command: ClientCommand.SUBSCRIBE,
      headers: {
        StompHeaders.destination: destination,
        StompHeaders.id: id,
        StompHeaders.ack: 'auto',
      },
    );
  }

  factory ClientFrame.unsubscribe(String id) {
    return ClientFrame._(
      command: ClientCommand.UNSUBSCRIBE,
      headers: {
        StompHeaders.id: id,
      },
    );
  }

  factory ClientFrame.ack(String messageId) {
    return ClientFrame._(
      command: ClientCommand.ACK,
      headers: {
        'message-id': messageId,
      },
    );
  }

  factory ClientFrame.nack(String messageId) {
    return ClientFrame._(
      command: ClientCommand.NACK,
      headers: {
        'message-id': messageId,
      },
    );
  }

  factory ClientFrame.disconnect() {
    return ClientFrame._(
      command: ClientCommand.DISCONNECT,
    );
  }
}

class ServerFrame extends Frame {
  ServerFrame._({
    required ServerCommand super.command,
    super.headers,
    super.body,
  });

  factory ServerFrame.connected() {
    return ServerFrame._(
      command: ServerCommand.CONNECTED,
      headers: {
        StompHeaders.version: '1.2',
      },
    );
  }

  factory ServerFrame.message(
      String destination, String messageId, String body) {
    return ServerFrame._(
      command: ServerCommand.MESSAGE,
      headers: {
        StompHeaders.destination: destination,
        'message-id': messageId,
      },
      body: body,
    );
  }

  factory ServerFrame.error(String message) {
    return ServerFrame._(
      command: ServerCommand.ERROR,
      headers: {
        StompHeaders.version: '1.2',
        StompHeaders.contentType: 'text/plain',
      },
      body: message,
    );
  }

  factory ServerFrame.parse(String rawFrame) {
    final lines = rawFrame.split('\n');
    if (lines.isEmpty) {
      throw FormatException('Invalid STOMP frame: empty frame');
    }

    // The first line is the command
    final command = Command.fromString(lines[0].trim());

    // Headers: Lines until the first empty line
    final headers = <String, String>{};
    var i = 1;
    while (i < lines.length && lines[i].isNotEmpty) {
      final headerLine = lines[i];
      final separatorIndex = headerLine.indexOf(':');
      if (separatorIndex == -1) {
        throw FormatException(
            'Invalid STOMP frame: malformed header "$headerLine"');
      }
      final key = _unescape(headerLine.substring(0, separatorIndex).trim());
      final value = _unescape(headerLine.substring(separatorIndex + 1).trim());
      headers[key] = value;
      i++;
    }

    final bodyStartIndex = rawFrame.indexOf('\n\n') + 2;
    final bodyEndIndex = rawFrame.indexOf('\x00');
    String? body;
    if (bodyStartIndex > 1 && bodyEndIndex > bodyStartIndex) {
      body = rawFrame.substring(bodyStartIndex, bodyEndIndex);
    }

    return ServerFrame._(
      command: command as ServerCommand,
      headers: headers,
      body: body,
    );
  }

  static String _unescape(String value) {
    return value
        .replaceAll('\\n', '\n')
        .replaceAll('\\r', '\r')
        .replaceAll('\\c', ':');
  }
}
