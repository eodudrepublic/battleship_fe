import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/server_url.dart';
import '../common/utils/logger.dart';

class GameService {
  /// -----------------------------
  /// 방 생성 : createInvite
  /// -----------------------------
  /// POST /invite/create?host_id={userId}
  /// - 참여 중인 방 없는 경우: { "room_code": "xxxxxx" }
  /// - 이미 방이 있는 경우: { "message": "already exists" }
  ///
  /// - Returns:
  ///   {
  ///     "room_code": "e722b949",   // 방 코드 (성공 시)
  ///     "message": "already exists" // 이미 방이 있을 시
  ///   }
  Future<Map<String, dynamic>> createInvite(int userId) async {
    final url = Uri.parse("$serverUrl:8000/invite/create?host_id=$userId");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // 성공 시 { "room_code": "..."} 또는 { "message": "already exists" }
        // "room_code"가 없을 수도 있으므로, Map으로 그대로 리턴
        Log.info("방 생성 응답: $jsonResponse");
        return jsonResponse;
      } else {
        throw Exception("초대 생성 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("초대 생성 중 오류 발생: $e");
    }
  }

  /// -----------------------------
  /// 초대 상태 확인 : getInvitationStatus
  /// -----------------------------
  /// GET /invite/invitation-status?room_code=xxx&host_id=yyy
  ///
  /// - 응답:
  ///   - 수락 전:  { "is_matched": false, "room_code": "", "opponent": 0, "is_first": false }
  ///   - 수락 후:  { "is_matched": true,  "room_code": "xxxx", "opponent": enemy_id, "is_first": false }
  Future<Map<String, dynamic>> getInvitationStatus(
      int userId, String roomCode) async {
    // query 파라미터로 전달
    final url = Uri.parse(
      "$serverUrl:8000/invite/invitation-status?room_code=$roomCode&host_id=$userId",
    );

    try {
      // GET 요청 (바디 없음)
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        Log.info("초대 상태 조회 응답: $jsonResponse");
        return jsonResponse;
      } else {
        throw Exception("초대 상태 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("초대 상태 조회 중 오류 발생: $e");
    }
  }

  /// -----------------------------
  /// status에 해당하는 게임 목록 조회 : 주어진 상태(`status`)에 해당하는 게임 목록을 서버로부터 조회하고, 결과를 반환합니다.
  /// -----------------------------
  /// GET /games/
  ///
  /// - Parameters:
  ///   - status: 조회할 게임의 상태 (예: "before", "in_progress", "completed")
  ///
  /// - Returns: 상태에 맞는 게임 목록을 담은 `List<Map<String, dynamic>>`
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<List<Map<String, dynamic>>> getGamesByStatus(String status) async {
    final url = Uri.parse("$serverUrl:8000/games/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        // 각 요소를 Map<String,dynamic>으로 변환
        final List<Map<String, dynamic>> allGames =
            jsonResponse.map((e) => e as Map<String, dynamic>).toList();

        // "status" 값이 일치하는 게임만 필터링
        final List<Map<String, dynamic>> filteredGames =
            allGames.where((game) => game["status"] == status).toList();

        Log.info("게임 목록 조회 응답: $filteredGames");
        return filteredGames;
      } else {
        throw Exception("게임 목록 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("게임 목록 조회 중 오류 발생: $e");
    }
  }

  /// -----------------------------
  /// 방 참가 : joinRoom
  /// -----------------------------
  /// GET /invite/join-room?room_code=xxx&invited_id=yyy
  ///
  /// - 응답:
  ///   {
  ///     "is_matched": true,
  ///     "room_code": "xxxxxx",
  ///     "opponent": enemy_id,
  ///     "is_first": true
  ///   }
  Future<Map<String, dynamic>> joinRoom(String roomCode, int myId) async {
    final url = Uri.parse("$serverUrl:8000/invite/join-room").replace(
      queryParameters: {
        "room_code": roomCode,
        "invited_id": myId.toString(),
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        Log.info("방 참가 응답: $jsonResponse");
        return jsonResponse;
      } else {
        throw Exception("방 참가 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("방 참가 중 오류 발생: $e");
    }
  }

  /// -----------------------------
  /// 보드 배치 정보 전송 : sendBoard
  /// -----------------------------
  /// POST /games/board
  /// body: { "room_code": "xxx", "user_id": my_id, "board": ["C3","D4",...] }
  ///
  /// 응답: null (200 OK)
  Future<void> sendBoard(
      String roomCode, int userId, List<String> board) async {
    final url = Uri.parse("$serverUrl:8000/games/board");
    final headers = {
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "room_code": roomCode,
      "user_id": userId,
      "board": board,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Log.info("보드 배치 정보 전송 성공: $board");
        // 응답 바디는 null
      } else {
        throw Exception("보드 배치 정보 전송 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("보드 배치 정보 전송 중 오류 발생: $e");
    }
  }

  /// -----------------------------
  /// 방 상태 확인 : getGameStatus
  /// -----------------------------
  /// GET /games/status?room_code=xxx
  ///
  /// - 응답:
  ///   {
  ///     "player_last": user1_id,
  ///     "first_board": ["C3","D4"],
  ///     "player_first": user2_id,
  ///     "last_board": ["A1","B2"],
  ///     "room_code": "xxx",
  ///     "status": "in_progress" // or "before"/"completed"
  ///   }
  Future<Map<String, dynamic>> getGameStatus(String roomCode) async {
    final url = Uri.parse("$serverUrl:8000/games/status?room_code=$roomCode");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        Log.info("게임 상태 조회 응답: $jsonResponse");
        return jsonResponse;
      } else {
        throw Exception("게임(방) 상태 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("게임(방) 상태 조회 중 오류 발생: $e");
    }
  }

  /// -----------------------------
  /// 수비자 : 데미지 상태 조회 (Damage)
  /// -----------------------------
  /// POST /games/damage?room_code=xxx
  /// 응답:
  ///   - 공격 전: { "damage_status": "not yet", "attack_position": "" }
  ///   - 공격 후: { "damage_status": "damaged"/"missed", "attack_position": "A1" }
  ///   - game_status: "in_progress"/"completed"
  ///
  /// => FE(수비자)는 이 API를 통해 "내가 공격받았는지" 확인 가능
  Future<Map<String, dynamic>> checkDamageStatusAsDefender(
      String roomCode) async {
    final url = Uri.parse("$serverUrl:8000/games/damage?room_code=$roomCode");

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        Log.info("수비자 Damage 상태 조회 응답: $jsonResponse");
        return jsonResponse;
      } else {
        throw Exception("수비자 Damage 상태 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("수비자 Damage 상태 조회 중 오류 발생: $e");
    }
  }

  /// -----------------------------
  /// 공격자 : 공격 수행
  /// -----------------------------
  /// POST /games/attack
  /// body: {
  ///   "room_code": "xxx",
  ///   "attacker": my_id,
  ///   "opponent": enemy_id,
  ///   "attack_position": "A1"
  /// }
  ///
  /// 응답:
  ///   {
  ///     "damage_status": "damaged"/"missed",
  ///     "game_status": "in_progress"/"completed",
  ///     "attack_position": "A1",
  ///     ...
  ///   }
  ///
  /// => 서버가 공격 결과를 즉시 계산해 돌려줌
  Future<Map<String, dynamic>> performAttack(
    String roomCode,
    int attacker,
    int opponent,
    String attackPosition,
  ) async {
    final url = Uri.parse("$serverUrl:8000/games/attack");
    final headers = {
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "room_code": roomCode,
      "attacker": attacker,
      "opponent": opponent,
      "attack_position": attackPosition,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        Log.info("공격 수행 응답: $jsonResponse");
        return jsonResponse; // damage_status, game_status 등
      } else {
        throw Exception("공격 수행 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("공격 수행 중 오류 발생: $e");
    }
  }

  /// -----------------------------
  /// 턴 넘기기 : endTurn
  /// -----------------------------
  /// POST /games/end-turn?room_code=xxx
  /// 응답: null (200 OK)
  Future<void> endTurn(String roomCode) async {
    final url = Uri.parse("$serverUrl:8000/games/end-turn?room_code=$roomCode");

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        Log.info("턴 종료 성공");
        // body 없음
      } else {
        throw Exception("턴 종료 실패: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("턴 종료 중 오류 발생: $e");
    }
  }
}
