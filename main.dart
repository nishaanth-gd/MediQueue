import 'package:flutter/material.dart';

void main() {
  runApp(const MediQueueApp());
}

// MAIN APP
class MediQueueApp extends StatelessWidget {
  const MediQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediQueue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// HOME SCREEN
// HOME SCREEN
// HOME SCREEN
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MediQueue'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_hospital,
              size: 80,
              color: Colors.teal,
            ),

            const SizedBox(height: 20),

            const Text(
              'Welcome to MediQueue',
              style: TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 30),

            // GET A TOKEN
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookingScreen(),
                  ),
                );
              },
              child: const Text('Get a Token'),
            ),

            const SizedBox(height: 12),

            // VIEW QUEUE
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QueueScreen(),
                  ),
                );
              },
              child: const Text('View Queue'),
            ),

            const SizedBox(height: 12),

            // DOCTOR DASHBOARD
            FilledButton.tonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorDashboard(),
                  ),
                );
              },
              child: const Text('Doctor Dashboard'),
            ),

            const SizedBox(height: 12),

            // RECEPTIONIST DASHBOARD
            FilledButton.tonal(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReceptionistDashboard(),
                  ),
                );
              },
              child: const Text('Receptionist Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

// BOOKING RECORD
class BookingRecord {
  final String patientName;
  final int age;
  final String hospital;
  final String department;
  final String doctor;
  final int tokenNumber;

  BookingRecord({
    required this.patientName,
    required this.age,
    required this.hospital,
    required this.department,
    required this.doctor,
    required this.tokenNumber,
  });
}

// BOOKING STORAGE AND TOKEN GENERATOR
// BOOKING STORAGE AND TOKEN GENERATOR
class BookingStore {
  static final List<BookingRecord> bookings = [];

  static final Map<String, int> nextTokens = {};

  static final Map<String, int> currentTokens = {};
  static final Map<String, int> completedTokens = {};

  // Generate token number
  static int generateToken(String doctor) {
    int next = nextTokens[doctor] ?? 100;

    next++;

    nextTokens[doctor] = next;

    currentTokens.putIfAbsent(doctor, () => 100);

    return next;
  }

  // Calculate patients waiting ahead
  static int patientsAhead(int tokenNumber, String doctor) {
    int current = currentTokens[doctor] ?? 100;

    return tokenNumber - current - 1;
  }

  // Calculate estimated waiting time
  static int waitingTime(int tokenNumber, String doctor) {
    int patients = patientsAhead(tokenNumber, doctor);

    return patients * 10;
  }
  // Mark consultation as completed
static void completeConsultation(String doctor) {
  int current = currentTokens[doctor] ?? 100;

  completedTokens[doctor] = current;
}
}
// BOOKING SCREEN
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String? hospital;
  String? department;
  String? doctor;

  void bookToken() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final token = BookingStore.generateToken(doctor!);

    final booking = BookingRecord(
      patientName: nameController.text.trim(),
      age: int.parse(ageController.text),
      hospital: hospital!,
      department: department!,
      doctor: doctor!,
      tokenNumber: token,
    );

    BookingStore.bookings.add(booking);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Booking Successful!'),
          content: Text(
            'Patient: ${booking.patientName}\n'
            'Doctor: ${booking.doctor}\n'
            'Hospital: ${booking.hospital}\n'
            'Token Number: ${booking.tokenNumber}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Your Token'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Text(
                'Patient Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final age = int.tryParse(value ?? '');
                  if (age == null || age < 1 || age > 120) {
                    return 'Enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              const Text(
                'Appointment Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: hospital,
                decoration: const InputDecoration(
                  labelText: 'Select Hospital',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'City Hospital',
                  'General Hospital',
                ].map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    hospital = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select hospital' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: department,
                decoration: const InputDecoration(
                  labelText: 'Select Department',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Cardiology',
                  'General Medicine',
                  'Orthopedics',
                ].map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    department = value;
                    doctor = null;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select department' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                // The key rebuilds this field (clearing it) when department changes
                key: ValueKey(department),
                initialValue: doctor,
                decoration: const InputDecoration(
                  labelText: 'Select Doctor',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Dr. Arun',
                  'Dr. Kumar',
                  'Dr. Priya',
                ].map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    doctor = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select doctor' : null,
              ),
              const SizedBox(height: 25),
              FilledButton.icon(
                onPressed: bookToken,
                icon: const Icon(Icons.confirmation_number),
                label: const Text('Book Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// LIVE QUEUE SCREEN
// LIVE QUEUE SCREEN
// LIVE QUEUE SCREEN
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = BookingStore.bookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Queue'),
      ),

      body: bookings.isEmpty
          ? const Center(
              child: Text(
                'No bookings available yet',
                style: TextStyle(fontSize: 20),
              ),
            )

          : ListView.builder(
              itemCount: bookings.length,

              itemBuilder: (context, index) {
                final booking = bookings[index];

                final ahead = BookingStore.patientsAhead(
                  booking.tokenNumber,
                  booking.doctor,
                );

                final waiting = BookingStore.waitingTime(
                  booking.tokenNumber,
                  booking.doctor,
                );

                final currentToken =
                    BookingStore.currentTokens[booking.doctor] ?? 100;

                return Card(
                  margin: const EdgeInsets.all(12),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          booking.patientName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Token Number: ${booking.tokenNumber}',
                        ),

                        Text(
                          'Currently Serving: $currentToken',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text('Doctor: ${booking.doctor}'),

                        Text('Hospital: ${booking.hospital}'),

                        Text('Department: ${booking.department}'),

                        const Divider(),

                        Text('Patients Ahead: $ahead'),

                        Text(
                          'Estimated Waiting Time: $waiting minutes',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// DOCTOR DASHBOARD
// DOCTOR DASHBOARD
// DOCTOR DASHBOARD
// DOCTOR DASHBOARD
// DOCTOR DASHBOARD
class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() =>
      _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {

  void callNextPatient(String doctor) {
    setState(() {
      int current =
          BookingStore.currentTokens[doctor] ?? 100;

      int lastToken = 100;

      for (var booking in BookingStore.bookings) {
        if (booking.doctor == doctor &&
            booking.tokenNumber > lastToken) {
          lastToken = booking.tokenNumber;
        }
      }

      if (current < lastToken) {
        BookingStore.currentTokens[doctor] = current + 1;
      }
    });
  }

  void completePatient(String doctor) {
    setState(() {
      BookingStore.completeConsultation(doctor);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation completed!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = BookingStore.bookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
      ),

      body: bookings.isEmpty
          ? const Center(
              child: Text('No patients booked yet'),
            )
          : ListView(
              children: [
                ...bookings.map((booking) {
                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          '${booking.tokenNumber}',
                        ),
                      ),
                      title: Text(booking.patientName),
                      subtitle: Text(
                        'Token: ${booking.tokenNumber}\n'
                        'Doctor: ${booking.doctor}\n'
                        'Age: ${booking.age}',
                      ),
                    ),
                  );
                }),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          callNextPatient(
                            bookings.first.doctor,
                          );
                        },
                        icon: const Icon(Icons.campaign),
                        label: const Text(
                          'Call Next Patient',
                        ),
                      ),

                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () {
                          completePatient(
                            bookings.first.doctor,
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text(
                          'Complete Consultation',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// RECEPTIONIST DASHBOARD
// RECEPTIONIST DASHBOARD
// RECEPTIONIST DASHBOARD
class ReceptionistDashboard extends StatefulWidget {
  const ReceptionistDashboard({super.key});

  @override
  State<ReceptionistDashboard> createState() =>
      _ReceptionistDashboardState();
}

class _ReceptionistDashboardState
    extends State<ReceptionistDashboard> {

  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String? selectedDoctor;

  final List<String> doctors = [
    'Dr. Arun',
    'Dr. Kumar',
    'Dr. Priya',
  ];

  void addWalkInPatient() {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text);

    if (name.isEmpty ||
        age == null ||
        age < 1 ||
        age > 120 ||
        selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid patient details'),
        ),
      );
      return;
    }

    setState(() {
      final token =
          BookingStore.generateToken(selectedDoctor!);

      BookingStore.bookings.add(
        BookingRecord(
          patientName: name,
          age: age,
          hospital: 'City Hospital',
          department: 'General Medicine',
          doctor: selectedDoctor!,
          tokenNumber: token,
        ),
      );

      nameController.clear();
      ageController.clear();
      selectedDoctor = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Walk-in token generated successfully!'),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = BookingStore.bookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receptionist Dashboard'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          const Text(
            'Register Walk-in Patient',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Patient Name',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Patient Age',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            initialValue: selectedDoctor,
            decoration: const InputDecoration(
              labelText: 'Select Doctor',
              border: OutlineInputBorder(),
            ),
            items: doctors.map((doctor) {
              return DropdownMenuItem(
                value: doctor,
                child: Text(doctor),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDoctor = value;
              });
            },
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: addWalkInPatient,
            icon: const Icon(Icons.add),
            label: const Text('Generate Walk-in Token'),
          ),

          const Divider(height: 40),

          const Text(
            'All Patient Bookings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          ...bookings.map((booking) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${booking.tokenNumber}'),
                ),
                title: Text(booking.patientName),
                subtitle: Text(
                  'Doctor: ${booking.doctor}\n'
                  'Token: ${booking.tokenNumber}',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}