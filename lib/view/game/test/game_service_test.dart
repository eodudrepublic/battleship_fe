import 'package:flutter/material.dart';
import 'package:battleship_fe/service/game_service.dart';
import '../../../common/utils/logger.dart';

class GameServiceTest extends StatefulWidget {
  // TODO : attack = 1 -> user1_id가 공격, user2_id가 수비
  // TODO : performAttack -> getAttackStatus -> sendDamageStatus -> getDamageStatus -> endTurn 수행
  // TODO : endTurn 이후 공격, 수비가 바뀌는것 표시 -> 화면에 attack:, defense: 표시

  const GameServiceTest({super.key});

  @override
  State<GameServiceTest> createState() => _GameServiceTestState();
}

class _GameServiceTestState extends State<GameServiceTest> {
  /// 공격자(user1)와 수비자(user2) 예시
  int user1Id = 25;
  int user2Id = 50;

  /// attack = 1이면 user1이 공격자, 2면 user2가 공격자
  int attack = 1;

  /// 서버 통신을 담당할 GameService
  final GameService _gameService = GameService();

  /// 현재 생성된 방 코드
  String? _roomCode;

  /// 로그/결과를 화면에 표시하기 위한 텍스트
  String _resultText = '결과가 여기에 표시됩니다.';

  /// 편의상 현재 공격자 / 수비자 ID를 반환하는 getter
  int get _attackerId => (attack == 1) ? user1Id : user2Id;
  int get _defenderId => (attack == 1) ? user2Id : user1Id;

  /// UI 상단에 표시할 "현재 공격자", "현재 수비자" 문자열
  String get _attackerString =>
      attack == 1 ? 'User1($user1Id)' : 'User2($user2Id)';
  String get _defenderString =>
      attack == 1 ? 'User2($user2Id)' : 'User1($user1Id)';

  /// 화면에 로그를 표시하기 위한 헬퍼 메서드
  void _log(String message) {
    setState(() {
      _resultText = message;
    });
    Log.info(message); // 추가된 부분: 콘솔에 로그 출력
  }

  /// 1) 방 생성: 공격자(Host)가 방을 만들고, room_code를 받는다.
  Future<void> _createInvite() async {
    try {
      final result = await _gameService.createInvite(_attackerId);
      _roomCode = result['room_code'];
      _log(
          "방 생성 완료\nRoomCode: $_roomCode\nInviteLink: ${result['invite_link']}");
    } catch (e) {
      _log("방 생성 실패: $e");
    }
  }

  /// 2) 수비자(Guest)가 위에서 생성된 방에 참가한다.
  Future<void> _joinRoom() async {
    if (_roomCode == null) {
      _log("먼저 방을 생성(createInvite)하세요.");
      return;
    }
    try {
      final result = await _gameService.joinRoom(_roomCode!, _defenderId);
      _log("""방 참가 성공
is_matched: ${result["is_matched"]}
room_code: ${result["room_code"]}
opponent: ${result["opponent"]}
is_first: ${result["is_first"]}""");
    } catch (e) {
      _log("방 참가 실패: $e");
    }
  }

  /// 3) 공격/수비 단계 전체 플로우:
  ///    performAttack -> getAttackStatus -> sendDamageStatus -> getDamageStatus -> endTurn
  ///    순서대로 호출하여 테스트
  Future<void> _attackSequence() async {
    if (_roomCode == null) {
      _log("먼저 방을 생성(createInvite) 및 참가(joinRoom)하세요.");
      return;
    }

    // === (1) 공격자 -> performAttack
    try {
      final performAttackResult = await _gameService.performAttack(
        _roomCode!,
        _attackerId,
        _defenderId,
        'A', // 예시: 공격 위치 x
        1, // 예시: 공격 위치 y
      );

      _log(
          "공격 수행 성공: 공격 상태 = ${performAttackResult ? 'attack' : 'not attack'}");
    } catch (e) {
      _log("공격 수행 실패: $e");
      return;
    }

    // === (2) 수비자 -> getAttackStatus (공격 받았는지 확인)
    try {
      final attackStatusResponse =
          await _gameService.getAttackStatus(_roomCode!);
      _log("""
공격 상태 조회 성공:
attackStatus: ${attackStatusResponse.attackStatus}
attackPositionX: ${attackStatusResponse.attackPositionX}
attackPositionY: ${attackStatusResponse.attackPositionY}
damageStatus: ${attackStatusResponse.damageStatus}
      """);
    } catch (e) {
      _log("공격 상태 조회 실패: $e");
      return;
    }

    // === (3) 수비자 -> sendDamageStatus (실제로 맞았다고 가정)
    try {
      // 예: 대미지를 입혔다(isDamaged=true), 게임 종료는 아직 아님(isFinished=false)
      final isFinished = await _gameService.sendDamageStatus(
        _roomCode!,
        'A', // 공격 위치 x
        1, // 공격 위치 y
        true, // 대미지 여부
        false, // 게임 종료 여부
      );
      _log("데미지 리포트 전송 완료, 게임 종료 여부: $isFinished");
    } catch (e) {
      _log("데미지 상태 전달 실패: $e");
      return;
    }

    // === (4) 공격자 -> getDamageStatus (수비자가 준 대미지 결과 확인)
    try {
      final damageStatusResponse =
          await _gameService.getDamageStatus(_roomCode!);
      _log("""
공격 결과(대미지) 조회 성공:
attackStatus: ${damageStatusResponse.attackStatus}
damageStatus: ${damageStatusResponse.damageStatus}
      """);
    } catch (e) {
      _log("대미지 결과 조회 실패: $e");
      return;
    }

    // === (5) 공격자 -> endTurn (턴 종료 후, 공격/수비 전환)
    try {
      final endTurnResult = await _gameService.endTurn(_attackerId, _roomCode!);
      _log("턴 종료 요청: ${endTurnResult ? '성공' : '실패'}");

      if (endTurnResult) {
        // 공격자/수비자 교체
        setState(() {
          attack = (attack == 1) ? 2 : 1;
        });
      }
    } catch (e) {
      _log("턴 종료 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GameService 테스트 화면'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "현재 공격자: $_attackerString\n현재 수비자: $_defenderString\nRoomCode: $_roomCode",
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    attack = (attack == 1) ? 2 : 1;
                  });
                },
                child: const Text("공격자 <-> 수비자 변경"),
              ),
              const SizedBox(height: 16),

              // 1) 방 생성
              ElevatedButton(
                onPressed: _createInvite,
                child: const Text("방 생성 (createInvite)"),
              ),

              // 2) 방 참가
              ElevatedButton(
                onPressed: _joinRoom,
                child: const Text("방 참가 (joinRoom)"),
              ),

              const Divider(height: 32, thickness: 2),

              // 3) 전체 공격 시퀀스 (performAttack -> getAttackStatus -> sendDamageStatus -> getDamageStatus -> endTurn)
              ElevatedButton(
                onPressed: _attackSequence,
                child: const Text("공격 시퀀스 실행"),
              ),

              const SizedBox(height: 32),

              // 결과 로그 표시
              Text(
                _resultText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
