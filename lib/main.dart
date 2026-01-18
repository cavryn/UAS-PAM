import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'presentation/pages/home_page.dart';
import 'presentation/pages/event_detail_page.dart';
import 'providers/event_provider.dart';
import 'presentation/domain/usecases/add_events_usecase.dart';
import 'presentation/domain/usecases/get_events_usecase.dart';
import 'presentation/domain/usecases/check_duplicate_event_usecase.dart'; // TAMBAHAN BARU
import 'presentation/data/datasources/firestore_datasource.dart';
import 'presentation/data/repositories/event_repository_impl.dart';

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
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/detail',
          builder: (context, state) {
            final eventName = state.extra as String;
            return EventDetailPage(eventName: eventName);
          },
        ),
      ],
    );

    // Inisialisasi semua dependencies
    final firestoreDatasource = FirestoreDatasource();
    final eventRepository = EventRepositoryImpl(firestoreDatasource);
    final getEventsUsecase = GetEventsUsecase(eventRepository);
    final addEventUsecase = AddEventUsecase(eventRepository);
    final checkDuplicateEventUsecase = CheckDuplicateEventUsecase(eventRepository); // TAMBAHAN BARU

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EventProvider(
            getEventsUsecase,
            addEventUsecase,
            checkDuplicateEventUsecase, // TAMBAHAN BARU
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Smart Event',
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
      ),
    );
  }
}