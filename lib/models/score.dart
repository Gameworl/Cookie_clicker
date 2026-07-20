/// Représente un score dans le classement.
class Score {
  final String name;
  final int cookies;

  const Score({required this.name, required this.cookies});

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      name: json['name'] as String? ?? 'Anonyme',
      cookies: json['cookies'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'cookies': cookies};
  }
}
