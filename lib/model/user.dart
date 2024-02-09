class User {
  late int id;
  late String userName;
  late int coin;

  User(
    this.id,
    this.userName,
    this.coin,
  );

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['user_name'];
    coin = json['coin'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_name': userName,
        'coin': coin,
      };
}
