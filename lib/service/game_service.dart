import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/server_url.dart';

// 턴 진행시 서버에서 전달받을 JSON 데이터 형식
// class AttackStatusResponse(BaseModel):
// id: int -> 신경쓰지 않아도 됨
// room_code: str -> 방 코드
// attacker: int -> 현재 공격자 user_id
// opponent: int -> 현재 수비자 user_id
// attack_position_x: str -> 현재 공격 위치 x좌표
// attack_position_y: int -> 현재 공격 위치 y좌표
// attack_status: str ('not yet' / 'attack')
// damage_status: str ('not yet' / 'damaged' / 'missed')
// TODO : 서버 통신 이용을 위한 각 메서드에 주석(설명) 자세히 추가

class GameService {
  // 대기열에 user 추가
  Future<Map<String, dynamic>> addUserToQueue(int userId) async {
    final url = Uri.parse("$serverUrl:8000/matching/add?user_id=$userId");
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to add user to queue: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error adding user to queue: $e");
    }
  }

  /// TODO : 매칭 성사 + 게임 시작 (방 생성) -> 현재 코드 수정 중
  // 매칭 성사 시 매칭 성사 여부, 방 코드, 상대 user_id, 선공 여부 정보 수신
  Future<Map<String, dynamic>> matchUsers() async {
    final url = Uri.parse("$serverUrl:8000/matching/match");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to match users: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error matching users: $e");
    }
  }

  // 대기열에서 user 삭제
  Future<Map<String, dynamic>> removeUserFromQueue(int userId) async {
    final url = Uri.parse("$serverUrl:8000/matching/remove/?user_id=$userId");
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to remove user from queue: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error removing user from queue: $e");
    }
  }

  // 모든 게임 조회
  Future<List<dynamic>> getAllGames() async {
    final url = Uri.parse("$serverUrl:8000/games/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch games: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching games: $e");
    }
  }

  /// 1-1. 수비 : 공격 상태 조회 -> 공격받았는지 확인
  Future<Map<String, dynamic>> getAttackStatus(String roomCode) async {
    final url =
        Uri.parse("$serverUrl:8000/games/attack_status?room_code=$roomCode");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to fetch attack status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching attack status: $e");
    }
  }

  /// 1-2. 공격 : 공격
  Future<Map<String, dynamic>> attack(String roomCode, int attacker,
      int opponent, String posX, int posY) async {
    final url = Uri.parse("$serverUrl:8000/games/attack");
    final payload = {
      "room_code": roomCode,
      "attacker": attacker,
      "opponent": opponent,
      "attack_position_x": posX,
      "attack_position_y": posY,
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to perform attack: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error performing attack: $e");
    }
  }

  /// 2-1. 공격 : 대미지 상태 조회
  Future<Map<String, dynamic>> getDamageStatus(String roomCode) async {
    final url =
        Uri.parse("$serverUrl:8000/games/damage_status?room_code=$roomCode");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Failed to fetch damage status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching damage status: $e");
    }
  }

  /// 2-2. 수비 : 대미지
  Future<Map<String, dynamic>> sendDamage(String roomCode, String posX,
      int posY, String damageStatus, bool isFinished) async {
    final url = Uri.parse("$serverUrl:8000/games/damage");
    final payload = {
      "room_code": roomCode,
      "attack_position_x": posX,
      "attack_position_y": posY,
      "damage_status": damageStatus,
      "is_finished": isFinished,
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to send damage: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error sending damage: $e");
    }
  }

  /// 3. 턴 종료
  Future<Map<String, dynamic>> endTurn(String roomCode) async {
    final url = Uri.parse("$serverUrl:8000/games/end-turn?room_code=$roomCode");
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to end turn: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error ending turn: $e");
    }
  }
}
