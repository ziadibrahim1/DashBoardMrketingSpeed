class Supervisor extends User {
  int id;
  List<Marketer> marketers;
  double totalDueAmount;
  int AmountDue;
  double pointPrice;
  bool isWithdrawalPending;

  Supervisor({
    required this.id,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required double Age,
    required String bank,
    required String accountNumber,
    required String phone,
    required String Role,
    required String email,
    required String password,
    this.totalDueAmount = 0,
    this.pointPrice = 0,
    this.AmountDue = 0,
    UserStatus status = UserStatus.active,
    required this.isWithdrawalPending,
    this.marketers = const [],
  }) : super(
    firstName: firstName,
    lastName: lastName,
    country: country,
    city: city,
    age: Age,
    bank: bank,
    accountNumber: accountNumber,
    phone: phone,
    email: email,
    password: password,
    status: status,
    points: totalDueAmount.toInt(),
    pointPrice: pointPrice,
    totalDueAmount: totalDueAmount.toDouble(),

  );

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    final fullName = (json['fullName'] ?? '').toString().split(' ');

    return Supervisor(
      id: json['id'],
      firstName: fullName.isNotEmpty ? fullName.first : '',
      lastName: fullName.length > 1 ? fullName.sublist(1).join(' ') : '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      Age: json['age'] ?? 0,
      bank: json['bank'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      phone: json['phone'] ?? '',
      Role: json['role'] ?? 'Supervisor',
      email: json['email'] ?? '',
      password: '',
      isWithdrawalPending: json['isWithdrawalPending'],
      status: json['isActive'] == true ? UserStatus.active : UserStatus.frozen,
      totalDueAmount: (json['totalDueAmount'] ?? 0).toDouble(),
      pointPrice: (json['pointPrice'] ?? 0).toDouble(),
      AmountDue: json['amountDue'] ?? 0,
      marketers: (json['marketers'] as List? ?? []).map((e) => Marketer.fromJson(e)).toList(),

    );
  }


}

class Marketer extends User {
  int id;
  int supervisorId;
  int points;
  double pointPrice;
  String discountCode;
  String reviewLink;
  double totalDueAmount;
  int AmountDue;
  double? age;
  bool isWithdrawalPending;

  Marketer({
    required this.id,
    required this.supervisorId,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required this.age,
    required String bank,
    required String accountNumber,
    required String phone,
    required String email,
    required String password,
    this.points = 0,
    this.pointPrice = 0,
    required this.discountCode ,
    this.reviewLink = '',
    this.totalDueAmount = 0,
    this.AmountDue = 0,
    UserStatus status = UserStatus.active,
    required this.isWithdrawalPending,

  }) : super(
    firstName: firstName,
    lastName: lastName,
    country: country,
    city: city,
    bank: bank,
    accountNumber: accountNumber,
    phone: phone,
    email: email,
    password: password,
    status: status,
    points: points,
    pointPrice: pointPrice,
    totalDueAmount: totalDueAmount,
  );

  factory Marketer.fromJson(Map<String, dynamic> json) {
    final fullName = (json['fullName'] ?? '').toString().split(' ');
    print('Age: ${json.toString()}');
    return Marketer(
      id: json['id'],
      supervisorId: json['marketerSupervisorId'] ?? 0,
      firstName: fullName.isNotEmpty ? fullName.first : '',
      lastName: fullName.length > 1 ? fullName.last : '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      age: json['age'] ?? 0,
      bank: json['bank'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      password: '',
      points: json['pointsAccumulated'] ?? 0,
      pointPrice: json['pointPrice'] ?? 0,
      discountCode: json['promoCode'] ?? '',
      totalDueAmount: (json['totalDueAmount'] ?? 0).toDouble(),
      status: json['isActive'] == true ? UserStatus.active : UserStatus.frozen,
      isWithdrawalPending: json['isWithdrawalPending'] ,
    );
  }

}
abstract class User {
  String firstName;
  String lastName;
  String country;
  String city;
  String bank;
  String accountNumber;
  String phone;
  String email;
  String password;
  UserStatus status;
  double? age;
  int points;
  double pointPrice;
  double totalDueAmount;




  User({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.city,
    required this.bank,
    required this.accountNumber,
    required this.phone,
    required this.email,
    required this.password,
    this.status = UserStatus.active,
    this.age = 0,
    this.points = 0,
    this.pointPrice = 0,
    this.totalDueAmount = 0,
  });
}

enum UserStatus { active, frozen }

UserStatus statusFromFlags(bool isFrozen) =>
    isFrozen ? UserStatus.frozen : UserStatus.active;

