class Unit {
  final String id;
  final String name;
  final int width; // 가로 크기
  final int height; // 세로 크기
  List<String> coordinates; // 배치된 좌표 리스트
  bool isPlaced;
  bool isHorizontal; // 배치 방향
  int? startRow; // 유닛의 시작 행
  int? startCol; // 유닛의 시작 열

  Unit({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    List<String>? coordinates,
    this.isPlaced = false,
    this.isHorizontal = true,
    this.startRow,
    this.startCol,
  }) : coordinates = coordinates ?? [];
}
