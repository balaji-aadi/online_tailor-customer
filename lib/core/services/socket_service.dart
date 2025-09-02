import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? _socket;
  final String serverUrl;
  final String userId;

  SocketService({required this.serverUrl, required this.userId});

  void connect() {
    _socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
    });

    _socket?.connect();

    _socket?.onConnect((_) {
      print('Connected: ${_socket?.id}');
      joinRoom();
    });

    _socket?.onReconnect((_) => print('Reconnected: ${_socket?.id}'));
    _socket?.onConnectError((error) => print('Connection error: $error'));
    _socket?.onDisconnect((_) => print('Disconnected'));

    _socket?.on('joined', (data) => print('Joined room: $data'));
    _socket?.on('typing', (data) => print('Typing: ${data['from']}'));
    _socket?.on('stopTyping', (data) => print('Stopped typing: ${data['from']}'));
    _socket?.on('receiveMessage', (data) => print('Received message: $data'));
    _socket?.on(
        'messageRead', (data) => print('Message read: ${data['messageId']} by ${data['by']}'));
  }

  void joinRoom() => _socket?.emit('join', userId);
  void sendTyping(String toUserId) => _socket?.emit('typing', {'to': toUserId, 'from': userId});
  void sendStopTyping(String toUserId) =>
      _socket?.emit('stopTyping', {'to': toUserId, 'from': userId});
  void markMessageAsRead(String messageId) =>
      _socket?.emit('markRead', {'messageId': messageId, 'by': userId});
  void disconnect() => _socket?.disconnect();
  void dispose() => _socket?.dispose();
  IO.Socket? get socket => _socket;
}