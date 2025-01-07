import 'package:flutter/material.dart';
import 'package:battleship_fe/service/game_service.dart';
import '../../../common/utils/logger.dart';

class GameServiceTest extends StatefulWidget {
  const GameServiceTest({super.key});

  @override
  State<GameServiceTest> createState() => _GameServiceTestState();
}

class _GameServiceTestState extends State<GameServiceTest> {
  /// 예시용: 공격자(user1), 수비자(user2)
  int user1Id = 25;
  int user2Id = 50;

  /// attack = 1이면 user1이 공격자, 2면 user2가 공격자
  int attack = 1;

  /// 서버 통신을 담당할 GameService
  final GameService _gameService = GameService();

  /// 현재 생성된 방 코드
  String? _roomCode;

  /// 테스트 로그를 화면에 표시하기 위한 문자열
  String _resultText = '결과가 여기에 표시됩니다.';

  /// 헬퍼: 현재 공격자 / 수비자 ID
  int get _attackerId => (attack == 1) ? user1Id : user2Id;
  int get _defenderId => (attack == 1) ? user2Id : user1Id;

  /// 헬퍼: 표시용 문자열
  String get _attackerString =>
      (attack == 1) ? 'User1($user1Id)' : 'User2($user2Id)';
  String get _defenderString =>
      (attack == 1) ? 'User2($user2Id)' : 'User1($user1Id)';

  /// 로그를 표시하고 콘솔에도 찍음
  void _log(String message) {
    setState(() {
      _resultText = message;
    });
    Log.info(message);
  }

  /// -----------------------------
  /// (3) 방 생성 : createInvite
  /// -----------------------------
  Future<void> _createInvite() async {
    try {
      final result = await _gameService.createInvite(_attackerId);
      if (result.containsKey('room_code')) {
        _roomCode = result['room_code'];
        _log("방 생성 완료, roomCode: $_roomCode");
      } else if (result.containsKey('message') &&
          result['message'] == 'already exists') {
        _log("이미 참여 중인 방이 있습니다: ${result['message']}");
      } else {
        _log("알 수 없는 응답: $result");
      }
    } catch (e) {
      _log("방 생성 실패: $e");
    }
  }

  /// -----------------------------
  /// (5) 초대 승인 : joinRoom
  /// -----------------------------
  Future<void> _joinRoom() async {
    if (_roomCode == null) {
      _log("방 코드가 없습니다. 먼저 방을 생성하세요.");
      return;
    }
    try {
      final result = await _gameService.joinRoom(_roomCode!, _defenderId);
      _log("방 참가 성공: $result");
    } catch (e) {
      _log("방 참가 실패: $e");
    }
  }

  /// 예시: 보드 배치 전송 (6)
  Future<void> _sendBoard() async {
    if (_roomCode == null) {
      _log("방 코드가 없습니다. 먼저 방을 생성하세요.");
      return;
    }

    try {
      // 예: 내가 "A1", "B2"에 뭔가를 배치했다고 가정
      final myBoard = ["A1", "B2"];
      await _gameService.sendBoard(_roomCode!, _attackerId, myBoard);
      _log("보드 배치 전송 완료!: attackerId=$_attackerId");
    } catch (e) {
      _log("보드 배치 전송 실패: $e");
    }
  }

  /// 예시: 방 상태 확인 (7)
  Future<void> _checkGameStatus() async {
    if (_roomCode == null) {
      _log("방 코드가 없습니다. 먼저 방을 생성하세요.");
      return;
    }

    try {
      final status = await _gameService.getGameStatus(_roomCode!);
      _log("방 상태 확인: $status");
    } catch (e) {
      _log("방 상태 조회 실패: $e");
    }
  }

  /// -----------------------------
  /// (9) 공격 -> (8) 수비 -> (10) 턴종료
  /// -----------------------------
  /// 간단히 공격자가 공격하고, 수비자가 damage 조회, 다시 턴 종료하는 흐름 예시
  Future<void> _attackAndCheckDamage() async {
    if (_roomCode == null) {
      _log("방 코드가 없습니다. 먼저 방을 생성하고, 참가하세요.");
      return;
    }

    // 1) 공격자가 공격
    try {
      // 예: "A1"에 공격
      final attackResult = await _gameService.performAttack(
        _roomCode!,
        _attackerId,
        _defenderId,
        "A1",
      );
      // 공격 결과 (damage_status, game_status 등) 확인
      _log("공격 결과: $attackResult");
    } catch (e) {
      _log("공격 수행 실패: $e");
      return;
    }

    // 2) 수비자가 방어/데미지 상태 확인
    try {
      final defenseResult =
          await _gameService.checkDamageStatusAsDefender(_roomCode!);
      _log("수비자 측 damage 상태: $defenseResult");
    } catch (e) {
      _log("데미지 상태 조회 실패: $e");
      return;
    }

    // 3) 공격자 -> 턴 종료
    try {
      await _gameService.endTurn(_roomCode!);
      _log("턴 종료 완료. 공격/수비 교대됩니다.");

      // 실제 로직에서는 서버가 내부적으로 next turn을 진행.
      // 여기서는 단순히 local 변수 swap
      setState(() {
        attack = (attack == 1) ? 2 : 1;
      });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "현재 공격자: $_attackerString\n"
              "현재 수비자: $_defenderString\n"
              "RoomCode: $_roomCode",
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  attack = (attack == 1) ? 2 : 1;
                });
                _log("공격자/수비자 교체: $_attackerString -> $_defenderString");
              },
              child: const Text("공격자 <-> 수비자 변경"),
            ),
            const SizedBox(height: 16),

            // 1) 방 생성
            ElevatedButton(
              onPressed: _createInvite,
              child: const Text("방 생성 (createInvite)"),
            ),

            // 2) 초대 승인 (방 참가)
            ElevatedButton(
              onPressed: _joinRoom,
              child: const Text("방 참가 (joinRoom)"),
            ),

            // 6) 보드 배치
            ElevatedButton(
              onPressed: _sendBoard,
              child: const Text("보드 배치 (sendBoard)"),
            ),

            // 7) 방 상태 확인
            ElevatedButton(
              onPressed: _checkGameStatus,
              child: const Text("방 상태 확인 (getGameStatus)"),
            ),

            const Divider(thickness: 2, height: 32),

            // 9) 공격 -> 8) 수비 -> 10) 턴 종료 (간단 시퀀스)
            ElevatedButton(
              onPressed: _attackAndCheckDamage,
              child: const Text("공격 + 수비 확인 + 턴 종료"),
            ),

            const SizedBox(height: 24),

            // 결과 로그 표시
            Text(
              _resultText,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
