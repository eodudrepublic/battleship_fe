import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../common/app_colors.dart';

class DeployViewMaking extends StatelessWidget {
  final double _cellSize = (1.sw - 10.sp) / 11 - 1.sp;
  final double _imageSize = min(
    (0.7.sh - 1.sw) / 4, // 첫 번째 값
    1.sw / 10, // 두 번째 값
  );

  DeployViewMaking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 상단 위젯
              Container(
                width: double.infinity,
                height: 0.2.sh,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '배치하기',
                      style: TextStyle(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TODO : 배치 남은 시간 표시하는 기능 추가
                        Container(
                          width: 0.36.sw,
                          height: 0.075.sh,
                          decoration: BoxDecoration(
                            color: AppColors.timeWidgetColor,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "00:57",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 10.sp,
                        ),
                        // TODO : GestureDetector로 배치 완료 기능 추가
                        Container(
                          width: 0.36.sw,
                          height: 0.075.sh,
                          decoration: BoxDecoration(
                            color: AppColors.attackButtonColor,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "배치 완료",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              /// 게임판
              // TODO : 게임판 위젯 추출
              Container(
                width: double.infinity,
                height: 1.sw,
                alignment: Alignment.center,
                child: Table(
                  border: TableBorder.all(color: Colors.blue, width: 2.sp),
                  defaultColumnWidth: FixedColumnWidth(_cellSize),
                  children: [
                    // 첫 번째 줄 (헤더)
                    TableRow(
                      children: List.generate(
                        11,
                        (index) => Container(
                          alignment: Alignment.center,
                          height: _cellSize,
                          child: index == 0
                              ? Text('') // 빈 셀
                              : Text(
                                  index.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                    // 나머지 줄 (A~J 행)
                    ...List.generate(
                      10,
                      (rowIndex) => TableRow(
                        children: List.generate(
                          11,
                          (colIndex) => Container(
                            alignment: Alignment.center,
                            height: _cellSize,
                            child: colIndex == 0
                                ? Text(
                                    String.fromCharCode(65 + rowIndex), // A~J
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : Text(''), // 빈 셀
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(horizontal: 5.sp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  // TODO : 배치할 유닛 이미지 회전 기능 추가
                  // TODO : 유닛을 모두 배치했으면 _none 이미지로 교체
                  children: [
                    Container(
                      height: _imageSize * 3,
                      width: _imageSize * 3,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/units/hippo_exist.png',
                        height: _imageSize * 2,
                        width: _imageSize * 3,
                      ),
                    ),
                    Container(
                      height: _imageSize * 4,
                      width: _imageSize * 4,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/units/crocodile_exist.png',
                        height: _imageSize * 1,
                        width: _imageSize * 4,
                      ),
                    ),
                    Container(
                      height: _imageSize * 2,
                      width: _imageSize * 2,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/units/log_exist.png',
                        height: _imageSize * 1,
                        width: _imageSize * 2,
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        height: 0.12.sh,
                        width: _imageSize * 3,
                        alignment: Alignment.topCenter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '하마',
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '(3 x 2)',
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '남은 개수: 1',
                              style: TextStyle(
                                  fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 6.sp,
                            ),
                            SvgPicture.asset(
                              'assets/icons/turn.svg',
                              height: 22.sp,
                              width: 22.sp,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 0.12.sh,
                        width: _imageSize * 4,
                        alignment: Alignment.topCenter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '악어',
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '(4 x 1)',
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '남은 개수: 2',
                              style: TextStyle(
                                  fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 6.sp,
                            ),
                            SvgPicture.asset(
                              'assets/icons/turn.svg',
                              height: 22.sp,
                              width: 22.sp,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 0.12.sh,
                        width: _imageSize * 2,
                        alignment: Alignment.topCenter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '통나무',
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '(2 x 1)',
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '남은 개수: 3',
                              style: TextStyle(
                                  fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 6.sp,
                            ),
                            SvgPicture.asset(
                              'assets/icons/turn.svg',
                              height: 22.sp,
                              width: 22.sp,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
