import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/server_url.dart';
import '../common/utils/logger.dart';
import '../model/attack_status_response.dart';
import '../model/game_models.dart';

class GameService {
  /// 방 생성 (방 코드 생성)
  ///
  /// 사용자의 ID를 기반으로 새로운 초대를 생성하고, 생성된 초대의 정보를 반환합니다.
  ///
  /// - Parameters:
  ///   - userId: 초대를 생성하는 사용자의 ID
  ///
  /// - Returns: 생성된 초대의 정보를 담은 `Map<String, String>`
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<Map<String, String>> createInvite(int userId) async {
    // API 엔드포인트 URL 구성
    final url = Uri.parse("$serverUrl:8000/invite/create?host_id=$userId");

    try {
      // POST 요청 보내기
      final response = await http.post(url);

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // JSON 응답을 Map<String, String>으로 변환
        final Map<String, String> result = {
          "room_code": jsonResponse["room_code"] as String,
          "invite_link": jsonResponse["invite_link"] as String,
        };

        Log.info("초대 생성 성공: $result");

        return result;
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("초대 생성 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("초대 생성 중 오류 발생: $e");
    }
  }

  /// 방 생성자 : 초대 수락 여부 확인
  ///
  /// 호스트 사용자 ID와 방 코드를 기반으로 초대 상태를 조회하고, 결과를 반환합니다.
  ///
  /// - Parameters:
  ///   - userId: 호스트 사용자의 ID
  ///   - roomCode: 초대를 조회할 방의 코드
  ///
  /// - Returns: 초대 상태 정보를 담은 `Map<String, dynamic>`
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<Map<String, dynamic>> getInvitationStatus(
      int userId, String roomCode) async {
    // API 엔드포인트 URL 구성
    final url = Uri.parse("$serverUrl:8000/invite/invitation-status");

    // 요청 헤더 설정
    final headers = {
      "Content-Type": "application/json",
    };

    // 요청 바디 구성
    final Map<String, dynamic> requestBody = {
      "host_id": userId,
      "room_code": roomCode,
    };

    try {
      // http.Request 객체 생성
      final request = http.Request('GET', url)
        ..headers.addAll(headers)
        ..body = jsonEncode(requestBody);

      // http.Client를 사용하여 요청 보내기
      final client = http.Client();
      final streamedResponse = await client.send(request);

      // 응답 본문 읽기
      final response = await http.Response.fromStream(streamedResponse);

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // 필요한 필드가 모두 있는지 확인
        if (jsonResponse.containsKey("is_matched") &&
            jsonResponse.containsKey("room_code") &&
            jsonResponse.containsKey("opponent") &&
            jsonResponse.containsKey("is_first")) {
          Log.info("초대 수락 여부 : ${jsonResponse["is_matched"]}");
          // JSON 응답을 Map<String, dynamic>으로 변환하여 반환
          return {
            "is_matched": jsonResponse["is_matched"] as bool,
            "room_code": jsonResponse["room_code"] as String,
            "opponent": jsonResponse["opponent"] as int,
            "is_first": jsonResponse["is_first"] as bool,
          };
        } else {
          // 응답 데이터 누락 시 예외 발생
          Log.error("응답 데이터 누락: ${response.body}");
          throw Exception("응답 데이터 누락: ${response.body}");
        }
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("초대 상태 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("초대 상태 조회 중 오류 발생: $e");
    }
  }

  /// 방 참가
  ///
  /// 주어진 방 코드와 사용자의 ID를 사용하여 방에 참가하고, 참가 결과를 반환합니다.
  ///
  /// - Parameters:
  ///   - roomCode: 참가할 방의 코드
  ///   - myId: 초대받은 사용자의 ID
  ///
  /// - Returns: 방 참가 결과를 담은 `Map<String, dynamic>`
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<Map<String, dynamic>> joinRoom(String roomCode, int myId) async {
    // API 엔드포인트 URL 구성
    final url =
        Uri.parse("$serverUrl:8000/invite/join-room").replace(queryParameters: {
      "room_code": roomCode,
      "invited_id": myId.toString(),
    });

    // 요청 헤더 설정
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      // GET 요청 보내기
      final response = await http.get(url, headers: headers);

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // 필요한 필드가 모두 있는지 확인
        if (jsonResponse.containsKey("is_matched") &&
            jsonResponse.containsKey("room_code") &&
            jsonResponse.containsKey("opponent") &&
            jsonResponse.containsKey("is_first")) {
          // 콘솔에 필요한 정보 출력
          Log.info("방 코드: ${jsonResponse['room_code']}");
          Log.info("상대방 ID: ${jsonResponse['opponent']}");
          Log.info("선공 여부: ${jsonResponse['is_first']}");

          // JSON 응답을 Map<String, dynamic>으로 변환하여 반환
          return {
            "is_matched": jsonResponse["is_matched"] as bool,
            "room_code": jsonResponse["room_code"] as String,
            "opponent": jsonResponse["opponent"] as int,
            "is_first": jsonResponse["is_first"] as bool,
          };
        } else {
          // 응답 데이터 누락 시 예외 발생
          throw Exception("응답 데이터 누락: ${response.body}");
        }
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("방 참가 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("방 참가 중 오류 발생: $e");
    }
  }

  /// status에 해당하는 게임 목록 조회
  ///
  /// 주어진 상태(`status`)에 해당하는 게임 목록을 서버로부터 조회하고, 결과를 반환합니다.
  ///
  /// - Parameters:
  ///   - status: 조회할 게임의 상태 (예: "before", "in_progress")
  ///
  /// - Returns: 상태에 맞는 게임 목록을 담은 `List<Game>`
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<List<Game>> getGamesByStatus(String status) async {
    // API 엔드포인트 URL 구성
    final url = Uri.parse("$serverUrl:8000/games/");

    // 요청 헤더 설정 (필요 시 추가)
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      // GET 요청 보내기
      final response = await http.get(url, headers: headers);

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final List<dynamic> jsonResponse = jsonDecode(response.body);

        // JSON 리스트를 Game 객체 리스트로 변환
        List<Game> games = jsonResponse
            .map((gameJson) => Game.fromJson(gameJson as Map<String, dynamic>))
            .toList();

        // 상태가 일치하는 게임들만 필터링
        List<Game> filteredGames =
            games.where((game) => game.status == status).toList();

        return filteredGames;
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("게임 목록 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("게임 목록 조회 중 오류 발생: $e");
    }
  }

  /// 수비자 : 공격 상태 조회 (공격 받았는지 확인)
  ///
  /// 주어진 방 코드를 사용하여 해당 방의 공격 상태를 조회하고, 결과를 반환합니다.
  ///
  /// - Parameters:
  ///   - roomCode: 공격 상태를 조회할 방의 코드
  ///
  /// - Returns: 공격 상태 정보를 담은 `AttackStatusResponse` 객체
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<AttackStatusResponse> getAttackStatus(String roomCode) async {
    // API 엔드포인트 URL 구성
    final url =
        Uri.parse("$serverUrl:8000/games/attack_status?room_code=$roomCode");

    // 요청 헤더 설정 (필요 시 추가)
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      // GET 요청 보내기
      final response = await http.get(url, headers: headers);

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // AttackStatusResponse 객체로 변환하여 반환
        return AttackStatusResponse.fromJson(jsonResponse);
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("공격 상태 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("공격 상태 조회 중 오류 발생: $e");
    }
  }

  /// 공격자 : 공격 수행
  ///
  /// 주어진 방 코드와 사용자의 정보를 사용하여 공격을 수행하고, 공격 상태에 따라 결과를 반환합니다.
  ///
  /// - Parameters:
  ///   - roomCode: 공격을 수행할 방의 코드
  ///   - myId: 공격을 수행하는 사용자의 ID (attacker)
  ///   - opponentId: 공격 대상 사용자의 ID (opponent)
  ///   - x: 공격 위치의 X좌표
  ///   - y: 공격 위치의 Y좌표
  ///
  /// - Returns: 공격 상태가 "attack"이면 `true`, 그렇지 않으면 `false`
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<bool> performAttack(
      String roomCode, int myId, int opponentId, String x, int y) async {
    // API 엔드포인트 URL 구성
    final url = Uri.parse("$serverUrl:8000/games/attack");

    // 요청 헤더 설정
    final headers = {
      "Content-Type": "application/json",
    };

    // 요청 바디 구성
    final Map<String, dynamic> requestBody = {
      "room_code": roomCode,
      "attacker": myId,
      "opponent": opponentId,
      "attack_position_x": x,
      "attack_position_y": y,
    };

    try {
      // POST 요청 보내기
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // AttackStatusResponse 객체로 변환
        AttackStatusResponse attackStatus =
            AttackStatusResponse.fromJson(jsonResponse);

        // "attack_status"가 "attack"인지 확인
        if (attackStatus.attackStatus == "attack") {
          return true;
        } else {
          return false;
        }
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("공격 수행 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("공격 수행 중 오류 발생: $e");
    }
  }

  /// 공격자 : 공격 결과 조회 (데미지 결과 받을때까지 대기)
  ///
  /// 주어진 방 코드를 사용하여 해당 방의 대미지 상태를 조회하고, 결과를 반환합니다.
  ///
  /// - Parameters:
  ///   - roomCode: 대미지 상태를 조회할 방의 코드
  ///
  /// - Returns: 대미지 상태 정보를 담은 `AttackStatusResponse` 객체
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<AttackStatusResponse> getDamageStatus(String roomCode) async {
    // API 엔드포인트 URL 구성
    final url =
        Uri.parse("$serverUrl:8000/games/damage_status?room_code=$roomCode");

    // 요청 헤더 설정 (필요 시 추가)
    final headers = {
      "Content-Type": "application/json",
    };

    try {
      // GET 요청 보내기
      final response = await http.get(url, headers: headers);

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // AttackStatusResponse 객체로 변환하여 반환
        return AttackStatusResponse.fromJson(jsonResponse);
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("대미지 상태 조회 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("대미지 상태 조회 중 오류 발생: $e");
    }
  }

  /// 수비자 : 데미지 리포트 전송
  ///
  /// 주어진 방 코드와 공격 위치, 대미지 여부, 게임 종료 여부를 사용하여 대미지 상태를 전달하고, 결과에 따라 반환값을 결정합니다.
  ///
  /// - Parameters:
  ///   - roomCode: 대미지를 전달할 방의 코드
  ///   - x: 공격 위치의 X좌표
  ///   - y: 공격 위치의 Y좌표
  ///   - isDamaged: 대미지를 입혔는지 여부
  ///   - isFinished: 게임이 끝났는지 여부
  ///
  /// - Returns: `"message"`가 `"finished"`이면 `true`, `"not finished"`이면 `false`
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<bool> sendDamageStatus(
      String roomCode, String x, int y, bool isDamaged, bool isFinished) async {
    // API 엔드포인트 URL 구성
    final url = Uri.parse("$serverUrl:8000/games/damage");

    // 요청 헤더 설정
    final headers = {
      "Content-Type": "application/json",
    };

    // damage_status 설정
    final String damageStatus = isDamaged ? "damaged" : "missed";

    // 요청 바디 구성
    final Map<String, dynamic> requestBody = {
      "room_code": roomCode,
      "attack_position_x": x,
      "attack_position_y": y,
      "damage_status": damageStatus,
      "is_finished": isFinished,
    };

    try {
      // POST 요청 보내기
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // DamageResponse 객체로 변환
        DamageResponse damageResponse = DamageResponse.fromJson(jsonResponse);

        // "message"에 따라 반환값 결정
        if (damageResponse.message == "finished") {
          return true;
        } else if (damageResponse.message == "not finished") {
          return false;
        } else {
          throw Exception("예상치 못한 응답 메시지: ${damageResponse.message}");
        }
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("대미지 상태 전달 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("대미지 상태 전달 중 오류 발생: $e");
    }
  }

  /// 공격자 : 턴 종료
  ///
  /// 주어진 사용자 ID와 방 코드를 사용하여 턴을 종료하고, 결과에 따라 반환값을 결정합니다.
  ///
  /// - Parameters:
  ///   - myId: 현재 사용자의 ID
  ///   - roomCode: 턴을 종료할 방의 코드
  ///
  /// - Returns: 응답의 `room_code`가 매개변수의 `room_code`와 일치하고, `opponent`가 `my_id`이면 `true`, 그렇지 않으면 `false`
  ///
  /// - Throws: 서버 요청 실패 시 예외 발생
  Future<bool> endTurn(int myId, String roomCode) async {
    // API 엔드포인트 URL 구성
    final url = Uri.parse("$serverUrl:8000/games/end-turn?room_code=$roomCode");

    try {
      // POST 요청 보내기
      final response = await http.post(url);

      // 응답 상태 코드가 200 (성공)인 경우
      if (response.statusCode == 200) {
        // 응답 바디를 JSON으로 디코딩
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // AttackStatusResponse 객체로 변환
        AttackStatusResponse attackStatus =
            AttackStatusResponse.fromJson(jsonResponse);

        // 응답의 room_code가 요청한 room_code와 일치하고, opponent가 my_id인지 확인
        if (attackStatus.roomCode == roomCode &&
            attackStatus.opponent == myId) {
          return true;
        } else {
          return false;
        }
      } else {
        // 실패한 경우, 상태 코드와 함께 예외 발생
        throw Exception("턴 종료 실패: ${response.statusCode}");
      }
    } catch (e) {
      // 요청 중 발생한 예외 처리
      throw Exception("턴 종료 중 오류 발생: $e");
    }
  }
}
