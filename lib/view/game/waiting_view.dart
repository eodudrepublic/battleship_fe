import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../model/game_state.dart';
import '../../model/user_model.dart';
import '../../service/game_service.dart';

class WaitingView extends StatefulWidget {
  final String? roomCode;
  const WaitingView({super.key, this.roomCode = ''});

  @override
  State<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<WaitingView> {
  final gameService = GameService();
  final appUserId = AppUser().id ?? 0;

  Timer? _inviteCheckTimer;

  /// 초대 상태를 주기적으로 확인하는 타이머를 시작
  void _startInviteCheckTimer() {
    // 5초에 한 번씩 폴링
    _inviteCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      // 화면이 dispose되었다면(Unmounted) 타이머 취소
      if (!mounted) {
        timer.cancel();
        return;
      }

      final rCode = GameState().roomCode;
      if (rCode == null || rCode.isEmpty) return;

      final status = await gameService.getInvitationStatus(appUserId, rCode);
      Log.info("초대 상태 조회: $status");

      // 예: { "is_matched": false, ... } or { "is_matched": true, "opponent": 123, "is_first": true }
      if (status["is_matched"] == true) {
        // (1) 매칭 완료
        final opponentId = status["opponent"] as int;
        final isFirst = status["is_first"] as bool;

        // (2) GameState 저장
        GameState().setGameState(
          isFirstPlayer: isFirst,
          opponentId: opponentId,
          roomCode: rCode,
        );

        // (3) 다음 화면으로 이동 (배치 화면)
        timer.cancel();
        Get.offNamed("/deploy"); // 배치 화면으로 이동
      }
    });
  }

  /// 방 생성 함수
  Future<void> _createRoom() async {
    try {
      final result = await gameService.createInvite(appUserId);
      if (result.containsKey('room_code')) {
        final rCode = result['room_code'] as String;
        GameState().roomCode = rCode;

        // 화면 표시용 roomCode 갱신
        setState(() {
          // widget.roomCode는 final이라 바꿀 수 없으므로
          // 별도 state 변수로 관리하거나, 그냥 Widget build 시 rCode를 사용
        });
      } else if (result.containsKey('message')) {
        // 예: {"message":"already exists"}
        Log.info("이미 방이 존재: ${result['message']}");
        // 적절히 처리 (SnackBar, Alert 등)
      }
    } catch (e) {
      Log.error("방 생성 실패: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // (1) roomCode가 없다면 createInvite 호출
    if (widget.roomCode == null || widget.roomCode!.isEmpty) {
      _createRoom();
    } else {
      // 이미 roomCode가 넘어왔다면, GameState에 저장
      GameState().roomCode = widget.roomCode;
    }

    // (2) 폴링 타이머 시작
    _startInviteCheckTimer();
  }

  @override
  void dispose() {
    // 화면 종료 시 타이머 해제
    _inviteCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedRoomCode = GameState().roomCode ?? widget.roomCode ?? '';

    return Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "상대를 기다리는 중",
                style: TextStyle(
                    fontFamily: 'Sejong',
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text("방코드: $displayedRoomCode",
                  style: TextStyle(
                      fontFamily: 'Sejong',
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(
                height: 5.sp,
              ),
              Image.asset(
                'assets/icons/loading.gif',
                width: 0.8.sw,
                height: 0.8.sw,
              ),
              SizedBox(
                height: 20.sp,
              ),
              SizedBox(
                width: 0.55.sw,
                height: 0.075.sh,
                child: ElevatedButton(
                  onPressed: () async {
                    Log.info('방 코드 복사하기');
                    final displayedRoomCode =
                        GameState().roomCode ?? widget.roomCode ?? '';
                    if (displayedRoomCode.isNotEmpty) {
                      await Clipboard.setData(
                          ClipboardData(text: displayedRoomCode));
                      Get.snackbar(
                        '복사 완료',
                        '방 코드가 클립보드에 복사되었습니다.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.black54,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    } else {
                      Get.snackbar(
                        '복사 실패',
                        '복사할 방 코드가 없습니다.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.timeWidgetColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // 테두리 곡률 설정 : 12 픽셀(Pixel)
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '방 코드 복사하기',
                    style: TextStyle(
                      fontFamily: 'Sejong',
                      color: Colors.black,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.sp,
              ),
              SizedBox(
                width: 0.55.sw,
                height: 0.075.sh,
                child: ElevatedButton(
                  onPressed: () {
                    Log.info('방 만들기 취소 -> Get.back()');
                    // TODO : (DELETE) /games/delete 적용 -> 만들어진 방 삭제
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.timeWidgetColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.sp, vertical: 5.sp),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // 테두리 곡률 설정 : 12 픽셀(Pixel)
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '취소하기',
                    style: TextStyle(
                        fontFamily: 'Sejong',
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
