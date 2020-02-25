/// Describes the login information...
class CafetoriaLogin {
  // ignore: public_member_api_docs
  CafetoriaLogin({this.error});

  /// Creates a cafetoria login from json map
  factory CafetoriaLogin.fromJson(Map<String, dynamic> json) => CafetoriaLogin(
        error: json['error'],
      );

  /// Login error
  final String error;
}

/// Describes the whole Cafetoria data...
class Cafetoria {
  // ignore: public_member_api_docs
  Cafetoria({this.error, this.days, this.saldo});

  /// Creates cafetoria from json map
  factory Cafetoria.fromJson(Map<String, dynamic> json) => Cafetoria(
        error: json['error'],
        days: json['days']
            .toList()
            .map((day) => CafetoriaDay.fromJson(day))
            .toList()
            .cast<CafetoriaDay>(),
        saldo: json['saldo'],
      );

  /// The login errors
  final String error;

  /// All cafetoria days
  final List<CafetoriaDay> days;

  /// The user saldo
  final double saldo;
}

/// Describes a day of the cafetoria...
class CafetoriaDay {
  // ignore: public_member_api_docs
  CafetoriaDay({
    this.date,
    this.menus,
  });

  /// Creates a cafetoria day from json map
  factory CafetoriaDay.fromJson(Map<String, dynamic> json) => CafetoriaDay(
        date: DateTime.parse(json['date']),
        menus: json['menus']
            .map((day) => CafetoriaMenu.fromJson(day))
            .toList()
            .cast<CafetoriaMenu>(),
      );

  /// The day [date]
  final DateTime date;

  /// The day [menus]
  final List<CafetoriaMenu> menus;
}

/// Describes a menu of a day...
class CafetoriaMenu {
  // ignore: public_member_api_docs
  CafetoriaMenu({this.time, this.name, this.price}) : super();

  /// Creates a cafetoria menu from json map
  factory CafetoriaMenu.fromJson(Map<String, dynamic> json) => CafetoriaMenu(
      time: json['time'],
      name: json['name'],
      price: double.parse('${json['price'] ?? 0.0}'));

  /// The time of this menu
  final String time;

  /// The name of this menu
  final String name;

  /// The price of this menu
  final double price;
}
