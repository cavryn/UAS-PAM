import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pages
import 'presentation/pages/home_page.dart';
import 'presentation/pages/event_detail_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';

// Providers
import 'providers/event_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/participant_provider.dart';

// Use cases & Repositories
import 'presentation/domain/usecases/add_events_usecase.dart';
import 'presentation/domain/usecases/get_events_usecase.dart';
import 'presentation/domain/usecases/check_duplicate_event_usecase.dart';
import 'presentation/data/datasources/firestore_datasource.dart';
import 'presentation/data/datasources/firestore_participant_datasource.dart';
import 'presentation/data/repositories/event_repository_impl.dart';
import 'presentation/data/repositories/auth_repository_impl.dart';
import 'presentation/data/repositories/participant_repository_impl.dart';
import 'presentation/services/firebase_auth_service.dart';
import 'presentation/domain/entities/event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
      initialLocation: '/login', // Selalu mulai dari login
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        final isAuthRoute = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register';

        // Jika masih loading, jangan redirect
        if (isLoading) {
          return null;
        }

        // Jika belum login dan bukan di halaman auth, redirect ke login
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // Jika sudah login dan di halaman auth, redirect ke home
        if (isAuthenticated && isAuthRoute) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
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
      ],
      refreshListenable: authProvider, // PENTING: Ini akan refresh router saat auth berubah
    );
  }
}