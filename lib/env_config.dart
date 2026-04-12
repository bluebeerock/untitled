class EnvConfig {
  /// LAN A のインターフェース名
  static const String lanA = String.fromEnvironment('LAN_A', defaultValue: 'ethx');

  /// LAN B のインターフェース名
  static const String lanB = String.fromEnvironment('LAN_B', defaultValue: 'ethz');

  /// リスト形式での取得
  static const List<String> interfaces = [lanA, lanB];
}