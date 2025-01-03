class Ship {
  final String id;
  final String name;
  final int size;
  List<String> coordinates; // 격자 좌표 (예: "A1", "B3")
  bool isPlaced;
  bool isHorizontal; // 함선의 배치 방향을 나타내는 속성

  Ship({
    required this.id,
    required this.name,
    required this.size,
    List<String>? coordinates, // nullable로 변경
    this.isPlaced = false,
    this.isHorizontal = true, // 기본적으로 가로 배치
  }) : coordinates = coordinates ?? []; // null일 경우 빈 리스트로 초기화
}
