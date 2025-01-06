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

  String imagePath; // <-- 각 유닛 인스턴스가 사용할 이미지 경로

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
    // imagePath는 생성자에서 직접 세팅할 것이므로, 파라미터로 받지 않아도 됨
  })  : coordinates = coordinates ?? [],
        imagePath = '' // 일단 기본값
  {
    // 생성자 끝에서 imagePath를 갱신
    _updateImagePath();
  }

  // -----------------------------
  // '회전' 시에도 imagePath를 다시 계산
  // -----------------------------
  void toggleOrientation() {
    // TODO : 여기에 콘솔 출력 추가 -> 언제 호출되는지 확인
    isHorizontal = !isHorizontal;
    _updateImagePath();
  }

  // -----------------------------
  // [핵심] imagePath 계산 로직
  // -----------------------------
  void _updateImagePath() {
    // 1) "u1_1" 같은 배치된 유닛 ID가 있을 수 있으므로, "u1" 등 기본 ID만 추출
    final baseId = id.contains('_') ? id.split('_')[0] : id;

    // 2) baseName 결정 (none / exist)
    //    - isPlaced == false 면 none 이미지
    //    - isPlaced == true 면 exist 이미지
    String baseName;
    switch (baseId) {
      case 'u1':
        baseName = 'hippo_ride';
        break;
      case 'u2':
        baseName = 'crocodile_ride';
        break;
      case 'u3':
        baseName = 'log_ride';
        break;
      default:
        baseName = 'none';
    }

    // 3) isHorizontal이 false(세로)면, 파일명에 '_rotate' 붙이기
    if (!isHorizontal) {
      baseName += '_rotate';
    }

    // 4) 최종 경로
    imagePath = 'assets/units/$baseName.png';
  }
}
