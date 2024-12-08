// ignore_for_file: constant_identifier_names

abstract class Command {
  String get value;

  static Command fromString(String value) {
    switch (value) {
      case 'SEND':
        return ClientCommand.SEND;
      case 'SUBSCRIBE':
        return ClientCommand.SUBSCRIBE;
      case 'UNSUBSCRIBE':
        return ClientCommand.UNSUBSCRIBE;
      case 'BEGIN':
        return ClientCommand.BEGIN;
      case 'COMMIT':
        return ClientCommand.COMMIT;
      case 'ABORT':
        return ClientCommand.ABORT;
      case 'ACK':
        return ClientCommand.ACK;
      case 'NACK':
        return ClientCommand.NACK;
      case 'DISCONNECT':
        return ClientCommand.DISCONNECT;
      case 'CONNECT':
        return ClientCommand.CONNECT;
      case 'STOMP':
        return ClientCommand.STOMP;
      case 'CONNECTED':
        return ServerCommand.CONNECTED;
      case 'MESSAGE':
        return ServerCommand.MESSAGE;
      case 'RECEIPT':
        return ServerCommand.RECEIPT;
      case 'ERROR':
        return ServerCommand.ERROR;
      default:
        throw ArgumentError('Invalid command: $value');
    }
  }
}

enum ClientCommand implements Command {
  SEND,
  SUBSCRIBE,
  UNSUBSCRIBE,
  BEGIN,
  COMMIT,
  ABORT,
  ACK,
  NACK,
  DISCONNECT,
  CONNECT,
  STOMP;

  @override
  String get value => toString().split('.').last;
}

enum ServerCommand implements Command {
  CONNECTED,
  MESSAGE,
  RECEIPT,
  ERROR;

  @override
  String get value => toString().split('.').last;
}
