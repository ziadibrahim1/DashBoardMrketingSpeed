import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MaterialApp(home: SupervisorsManagementSimpleScreen()));
}

class Supervisor {
  String id;
  String firstName, middleName, lastName, phone, country, city;
  String bankName, bankAccountNumber;
  File? profileImageFile;
  String? profileImageUrl; // للمشرفين فقط رابط - ممكن تغيرها لملف إذا حبيت

  String email, password;

  List<Marketer> marketers = [];

  Supervisor({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phone,
    required this.country,
    required this.city,
    required this.bankName,
    required this.bankAccountNumber,
    this.profileImageFile,
    this.profileImageUrl,
    required this.email,
    required this.password,
  });

  String get fullName => '$firstName $middleName $lastName';
}

class Marketer {
  String id;
  String firstName, middleName, lastName, phone, country, city;
  String bankName, bankAccountNumber;
  File? profileImageFile; // الصورة الشخصية ملف من الجهاز
  String? profileImageUrl; // للاحتياط لو حبيت رابط

  String promoCode;
  DateTime promoCodeCreatedAt;
  DateTime promoCodeExpiresAt;
  DateTime createdAt;

  int points;
  String supervisorId;
  bool isFrozen;
  double salary;

  Marketer({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phone,
    required this.country,
    required this.city,
    required this.bankName,
    required this.bankAccountNumber,
    this.profileImageFile,
    this.profileImageUrl,
    required this.promoCode,
    required this.promoCodeCreatedAt,
    required this.promoCodeExpiresAt,
    required this.createdAt,
    required this.points,
    required this.supervisorId,
    this.isFrozen = false,
  }) : salary = points * 0.15;

  String get fullName => '$firstName $middleName $lastName';

  void regeneratePromoCode() {
    promoCode = const Uuid().v4().substring(0, 8).toUpperCase();
    promoCodeCreatedAt = DateTime.now();
    promoCodeExpiresAt = DateTime.now().add(const Duration(days: 30));
  }

  void cashOutSalary() {
    points = 0;
    salary = 0;
  }
}

class SupervisorsManagementSimpleScreen extends StatefulWidget {
  const SupervisorsManagementSimpleScreen({super.key});

  @override
  State<SupervisorsManagementSimpleScreen> createState() =>
      _SupervisorsManagementSimpleScreenState();
}

class _SupervisorsManagementSimpleScreenState
    extends State<SupervisorsManagementSimpleScreen> {
  final List<Supervisor> supervisors = [];
  Supervisor? selectedSupervisor;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // بيانات تجريبية
    final sup1 = Supervisor(
      id: const Uuid().v4(),
      firstName: 'محمد',
      middleName: 'علي',
      lastName: 'الزهراني',
      phone: '0501234567',
      country: 'السعودية',
      city: 'الرياض',
      bankName: 'الأهلي',
      bankAccountNumber: '1234567890',
      email: 'm.alzahrani@example.com',
      password: 'password123',
    );

    final marketer1 = Marketer(
      id: const Uuid().v4(),
      firstName: 'علي',
      middleName: 'خالد',
      lastName: 'الحربي',
      phone: '0555555555',
      country: 'السعودية',
      city: 'الدمام',
      bankName: 'الراجحي',
      bankAccountNumber: '1122334455',
      promoCode: 'PROMO123',
      promoCodeCreatedAt: DateTime.now().subtract(const Duration(days: 10)),
      promoCodeExpiresAt: DateTime.now().add(const Duration(days: 20)),
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      points: 150,
      supervisorId: sup1.id,
      isFrozen: false,
    );

    sup1.marketers.add(marketer1);

    supervisors.add(sup1);

    selectedSupervisor = supervisors.first;
  }

  void addSupervisor(Supervisor sup) {
    setState(() {
      supervisors.add(sup);
    });
  }

  void updateSupervisor(Supervisor updated) {
    final idx = supervisors.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      setState(() {
        supervisors[idx] = updated;
        if (selectedSupervisor?.id == updated.id) selectedSupervisor = updated;
      });
    }
  }

  void addMarketer(Marketer marketer) {
    final sup = supervisors.firstWhere((s) => s.id == marketer.supervisorId);
    setState(() {
      sup.marketers.add(marketer);
    });
  }

  void updateMarketer(Marketer updated) {
    final sup = supervisors.firstWhere((s) => s.id == updated.supervisorId);
    final idx = sup.marketers.indexWhere((m) => m.id == updated.id);
    if (idx != -1) {
      setState(() {
        sup.marketers[idx] = updated;
      });
    }
  }

  void freezeMarketer(Marketer m, Duration duration) {
    setState(() {
      m.isFrozen = true;
      m.regeneratePromoCode();
      m.promoCodeExpiresAt = DateTime.now().add(duration);
    });
  }

  void unfreezeMarketer(Marketer m) {
    setState(() {
      m.isFrozen = false;
      m.promoCodeExpiresAt = DateTime.now().add(const Duration(days: 30));
    });
  }

  Future<void> _pickImageForSupervisor() async {
    if (selectedSupervisor == null) return;
    final picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() {
        selectedSupervisor!.profileImageFile = File(picked.path);
        selectedSupervisor!.profileImageUrl = null;
      });
    }
  }

  Future<File?> _pickImageForMarketer(Marketer marketer) async {
    final picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  void _showSupervisorDialog({Supervisor? supervisor}) {
    showDialog(
      context: context,
      builder: (context) => SimpleSupervisorDialog(
        supervisor: supervisor,
        onSave: (sup) {
          if (supervisor == null) {
            addSupervisor(sup);
          } else {
            updateSupervisor(sup);
          }
          Navigator.pop(context);
        },
        pickImage: _pickImageForSupervisor,
      ),
    );
  }

  void _showMarketerDialog({Marketer? marketer}) {
    if (selectedSupervisor == null) return;
    showDialog(
      context: context,
      builder: (context) => SimpleMarketerDialog(
        marketer: marketer,
        supervisorId: selectedSupervisor!.id,
        onSave: (marketerData) {
          if (marketer == null) {
            addMarketer(marketerData);
          } else {
            updateMarketer(marketerData);
          }
          Navigator.pop(context);
        },
        pickImage: () => _pickImageForMarketer(marketer!),
      ),
    );
  }

  void _showFreezeDialog(Marketer marketer) {
    Duration selected = const Duration(days: 30);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('اختر مدة التجميد'),
          content: StatefulBuilder(builder: (ctx, setState) {
            return DropdownButton<Duration>(
              value: selected,
              items: const [
                DropdownMenuItem(value: Duration(days: 7), child: Text('7 أيام')),
                DropdownMenuItem(value: Duration(days: 30), child: Text('30 يوم')),
                DropdownMenuItem(value: Duration(days: 90), child: Text('90 يوم')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selected = val;
                  });
                }
              },
            );
          }),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                freezeMarketer(marketer, selected);
                Navigator.pop(ctx);
              },
              child: const Text('تجميد'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sup = selectedSupervisor;
    final marketers = sup?.marketers ?? [];

    final frozen = marketers.where((m) => m.isFrozen).toList();
    final active = marketers.where((m) => !m.isFrozen).toList();

    final totalPoints = marketers.fold<int>(0, (sum, m) => sum + m.points);
    final totalSalary = marketers.fold<double>(0, (sum, m) => sum + m.salary);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المشرفين والمسوقين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'إضافة مشرف',
            onPressed: () => _showSupervisorDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1.3,
          child: Column(children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _simpleStat('المشرفين', supervisors.length.toString(),
                          Icons.supervisor_account),
                      _simpleStat('المسوقين', marketers.length.toString(),
                          Icons.group),
                      _simpleStat('المجمدين', frozen.length.toString(),
                          Icons.lock_outline),
                      _simpleStat('النقاط', totalPoints.toString(),
                          Icons.star_outline),
                      _simpleStat('الرواتب', totalSalary.toStringAsFixed(1) + ' ر.س',
                          Icons.attach_money_outlined),
                    ]),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<Supervisor>(
              isExpanded: true,
              value: sup,
              items: supervisors
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.fullName)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedSupervisor = val;
                });
              },
            ),
            if (sup != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: sup.profileImageFile != null
                          ? FileImage(sup.profileImageFile!)
                          : sup.profileImageUrl != null
                          ? NetworkImage(sup.profileImageUrl!) as ImageProvider
                          : null,
                      child: sup.profileImageFile == null &&
                          sup.profileImageUrl == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      sup.fullName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ]),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'تعديل بيانات المشرف',
                    onPressed: () => _showSupervisorDialog(supervisor: sup),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    tooltip: 'تغيير الصورة الشخصية',
                    onPressed: _pickImageForSupervisor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('إضافة مسوق'),
                onPressed: () => _showMarketerDialog(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 500,
                child: ListView(
                  children: [
                    if (frozen.isNotEmpty)
                      _buildMarketerSection('المسوقين المجمدين', frozen),
                    if (active.isNotEmpty)
                      _buildMarketerSection('المسوقين النشطين', active),
                    if (marketers.isEmpty)
                      const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('لا يوجد مسوقين لهذا المشرف'),
                          )),
                  ],
                ),
              ),
            ]
          ]),
        ),
      ),
    );
  }

  Widget _simpleStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title),
      ],
    );
  }

  Widget _buildMarketerSection(String title, List<Marketer> marketers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(thickness: 1),
        ...marketers.map((m) => _buildMarketerTile(m)).toList(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMarketerTile(Marketer m) {
    final expired = DateTime.now().isAfter(m.promoCodeExpiresAt);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: CircleAvatar(
          backgroundImage: m.profileImageFile != null
              ? FileImage(m.profileImageFile!)
              : m.profileImageUrl != null
              ? NetworkImage(m.profileImageUrl!) as ImageProvider
              : null,
          child: m.profileImageFile == null && m.profileImageUrl == null
              ? const Icon(Icons.person, size: 24)
              : null,
        ),
        title: Row(
          children: [
            Expanded(
                child: Text(m.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            if (m.isFrozen)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red.shade300,
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('مجمّد',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            IconButton(
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'تعديل',
                onPressed: () => _showMarketerDialog(marketer: m)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: [
              _simpleInfoRow('الهاتف', m.phone),
              _simpleInfoRow('الدولة', m.country),
              _simpleInfoRow('المدينة', m.city),
              _simpleInfoRow('البنك', m.bankName),
              _simpleInfoRow('رقم الحساب', m.bankAccountNumber),
              const Divider(),
              _simpleInfoRow('الكود الترويجي', m.promoCode,
                  valueColor: expired ? Colors.red : Colors.black),
              _simpleInfoRow(
                  'تاريخ إنشاء الكود',
                  '${m.promoCodeCreatedAt.year}-${m.promoCodeCreatedAt.month.toString().padLeft(2, '0')}-${m.promoCodeCreatedAt.day.toString().padLeft(2, '0')}'),
              _simpleInfoRow(
                  'تاريخ انتهاء الكود',
                  '${m.promoCodeExpiresAt.year}-${m.promoCodeExpiresAt.month.toString().padLeft(2, '0')}-${m.promoCodeExpiresAt.day.toString().padLeft(2, '0')}',
                  valueColor: expired ? Colors.red : null),
              _simpleInfoRow(
                  'تاريخ الإنشاء',
                  '${m.createdAt.year}-${m.createdAt.month.toString().padLeft(2, '0')}-${m.createdAt.day.toString().padLeft(2, '0')}'),
              _simpleInfoRow('نقاط الترويج', m.points.toString()),
              _simpleInfoRow('الراتب', '${m.salary.toStringAsFixed(2)} ر.س',
                  valueColor: Colors.green.shade700),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: m.isFrozen
                        ? null
                        : () {
                      setState(() {
                        m.regeneratePromoCode();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('كود جديد'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 36),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: m.points > 0
                        ? () {
                      setState(() {
                        m.cashOutSalary();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'تم صرف الراتب للمسوق ${m.fullName}')),
                      );
                    }
                        : null,
                    icon: const Icon(Icons.money_off),
                    label: const Text('صرف الراتب'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 36),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!m.isFrozen)
                    ElevatedButton.icon(
                      onPressed: () => _showFreezeDialog(m),
                      icon: const Icon(Icons.lock),
                      label: const Text('تجميد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          unfreezeMarketer(m);
                        });
                      },
                      icon: const Icon(Icons.lock_open),
                      label: const Text('فك التجميد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                      ),
                    ),
                ],
              )
            ]),
          )
        ],
      ),
    );
  }

  Widget _simpleInfoRow(String label, String value,
      {Color? valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// حوار إضافة وتعديل مشرف مع إمكانية اختيار صورة من الجهاز
class SimpleSupervisorDialog extends StatefulWidget {
  final Supervisor? supervisor;
  final void Function(Supervisor sup) onSave;
  final Future<void> Function()? pickImage;

  const SimpleSupervisorDialog(
  {super.key, this.supervisor, required this.onSave, this.pickImage});

  @override
  State<SimpleSupervisorDialog> createState() => _SimpleSupervisorDialogState();
}

class _SimpleSupervisorDialogState extends State<SimpleSupervisorDialog> {
  final _formKey = GlobalKey<FormState>();

  late String firstName;
  late String middleName;
  late String lastName;
  late String phone;
  late String country;
  late String city;
  late String bankName;
  late String bankAccountNumber;
  File? profileImageFile;
  String? profileImageUrl;
  late String email;
  late String password;

  @override
  void initState() {
    super.initState();
    final sup = widget.supervisor;
    firstName = sup?.firstName ?? '';
    middleName = sup?.middleName ?? '';
    lastName = sup?.lastName ?? '';
    phone = sup?.phone ?? '';
    country = sup?.country ?? '';
    city = sup?.city ?? '';
    bankName = sup?.bankName ?? '';
    bankAccountNumber = sup?.bankAccountNumber ?? '';
    profileImageFile = sup?.profileImageFile;
    profileImageUrl = sup?.profileImageUrl;
    email = sup?.email ?? '';
    password = sup?.password ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.supervisor == null ? 'إضافة مشرف' : 'تعديل مشرف'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField('الاسم الأول', (val) => firstName = val ?? '', firstName),
              _buildField('الاسم الأوسط', (val) => middleName = val ?? '', middleName),
              _buildField('الاسم الأخير', (val) => lastName = val ?? '', lastName),
              _buildField('رقم الهاتف', (val) => phone = val ?? '', phone),
              _buildField('الدولة', (val) => country = val ?? '', country),
              _buildField('المدينة', (val) => city = val ?? '', city),
              _buildField('اسم البنك', (val) => bankName = val ?? '', bankName),
              _buildField('رقم الحساب البنكي', (val) => bankAccountNumber = val ?? '', bankAccountNumber),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('اختيار صورة'),
                    onPressed: () async {
                      if (widget.pickImage != null) {
                        await widget.pickImage!();
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  profileImageFile != null
                      ? CircleAvatar(
                    radius: 25,
                    backgroundImage: FileImage(profileImageFile!),
                  )
                      : profileImageUrl != null
                      ? CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(profileImageUrl!),
                  )
                      : const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person),
                  ),
                ],
              ),
              _buildField('البريد الإلكتروني', (val) => email = val ?? '', email),
              _buildField('كلمة المرور', (val) => password = val ?? '', password,
                  obscure: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final sup = Supervisor(
                id: widget.supervisor?.id ?? const Uuid().v4(),
                firstName: firstName,
                middleName: middleName,
                lastName: lastName,
                phone: phone,
                country: country,
                city: city,
                bankName: bankName,
                bankAccountNumber: bankAccountNumber,
                profileImageFile: profileImageFile,
                profileImageUrl: profileImageUrl,
                email: email,
                password: password,
              );
              widget.onSave(sup);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  Widget _buildField(String label, Function(String?) onChanged, String initialValue,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: initialValue,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
        onChanged: onChanged,
      ),
    );
  }
}

// حوار إضافة وتعديل مسوق مع اختيار صورة من الجهاز
class SimpleMarketerDialog extends StatefulWidget {
  final Marketer? marketer;
  final String supervisorId;
  final void Function(Marketer marketer) onSave;
  final Future<File?> Function()? pickImage;

  const SimpleMarketerDialog(
  {super.key,
  this.marketer,
  required this.supervisorId,
  required this.onSave,
  this.pickImage});

  @override
  State<SimpleMarketerDialog> createState() => _SimpleMarketerDialogState();
}

class _SimpleMarketerDialogState extends State<SimpleMarketerDialog> {
  final _formKey = GlobalKey<FormState>();

  late String firstName;
  late String middleName;
  late String lastName;
  late String phone;
  late String country;
  late String city;
  late String bankName;
  late String bankAccountNumber;
  File? profileImageFile;

  @override
  void initState() {
    super.initState();
    final m = widget.marketer;
    firstName = m?.firstName ?? '';
    middleName = m?.middleName ?? '';
    lastName = m?.lastName ?? '';
    phone = m?.phone ?? '';
    country = m?.country ?? '';
    city = m?.city ?? '';
    bankName = m?.bankName ?? '';
    bankAccountNumber = m?.bankAccountNumber ?? '';
    profileImageFile = m?.profileImageFile;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.marketer == null ? 'إضافة مسوق' : 'تعديل مسوق'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField('الاسم الأول', (val) => firstName = val ?? '', firstName),
              _buildField('الاسم الأوسط', (val) => middleName = val ?? '', middleName),
              _buildField('الاسم الأخير', (val) => lastName = val ?? '', lastName),
              _buildField('رقم الهاتف', (val) => phone = val ?? '', phone),
              _buildField('الدولة', (val) => country = val ?? '', country),
              _buildField('المدينة', (val) => city = val ?? '', city),
              _buildField('اسم البنك', (val) => bankName = val ?? '', bankName),
              _buildField('رقم الحساب البنكي', (val) => bankAccountNumber = val ?? '', bankAccountNumber),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('اختيار صورة'),
                    onPressed: () async {
                      if (widget.pickImage != null) {
                        final file = await widget.pickImage!();
                        if (file != null) {
                          setState(() {
                            profileImageFile = file;
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  profileImageFile != null
                      ? CircleAvatar(
                    radius: 25,
                    backgroundImage: FileImage(profileImageFile!),
                  )
                      : const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final marketer = Marketer(
                id: widget.marketer?.id ?? const Uuid().v4(),
                firstName: firstName,
                middleName: middleName,
                lastName: lastName,
                phone: phone,
                country: country,
                city: city,
                bankName: bankName,
                bankAccountNumber: bankAccountNumber,
                profileImageFile: profileImageFile,
                promoCode: widget.marketer?.promoCode ?? _generatePromoCode(),
                promoCodeCreatedAt:
                widget.marketer?.promoCodeCreatedAt ?? DateTime.now(),
                promoCodeExpiresAt:
                widget.marketer?.promoCodeExpiresAt ??
                    DateTime.now().add(const Duration(days: 30)),
                createdAt: widget.marketer?.createdAt ?? DateTime.now(),
                points: widget.marketer?.points ?? 0,
                supervisorId: widget.supervisorId,
                isFrozen: widget.marketer?.isFrozen ?? false,
              );
              widget.onSave(marketer);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  String _generatePromoCode() => const Uuid().v4().substring(0, 8).toUpperCase();

  Widget _buildField(String label, Function(String?) onChanged, String initialValue,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: initialValue,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
        onChanged: onChanged,
      ),
    );
  }
}
