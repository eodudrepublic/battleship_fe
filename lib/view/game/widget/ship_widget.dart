import 'package:flutter/material.dart';
import '../../../model/ship.dart';

// TODO : 일단 다른거보다 이거 먼저 뜯어 고쳐야 한다.
class ShipWidget extends StatelessWidget {
  final Ship ship;
  final bool isSelected;
  final VoidCallback onTap;

  const ShipWidget({
    super.key,
    required this.ship,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ship.isHorizontal ? ship.size * 30.0 : 30.0,
        height: ship.isHorizontal ? 30.0 : ship.size * 30.0,
        margin: EdgeInsets.all(8.0),
        // TODO : 이미 배치한 함선의 배경색 변경
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.orange,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.brown,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Center(
          child: Text(
            ship.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
