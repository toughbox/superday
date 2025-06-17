/// 하루성공 앱의 텍스트 상수들
class AppStrings {
  // 앱 기본 정보
  static const String appName = '하루성공';
  static const String appDescription = '매일 하나의 목표를 달성하는 동기부여 앱';
  
  // 네비게이션 메뉴
  static const String homeTab = '홈';
  static const String calendarTab = '달력';
  static const String historyTab = '히스토리';
  static const String settingsTab = '설정';
  
  // 홈 화면
  static const String todayGoal = '오늘의 목표';
  static const String todayGoals = '오늘의 목표';
  static const String todayProgress = '오늘의 진행률';
  static const String addGoal = '목표 추가';
  static const String goalAchieved = '달성';
  static const String goalInputHint = '오늘 달성하고 싶은 목표를 입력하세요';
  static const String noGoalsToday = '오늘 설정된 목표가 없습니다.\n새로운 목표를 추가해보세요!';
  static const String addFirstGoal = '첫 번째 목표를 추가해보세요!';
  
  // 축하 메시지 30종
  static const List<String> celebrationMessages = [
    "오늘도 해냈어요! 멋져요! ⭐",
    "작은 성공이 큰 변화를 만듭니다! 🌟",
    "계속 이렇게만 해봐요, 곧 큰 성취가 기다리고 있어요! 🚀",
    "스스로에게 박수를 보내주세요! 👏",
    "오늘의 목표 달성, 내일도 기대할게요! 💪",
    "성공은 습관입니다. 오늘도 한 걸음! 👣",
    "당신의 노력이 빛나고 있어요! ✨",
    "목표를 달성한 자신을 자랑스러워하세요! 🏆",
    "한 걸음 한 걸음이 모여 큰 변화가 됩니다! 🌈",
    "오늘도 성장하는 모습이 아름다워요! 🌱",
    "포기하지 않은 당신이 대단해요! 💎",
    "꾸준함의 힘을 보여주고 있어요! ⚡",
    "목표 달성! 오늘 하루도 완벽했어요! 🎯",
    "당신의 의지력에 감동받았어요! 💝",
    "작은 승리가 큰 기쁨을 가져다줘요! 🎉",
    "오늘의 성취, 내일의 동기부여가 됩니다! 🔥",
    "멋진 하루를 만들어가고 있어요! 🌸",
    "목표를 향한 열정이 느껴져요! ❤️",
    "당신은 할 수 있다는 걸 증명했어요! 💪",
    "오늘 하루 정말 수고했어요! 🙏",
    "꿈을 향해 한 걸음 더 나아갔어요! 🌟",
    "성취의 기쁨을 만끽하세요! 🎊",
    "당신의 노력이 결실을 맺었어요! 🍀",
    "목표 달성의 달인이 되어가고 있어요! 👑",
    "오늘도 자신과의 약속을 지켰어요! 🤝",
    "성공의 맛을 제대로 느끼고 있어요! 🍯",
    "당신의 의지는 정말 강해요! 🦾",
    "목표를 이룬 기쁨이 전해져요! 😊",
    "오늘의 노력이 미래를 바꿔요! 🔮",
    "축하해요! 오늘도 성공적인 하루였어요! 🎈"
  ];
  
  // 에러 메시지
  static const String goalTooLong = '목표는 50자 이내로 입력해주세요.';
  static const String goalEmpty = '목표를 입력해주세요.';
  static const String goalAlreadyExists = '이미 같은 목표가 있습니다.';
  
  // 확인 메시지
  static const String deleteConfirm = '정말로 삭제하시겠습니까?';
  static const String goalCompleteConfirm = '목표를 달성하셨나요?';
} 