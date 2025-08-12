import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/app_providers.dart';
import 'SimpleSupervisorDialog.dart';

enum UserStatus { active, frozen }

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
  });
}

class Supervisor extends User {
  List<Marketer> marketers;
  double totalDueAmount;
  double pointPrice;
  Supervisor({
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String bank,
    required String accountNumber,
    required String phone,
    required String email,
    required String password,
    this.marketers = const [],
    UserStatus status = UserStatus.active,
    this.totalDueAmount = 0,
    this.pointPrice = 0,
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
  );
}

class Marketer extends User {
  int points;
  double pointPrice;
  String discountCode;
  String reviewLink;
  double totalDueAmount;

  Marketer({
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String bank,
    required String accountNumber,
    required String phone,
    required String email,
    required String password,
    this.points = 0,
    this.pointPrice = 0,
    this.discountCode = '',
    required this.reviewLink,
    this.totalDueAmount = 0,
    UserStatus status = UserStatus.active,
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
  );
}


// --- الشاشة الرئيسية ---
class SupervisorsMarketersPage extends StatefulWidget {
  const SupervisorsMarketersPage({Key? key}) : super(key: key);

  @override
  State<SupervisorsMarketersPage> createState() =>
      _SupervisorsMarketersPageState();
}

class _SupervisorsMarketersPageState extends State<SupervisorsMarketersPage> {
  List<Supervisor> supervisors = [];
  Supervisor? selectedSupervisor;
  User? selectedUser; // مشرف أو مسوق
  bool showEditPanel = false;
  User? editingUser;
  bool isEditingSupervisor = false;
  bool isAdding = false;

  late bool isArabic;
  late bool isDark;

  @override
  void initState() {
    super.initState();
    supervisors = [
      Supervisor(
        firstName: 'أحمد',
        lastName: 'الناصر',
        country: 'السعودية',
        city: 'الرياض',
        bank: 'الراجحي',
        accountNumber: '123456789',
        phone: '0501234567',
        email: 'ahmed@example.com',
        totalDueAmount: 30,
        password: '123456789',
        marketers: [
          Marketer(
            firstName: 'محمد',
            lastName: 'سعيد',
            country: 'السعودية',
            city: 'جدة',
            bank: 'الرياض',
            accountNumber: '987654321',
            phone: '0559876543',
            email: 'mohamed@example.com',
            points: 120,
            pointPrice: 0.5,
            discountCode: 'DISC2025',
            reviewLink: 'http://review.link/abcd1234',
            totalDueAmount: 60,
            password: '123456789',
          ),
        ],
      ),
    ];
  }

  String tr(String ar, String en) => isArabic ? ar : en;

  void selectSupervisor(Supervisor sup) {
    setState(() {
      selectedSupervisor = sup;
      selectedUser = sup;
      editingUser = null;
      showEditPanel = false;
    });
  }

  void selectMarketer(Marketer marketer) {
    setState(() {
      selectedUser = marketer;
      editingUser = null;
      showEditPanel = false;
    });
  }

  void openAddEdit({User? user, required bool supervisor}) {
    setState(() {
      editingUser = user;
      isEditingSupervisor = supervisor;
      isAdding = user == null;
      showEditPanel = true;
    });
  }

  void closeAddEdit() {
    setState(() {
      editingUser = null;
      showEditPanel = false;
    });
  }

  void onSaveUser(User newUser) {
    setState(() {
      if (isAdding) {
        if (isEditingSupervisor) {
          supervisors.add(newUser as Supervisor);
          selectedSupervisor = newUser;
          selectedUser = newUser;
        } else {
          selectedSupervisor?.marketers.add(newUser as Marketer);
          selectedUser = newUser;
        }
      } else {
        if (editingUser is Supervisor && newUser is Supervisor) {
          int index = supervisors.indexOf(editingUser as Supervisor);
          supervisors[index] = newUser;
          selectedSupervisor = newUser;
          selectedUser = newUser;
        } else if (editingUser is Marketer && newUser is Marketer) {
          int index = selectedSupervisor!.marketers.indexOf(editingUser as Marketer);
          selectedSupervisor!.marketers[index] = newUser;
          selectedUser = newUser;
        }
      }
      editingUser = null;
      showEditPanel = false;
    });
  }

  String generateReviewLink() {
    final random = Random();
    final randomStr =
    List.generate(8, (_) => random.nextInt(36).toRadixString(36)).join();
    return 'http://review.link/$randomStr';
  }
  void showSupervisorOptions(Supervisor sup) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(tr('تعديل', 'Edit')),
              onTap: () {
                Navigator.pop(context);
                openAddEdit(user: sup, supervisor: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(tr('حذف', 'Delete')),
              onTap: () {
                Navigator.pop(context);
                showDeleteConfirmation(sup,isDark);
              },
            ),
            ListTile(
              leading: Icon(sup.status == UserStatus.active ? Icons.pause : Icons.play_arrow),
              title: Text(sup.status == UserStatus.active ? tr('تجميد', 'Freeze') : tr('تفعيل', 'Activate')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  sup.status = sup.status == UserStatus.active ? UserStatus.frozen : UserStatus.active;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void showMarketerOptions(Marketer marketer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(tr('تعديل', 'Edit')),
              onTap: () {
                Navigator.pop(context);
                openAddEdit(user: marketer, supervisor: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(tr('حذف', 'Delete')),
              onTap: () {
                Navigator.pop(context);
                showDeleteConfirmation(marketer,isDark);
              },
            ),
            ListTile(
              leading: Icon(marketer.status == UserStatus.active ? Icons.pause : Icons.play_arrow),
              title: Text(marketer.status == UserStatus.active ? tr('تجميد', 'Freeze') : tr('تفعيل', 'Activate')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  marketer.status = marketer.status == UserStatus.active ? UserStatus.frozen : UserStatus.active;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String getSupervisorStats(Supervisor sup) {
    int totalPoints = sup.marketers.fold(0, (p, m) => p + m.points);
    double totalDue = sup.marketers.fold(0.0, (p, m) => p + m.totalDueAmount);
    return '${tr('عدد المسوقين', 'Marketers')}: ${sup.marketers.length} - '
        '${tr('إجمالي النقاط', 'Total Points')}: $totalPoints - '
        '${tr('إجمالي المستحق', 'Total Due')}: ${totalDue.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    isArabic = localeProvider.locale.languageCode == 'ar';
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(

        body: Row(
          children: [
          Expanded(
          flex: 2,
          child:
            Column(children : [
              Row(children: [
                const SizedBox(width: 25,),
                Text(tr('المشرفين', 'Supervisors'),style:TextStyle(color:isDark?Color(0xFFD7EFDC):Colors.blue[900],fontWeight:FontWeight.bold,fontSize:25 )),
                const SizedBox(width: 25,),
                Card(child:  IconButton(
                  tooltip: tr('إضافة مشرف', 'Add Supervisor'),
                  icon:   Icon(Icons.person_add,color:isDark?Color(0xFFD7EFDC):Colors.blue[900]),
                  onPressed: () => openAddEdit(user: null, supervisor: true),
                )),
                ]
              ),
              Flexible(
              flex: 2,

              child: ListView(

                children: supervisors
                    .map(
                      (sup) => Card(
                        
                    color: sup == selectedSupervisor
                        ? (isDark
                        ? Colors.green[300]?.withOpacity(.6)
                        : Colors.blue[900]?.withOpacity(.8))
                        :(isDark
                        ? Colors.green.withOpacity(.2)
                        : Colors.blue[600]?.withOpacity(.3)),
                    child: ListTile(
                      title: Text('${sup.firstName} ${sup.lastName}',style:TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color:Colors.white)),
                      subtitle: Text(
                        '${sup.country} - ${sup.city}\n${getSupervisorStats(sup)}'
                          ,style:TextStyle(color:Colors.white)),
                      isThreeLine: true,
                      trailing: sup.status == UserStatus.active
                          ? null
                          : const Icon(Icons.pause_circle_filled,
                          color: Colors.red),
                      onTap: () => selectSupervisor(sup),
                      onLongPress: () => showSupervisorOptions(sup),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),]
            ),
            ),
            const VerticalDivider(width: 12),

            // عمود المسوقين + التفاصيل أو شاشة التعديل
            Expanded(
              flex: 5,
              child: showEditPanel
                  ? AddEditUserWidget(
                user: editingUser,
                isSupervisor: isEditingSupervisor,
                isArabic: isArabic,
                onCancel: closeAddEdit,
                onSave: onSaveUser,
                generateReviewLink: generateReviewLink,
              )
                  : selectedUser == null
                  ? Center(
                child: Text(
                    tr('يرجى اختيار مشرف أو مسوق', 'Please select a supervisor or marketer')),
              )
                  : selectedUser is Supervisor
                  ? buildSupervisorDetails(selectedUser as Supervisor)
                  : buildMarketerDetails(selectedUser as Marketer),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSupervisorDetails(Supervisor sup) {
    final textColor = isDark ? Color(0xFFD7EFDC) : Colors.blue[900];
    final gradient = LinearGradient(
      colors:isDark?[
        Colors.green.shade700.withOpacity(.3),
        Colors.green.shade500.withOpacity(.3),
        Color(0xFFB3A664).withOpacity(.3),
        Colors.green.shade600.withOpacity(.3),
        ?Colors.green[900]?.withOpacity(.3),
      ] :
      [?Colors.green[200]?.withOpacity(.3), ?Colors.blue[700]?.withOpacity(.3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final gradient2 = LinearGradient(
      colors:isDark?[
        Colors.green.shade700.withOpacity(.3),
        Colors.green.shade500.withOpacity(.3),
        Color(0xFFB3A664).withOpacity(.3),
        Colors.green.shade600.withOpacity(.3),
        ?Colors.green[900]?.withOpacity(.3),
      ] :
      [ ?Colors.blue[700]?.withOpacity(.3),?Colors.green[200]?.withOpacity(.3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('تفاصيل المشرف', 'Supervisor Details'),
                  style:   TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color:isDark?Color(0xFFD7EFDC):Colors.blue[900]),
                ),
                const SizedBox(height: 16),
                buildDetailRow(tr('الاسم الأول', 'First Name'), sup.firstName , textColor!),
                buildDetailRow(tr('الاسم الأخير', 'Last Name'), sup.lastName, textColor),
                buildDetailRow(tr('الدولة', 'Country'), sup.country, textColor),
                buildDetailRow(tr('المدينة', 'City'), sup.city, textColor),
                buildDetailRow(tr('البنك', 'Bank'), sup.bank, textColor),
                buildDetailRow(tr('رقم الحساب', 'Account Number'), sup.accountNumber, textColor),
                buildDetailRow(tr('رقم الهاتف', 'Phone'), sup.phone, textColor),
                buildDetailRow(tr('البريد الإلكتروني', 'Email'), sup.email, textColor),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: isDark?Colors.green[800]:Colors.blue),
                      icon: const Icon(Icons.edit,color:Colors.white),
                      label: Text(tr('تعديل', 'Edit'),style:TextStyle(color:Colors.white)),
                      onPressed: () => openAddEdit(user: sup, supervisor: true),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      icon: const Icon(Icons.delete, color:Colors.white ),
                      label: Text(tr('حذف', 'Delete'),style:TextStyle(color:Colors.white)),
                      onPressed: () => showDeleteConfirmation(sup,isDark),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                          sup.status == UserStatus.active ? Colors.orange : Colors.green),
                      icon: Icon(sup.status == UserStatus.active ? Icons.pause : Icons.play_arrow,color:Colors.white),
                      label: Text(sup.status == UserStatus.active ? tr('تجميد', 'Freeze') : tr('تفعيل', 'Activate'),style:TextStyle(color:Colors.white)),
                      onPressed: () {
                        setState(() {
                          sup.status = sup.status == UserStatus.active
                              ? UserStatus.frozen
                              : UserStatus.active;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor:isDark?Colors.green[700]: Colors.blue),
                      onPressed:  () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr('تم صرف المبلغ', 'Amount paid'))),
                        );
                        setState(() {

                        });
                      }
                         ,
                      child: Text(tr('صرف المبلغ المستحق', 'Pay Due Amount'),style:TextStyle(color:Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                Row( children: [
                  SizedBox(width: 20,),
                  Text(
                  tr('المسوقين التابعين', 'Marketers under Supervisor'),
                  style:  TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color:isDark?Color(0xFFD7EFDC):Colors.blue[900]),
                ),
                  SizedBox(width: 20,),
                  Card(child: IconButton(
                    tooltip: tr('إضافة مسوق', 'Add Marketer'),
                    icon:   Icon(Icons.person_add,color:isDark?Color(0xFFD7EFDC):Colors.blue[900]),
                    onPressed: () => openAddEdit(user: null, supervisor: false),
                  ) ,),
                ] ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: sup.marketers.length,
                  itemBuilder: (context, index) {
                    final marketer = sup.marketers[index];
                    return Card(
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 8,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: gradient2,
                            borderRadius: BorderRadius.circular(18),
                          ),
                      child: ListTile(
                        title: Text('${marketer.firstName} ${marketer.lastName}',style:TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color:isDark?Colors.white:Colors.blue[900])),
                        subtitle: Text('${marketer.country} - ${marketer.city}',style:TextStyle(color:isDark?Colors.white:Colors.blue[900])),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: tr('نسخ اللينك', 'Copy Link'),
                              icon: const Icon(Icons.copy, color: Colors.white),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: marketer.reviewLink));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(tr('تم نسخ اللينك', 'Link copied'))),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: tr('تجديد اللينك', 'Renew Link'),
                              icon: const Icon(Icons.refresh, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  marketer.reviewLink = generateReviewLink();
                                  selectedUser = marketer;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(tr('تم تجديد اللينك', 'Link renewed'))),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () => selectMarketer(marketer),
                        onLongPress: () => showMarketerOptions(marketer),
                      ),
                    )
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMarketerDetails(Marketer marketer) {
    final textColor = isDark ? Color(0xFFD7EFDC) : Colors.blue[900];

    final gradient = LinearGradient(
      colors:isDark?[
        Colors.green.shade700.withOpacity(.3),
        Colors.green.shade500.withOpacity(.3),
        Color(0xFFB3A664).withOpacity(.3),
        Colors.green.shade600.withOpacity(.3),
        ?Colors.green[900]?.withOpacity(.3),
      ] :
      [?Colors.green[200]?.withOpacity(.3), ?Colors.blue[700]?.withOpacity(.3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                tr('تفاصيل المسوق', 'Marketer Details'),
            style:   TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color:isDark?Color(0xFFD7EFDC):Colors.blue[900]),
          ),
          const SizedBox(height: 16),
          buildDetailRow(tr('الاسم الأول', 'First Name'), marketer.firstName, textColor!),
          buildDetailRow(tr('الاسم الأخير', 'Last Name'), marketer.lastName, textColor),
          buildDetailRow(tr('الدولة', 'Country'), marketer.country, textColor),
          buildDetailRow(tr('المدينة', 'City'), marketer.city, textColor),
          buildDetailRow(tr('البنك', 'Bank'), marketer.bank, textColor),
          buildDetailRow(tr('رقم الحساب', 'Account Number'), marketer.accountNumber, textColor),
          buildDetailRow(tr('رقم الهاتف', 'Phone'), marketer.phone, textColor),
          buildDetailRow(tr('البريد الإلكتروني', 'Email'), marketer.email, textColor),
          const Divider(height: 30),
          buildDetailRow(tr('النقاط المجمعه', 'Points Collected'), marketer.points.toString(), textColor),
          buildDetailRow(tr('سعر النقاط', 'Point Price'), marketer.pointPrice.toStringAsFixed(2), textColor),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${tr('كود الخصم', 'Discount Code')}: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          marketer.discountCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: tr('نسخ الكود', 'Copy Code'),
                        icon: const Icon(Icons.copy, color: Colors.blue),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: marketer.discountCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr('تم نسخ الكود', 'Code copied'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),)),
                          );
                        },
                      ),
                    ],
                  ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '${tr('لينك المراجعه', 'Review Link')}: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  marketer.reviewLink,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: tr('نسخ اللينك', 'Copy Link'),
                icon: const Icon(Icons.copy, color: Colors.blue),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: marketer.reviewLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('تم نسخ اللينك', 'Link copied'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),)),
                  );
                },
              ),
              IconButton(
                tooltip: tr('تجديد اللينك', 'Renew Link'),
                icon: const Icon(Icons.refresh, color: Colors.green),
                onPressed: () {
                  setState(() {
                    marketer.reviewLink = generateReviewLink();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('تم تجديد اللينك', 'Link renewed'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),)),
                  );
                },
              ),
            ],
          ),
          buildDetailRow(tr('اجمالي المبلغ المستحق', 'Total Due Amount'),
              marketer.totalDueAmount.toStringAsFixed(2), textColor),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor:isDark?Colors.green[700]: Colors.blue),
            onPressed: marketer.totalDueAmount > 0
                ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr('تم صرف المبلغ', 'Amount paid'))),
              );
              setState(() {
                marketer.totalDueAmount = 0;
              });
            }
                : null,
            child: Text(tr('صرف المبلغ المستحق', 'Pay Due Amount'),style:TextStyle(color:Colors.white)),
          ),
          const SizedBox(height: 16),
          Row(
              children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor:isDark?Colors.green[700]: Colors.blue),
          icon: const Icon(Icons.edit,color:Colors.white),
          label: Text(tr('تعديل', 'Edit'),style:TextStyle(color:Colors.white)),
          onPressed: () => openAddEdit(user: marketer, supervisor: false),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          icon: const Icon(Icons.delete,color:Colors.white),
          label: Text(tr('حذف', 'Delete'),style:TextStyle(color:Colors.white)),
          onPressed: () => showDeleteConfirmation(marketer,isDark),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                marketer.status == UserStatus.active ? Colors.orange : Colors.green),
            icon: Icon(marketer.status == UserStatus.active ? Icons.pause : Icons.play_arrow,color:Colors.white),
            label: Text(
                marketer.status == UserStatus.active ? tr('تجميد', 'Freeze') : tr('تفعيل', 'Activate'),style:TextStyle(color:Colors.white)),
            onPressed: () {
              setState(() {
                marketer.status = marketer.status == UserStatus.active
                    ? UserStatus.frozen
                    : UserStatus.active;
              });
            },
        ),
              ],
          ),
                ],
            ),
          ),
        )
        );
    }

  Widget buildDetailRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }


  void showDeleteConfirmation(User user,bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('تأكيد الحذف', 'Delete Confirmation'),style:TextStyle(color:isDark?Color(0xFFD7EFDC):Colors.blue[900])),
        content: Text(tr(
            'هل أنت متأكد من حذف هذا العنصر؟',
            'Are you sure you want to delete this item?'),style:TextStyle(color:isDark?Color(0xFFD7EFDC):Colors.blue[900])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('إلغاء', 'Cancel'),style:TextStyle(color:isDark?Color(0xFFD7EFDC):Colors.blue[900])),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (user is Supervisor) {
                  supervisors.remove(user);
                  if (selectedSupervisor == user) {
                    selectedSupervisor = null;
                    selectedUser = null;
                  }
                } else if (user is Marketer) {
                  selectedSupervisor?.marketers.remove(user);
                  if (selectedUser == user) {
                    selectedUser = null;
                  }
                }
              });
              Navigator.pop(context);
            },
            child: Text(tr('حذف', 'Delete'),style:TextStyle(color:isDark?Color(0xFFD7EFDC):Colors.blue[900])),
          ),
        ],
      ),
    );
  }

} // نهاية _SupervisorsMarketersPageState
