import 'package:flutter/material.dart';

class GridViewWidget extends StatelessWidget {
  final List<List<String>> grid; // 격자 데이터
  final Function(int, int) onCellTap; // 셀 탭 시 호출될 콜백

  const GridViewWidget({
    super.key,
    required this.grid,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 15,
      ),
      itemCount: 225, // 15x15
      itemBuilder: (context, index) {
        int row = index ~/ 15;
        int col = index % 15;

        String cellValue = grid[row][col];

        return GestureDetector(
          onTap: () {
            onCellTap(row, col);
          },
          // TODO : 함선 배치시 보이는거 수정해야 함
          child: Container(
            margin: EdgeInsets.all(1.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              color: cellValue == 'empty' ? Colors.lightBlue[50] : Colors.grey,
            ),
            child: Center(
              child: Text(
                cellValue == 'empty' ? '' : 'S',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
