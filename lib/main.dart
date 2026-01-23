import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

// Pages
import 'presentation/pages/home_page.dart';
import 'presentation/pages/event_detail_page.dart';
import 'presentation/pages/user/my_events_page.dart';
import 'presentation/pages/user/my_event_detail_page.dart';
import 'presentation/pages/user/attendance_page.dart';
import 'presentation/pages/user/certificate_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/admin/attendance_approval_page.dart';
import 'presentation/pages/admin/admin_dashboard_page.dart'; // ADDED

// Providers
import 'providers/event_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/participant_provider.dart';
import 'providers/attendance_provider.dart';

// Use cases & Repositories
import 'presentation/domain/usecases/add_events_usecase.dart';
import 'presentation/domain/usecases/get_events_usecase.dart';
import 'presentation/domain/usecases/check_duplicate_event_usecase.dart';
import 'presentation/data/datasources/firestore_datasource.dart';
import 'presentation/data/datasources/firestore_participant_datasource.dart';
import 'presentation/data/datasources/firestore_attendance_datasource.dart';
import 'presentation/data/repositories/event_repository_impl.dart';
import 'presentation/data/repositories/auth_repository_impl.dart';
import 'presentation/data/repositories/participant_repository_impl.dart';
import 'presentation/data/repositories/attendance_repository_impl.dart';
import 'presentation/services/firebase_auth_service.dart';
import 'presentation/domain/entities/event.dart';
import 'presentation/domain/entities/participant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Indonesian locale for date formatting
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final firestoreDatasource = FirestoreDatasource();
    final eventRepository = EventRepositoryImpl(firestoreDatasource);
    final getEventsUsecase = GetEventsUsecase(eventRepository);
    final addEventUsecase = AddEventUsecase(eventRepository);
    final checkDuplicateEventUsecase = CheckDuplicateEventUsecase(eventRepository);

    // Auth dependencies
    final firebaseAuthService = FirebaseAuthService();
    final authRepository = AuthRepositoryImpl(firebaseAuthService);

    // Participant dependencies
    final firestoreParticipantDatasource = FirestoreParticipantDatasource();
    final participantRepository = ParticipantRepositoryImpl(firestoreParticipantDatasource);

    // Attendance dependencies
    final firestoreAttendanceDatasource = FirestoreAttendanceDatasource();
    final attendanceRepository = AttendanceRepositoryImpl(
      datasource: firestoreAttendanceDatasource,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => EventProvider(
            getEventsUsecase,
            addEventUsecase,
            checkDuplicateEventUsecase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ParticipantProvider(participantRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(
            repository: attendanceRepository,
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Smart Event',
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              useMaterial3: true,
            ),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        final isAuthRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register';

        if (isLoading) {
          return null;
        }

        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        if (isAuthenticated && isAuthRoute) {
          return '/';
        }

        return null;
      },
      
      routes: [
        // Auth Routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        
        // User Routes
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/detail',
          builder: (context, state) {
            final event = state.extra as Event;
            return EventDetailPage(event: event);
          },
        ),
        GoRoute(
          path: '/my-events',
          builder: (context, state) => const MyEventsPage(),
        ),
        GoRoute(
          path: '/my-events/:id',
          builder: (context, state) {
            final participant = state.extra as Participant;
            return MyEventDetailPage(participant: participant);
          },
        ),
        
        // Attendance Routes
        GoRoute(
          path: '/attendance/:eventId/:eventName',
          builder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            final eventName = Uri.decodeComponent(state.pathParameters['eventName']!);
            return AttendancePage(
              eventId: eventId,
              eventName: eventName,
            );
          },
        ),
        
        // Certificate Route
        GoRoute(
          path: '/certificates',
          builder: (context, state) => const CertificatePage(),
        ),
        
        // Admin Routes
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/attendance-approval/:eventId/:eventName',
          builder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            final eventName = Uri.decodeComponent(state.pathParameters['eventName']!);
            return AttendanceApprovalPage(
              eventId: eventId,
              eventName: eventName,
            );
          },
        ),
      ],
      refreshListenable: authProvider,
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Halaman Tidak Ditemukan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Path: ${state.uri}',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}