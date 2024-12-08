const String kDefaultHost = 'localhost';
const int kDefaultPort = 61613;
const String kDefaultLogin = 'admin';
const String kDefaultPasscode = 'admin';
const Duration kDefaultHeartbeat = Duration(seconds: 10);
const Duration kDefaultTimeout = Duration(seconds: 5);

class StompClientOptions {
  const StompClientOptions({
    this.host = kDefaultHost,
    this.port = kDefaultPort,
    this.login = kDefaultLogin,
    this.passcode = kDefaultPasscode,
    this.heartbeat = kDefaultHeartbeat,
    this.timeout = kDefaultTimeout,
  });

  final String host;
  final int port;
  final String login;
  final String passcode;
  final Duration heartbeat;
  final Duration timeout;
}
