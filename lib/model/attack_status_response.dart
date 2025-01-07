import 'dart:convert';

class AttackStatusResponse {
  final String roomCode; // 방 코드
  final int attacker; // 현재 공격자 user_id
  final int opponent; // 현재 수비자 user_id
  final String attackPositionX; // 현재 공격 위치 x좌표
  final int attackPositionY; // 현재 공격 위치 y좌표
  final String attackStatus; // 공격 상태 ('not yet' / 'attack')
  final String
      damageStatus; // 대미지 상태 ('not yet' / 'damaged' / 'missed' / 'finished')

  AttackStatusResponse({
    required this.roomCode,
    required this.attacker,
    required this.opponent,
    required this.attackPositionX,
    required this.attackPositionY,
    required this.attackStatus,
    required this.damageStatus,
  });

  /// JSON 데이터를 객체로 변환하는 팩토리 생성자
  factory AttackStatusResponse.fromJson(Map<String, dynamic> json) {
    return AttackStatusResponse(
      roomCode: json['room_code'] as String,
      attacker: json['attacker'] as int,
      opponent: json['opponent'] as int,
      attackPositionX: json['attack_position_x'] as String,
      attackPositionY: json['attack_position_y'] as int,
      attackStatus: json['attack_status'] as String,
      damageStatus: json['damage_status'] as String,
    );
  }

  /// 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'room_code': roomCode,
      'attacker': attacker,
      'opponent': opponent,
      'attack_position_x': attackPositionX,
      'attack_position_y': attackPositionY,
      'attack_status': attackStatus,
      'damage_status': damageStatus,
    };
  }

  // TODO : attackStatus를 통해 내가 공격받았는지 반환하는 메서드 생성
  // TODO : attack_position_x, attack_position_y를 통해 상대의 공격 위치를 반환하는 메서드 생성

  // TODO : damageStatus를 통해 상대에게 대미지를 입혔는지 반환하는 메서드 생성

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
