class StompMessage {
  final Map<String, String> headers;
  final String body;

  StompMessage(this.headers, this.body);

  @override
  String toString() {
    return 'StompMessage{headers: $headers, body: $body}';
  }
}
