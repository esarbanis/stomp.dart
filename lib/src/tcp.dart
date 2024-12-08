import 'dart:io';
import 'dart:typed_data';

abstract class StompTcpClient {
  Future<void> connect(String host, int port, Duration timeout);
  void add(List<int> data);
  Stream<Uint8List> get onReceive;
  void close();
}

class StompTcpClientSocket implements StompTcpClient {
  StompTcpClientSocket();

  Socket? _socket;

  @override
  Future<void> connect(
    String host,
    int port,
    Duration timeout,
  ) async {
    _socket = await Socket.connect(host, port, timeout: timeout);
  }

  @override
  void add(List<int> data) {
    assert(_socket != null);

    _socket!.add(data);
  }

  @override
  Stream<Uint8List> get onReceive {
    assert(_socket != null);

    return _socket!.asBroadcastStream();
  }

  @override
  void close() {
    if (_socket != null) _socket!.close();
    _socket = null;
  }
}
