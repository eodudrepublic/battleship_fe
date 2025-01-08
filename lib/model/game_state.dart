import '../common/utils/logger.dart';

/// 게임 진행에 필요한 상태들을 저장하는 싱글턴 클래스
class GameState {
  // 싱글턴 인스턴스
  static final GameState _instance = GameState._internal();

  // 외부에서 new로 생성 못하도록 factory 사용
  factory GameState() {
    return _instance;
  }

  // 프라이빗 생성자
  GameState._internal();

  // -----------------------------
  // (1) 필드들
  // -----------------------------
  bool? isFirst; // 내가 선공인지 여부
  bool? isMyTurn; // 지금 내 차례(공격턴)인지 여부
  int? opponentId; // 상대방 user_id
  String? roomCode; // 현재 방 코드
  bool isGameOver = false; // 게임 종료 여부
  bool isSoloGame = false; // 솔로 게임 여부

  // -----------------------------
  // (2) 메서드들
  // -----------------------------
  /// 게임 초기 상태 세팅
  void setGameState({
    required bool isFirstPlayer,
    required int opponentId,
    required String roomCode,
    bool solo = false,
  }) {
    isFirst = isFirstPlayer;
    // 선공이면 내 턴(true), 후공이면 내 턴(false)으로 시작
    isMyTurn = isFirstPlayer;
    this.opponentId = opponentId;
    this.roomCode = roomCode;
    isGameOver = false;
    isSoloGame = solo;

    Log.info("[GameState] setGameState:"
        " isFirst=$isFirst, isMyTurn=$isMyTurn, "
        " opponentId=$opponentId, roomCode=$roomCode, isSoloGame=$isSoloGame");
  }

  /// 턴 교대 : 내 턴 <-> 상대 턴
  void toggleTurn() {
    if (isMyTurn == null) return;
    isMyTurn = !isMyTurn!;
    Log.info("[GameState] 토글 턴 -> isMyTurn=$isMyTurn");
  }

  /// 게임 종료 설정
  void endGame() {
    isGameOver = true;
    Log.info("[GameState] 게임 종료 isGameOver=$isGameOver");
  }

  /// 전체 필드 초기화
  void clear() {
    isFirst = null;
    isMyTurn = null;
    opponentId = null;
    roomCode = null;
    isGameOver = false;
    isSoloGame = false;
    Log.info("[GameState] 클리어 - 게임 상태 초기화");
  }
}
