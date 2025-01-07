import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../model/game_state.dart';
import '../../model/user_model.dart';
import '../../service/game_service.dart';

class EnteringView extends StatefulWidget {
  const EnteringView({Key? key}) : super(key: key);

  @override
  State<EnteringView> createState() => _EnteringViewState();
}

class _EnteringViewState extends State<EnteringView> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<String> _inputValue = ValueNotifier<String>('');

  final gameService = GameService();
  final myId = AppUser().id ?? 0;

  /// 대기중인 방 목록
  List<Map<String, dynamic>> _waitingRooms = [];

  @override
  void initState() {
    super.initState();
    // 진입 시점에 "before" 상태의 방들 불러오기
    _loadWaitingRooms();

    // 텍스트필드 변화를 _inputValue에 반영
    _controller.addListener(() {
      _inputValue.value = _controller.text;
    });
  }

  Future<void> _loadWaitingRooms() async {
    try {
      final waitingGames = await gameService.getGamesByStatus("before");
      // waitingGames : List<Map<String,dynamic>>
      setState(() {
        _waitingRooms = waitingGames;
      });
      Log.info("대기중인 방 목록: $_waitingRooms");
    } catch (e) {
      Log.error("대기중인 방 목록 조회 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // (1) 상단 TextField (방 코드 직접 입력)
              Container(
                padding: EdgeInsets.only(top: 50.sp),
                child: ValueListenableBuilder<String>(
                  valueListenable: _inputValue,
                  builder: (context, value, child) {
                    return TextField(
                      controller: _controller,
                      style: TextStyle(fontSize: 18.sp, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "방 코드 입력",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                              BorderSide(color: Colors.grey[400]!, width: 2.sp),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.r),
                          borderSide:
                              BorderSide(color: Colors.grey[400]!, width: 2.sp),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.sp, vertical: 10.sp),
                        suffixIcon: IconButton(
                          icon: Icon(
                            value.isEmpty
                                ? Icons.clear_rounded
                                : Icons.arrow_forward_ios_rounded,
                          ),
                          onPressed: () async {
                            // 방 코드 수동 입력 -> joinRoom 시도 가능
                            if (value.isNotEmpty) {
                              Log.info("직접 입력한 room_code: $value");
                              final result =
                                  await gameService.joinRoom(value, myId);
                              if (result["is_matched"] == true) {
                                final isFirst = result["is_first"] as bool;
                                final opponent = result["opponent"] as int;

                                // GameState 저장
                                GameState().setGameState(
                                  isFirstPlayer: isFirst,
                                  opponentId: opponent,
                                  roomCode: value,
                                );

                                Get.offNamed("/deploy");
                              }
                            } else {
                              // 비어있다면 그냥 clear
                              _controller.clear();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // (2) 서버에서 가져온 "before" 상태 방 목록 보여주기
              Expanded(
                child: ListView.builder(
                  itemCount: _waitingRooms.length,
                  itemBuilder: (context, index) {
                    final room = _waitingRooms[index];
                    final roomCode = room["room_code"] ?? "unknown";
                    return _existingRoom(roomCode);
                  },
                ),
              ),
            ],
          ),
        ));
  }

  /// 방 목록에서 하나 클릭 시 -> joinRoom 진행
  Widget _existingRoom(String roomCode) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.sp),
        child: SizedBox(
          width: 0.4.sw,
          height: 0.25.sh,
          child: GestureDetector(
            onTap: () async {
              // 방 참가
              Log.info("Enter room_code: $roomCode");
              final result = await gameService.joinRoom(roomCode, myId);
              // { "is_matched": true, "room_code": "...", "opponent": ..., "is_first": ... }
              if (result["is_matched"] == true) {
                final isFirst = result["is_first"] as bool;
                final opponent = result["opponent"] as int;

                // GameState 저장
                GameState().setGameState(
                  isFirstPlayer: isFirst,
                  opponentId: opponent,
                  roomCode: roomCode,
                );

                Log.info("Enter room_code: $roomCode");
                // 배치 화면으로 이동
                Get.offNamed("/deploy");
              }
            },
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // 이미지가 겹쳐 나올 수 있도록 설정
              children: [
                // 텍스트 배경 컨테이너
                Positioned(
                  bottom: 5, // 이미지와 겹치도록 조정
                  child: Container(
                    width: 0.35.sw,
                    height: 0.2.sw,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.timeWidgetColor,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Text(
                      roomCode,
                      style: TextStyle(
                        fontSize: 20, // 텍스트 크기
                        fontWeight: FontWeight.bold, // 텍스트 굵기
                        color: Colors.black, // 텍스트 색상
                      ),
                    ),
                  ),
                ),
                // 이미지 컨테이너
                Positioned(
                  top: 0,
                  child: Image.asset(
                    'assets/icons/stackBara.png',
                    width: 90.sp,
                    height: 90.sp,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
