import 'dart:convert';

class Game {
  final String status; // 게임 상태
  final int playerLast; // 마지막 플레이어 ID
  final int id; // 게임 ID
  final String roomCode; // 방 코드
  final DateTime createdTime; // 생성 시간
  final int playerFirst; // 첫 번째 플레이어 ID

  Game({
    required this.status,
    required this.playerLast,
    required this.id,
    required this.roomCode,
    required this.createdTime,
    required this.playerFirst,
  });

  /// JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      status: json['status'] as String,
      playerLast: json['player_last'] as int,
      id: json['id'] as int,
      roomCode: json['room_code'] as String,
      createdTime: DateTime.parse(json['created_time'] as String),
      playerFirst: json['player_first'] as int,
    );
  }

  /// 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'player_last': playerLast,
      'id': id,
      'room_code': roomCode,
      'created_time': createdTime.toIso8601String(),
      'player_first': playerFirst,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class DamageResponse {
  final String message; // 응답 메시지

  DamageResponse({
    required this.message,
  });

  /// JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory DamageResponse.fromJson(Map<String, dynamic> json) {
    return DamageResponse(
      message: json['message'] as String,
    );
  }

  /// 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
