import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'presentation/pages/home_page.dart';
import 'presentation/pages/event_detail_page.dart';
import 'presentation/domain/usecases/get_events_usecase.dart';
import 'presentation/domain/repositories/event_repository.dart';
import 'presentation/data/datasources/firestore_datasource.dart';
import 'presentation/data/repositories/event_repository_impl.dart';
import 'providers/event_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

    return MultiProvider(
      providers: [
        // DataSource Layer
        Provider<FirestoreDatasource>(
          create: (_) => FirestoreDatasource(),
        ),
        
        // Repository Layer
        ProxyProvider<FirestoreDatasource, EventRepository>(
          update: (_, datasource, __) => EventRepositoryImpl(datasource),
        ),
        
        // UseCase Layer
        ProxyProvider<EventRepository, GetEventsUsecase>(
          update: (_, repository, __) => GetEventsUsecase(repository),
        ),
        
        // Provider Layer
        ChangeNotifierProxyProvider<GetEventsUsecase, EventProvider>(
          create: (context) => EventProvider(
            context.read<GetEventsUsecase>(),
          ),
          update: (_, usecase, __) => EventProvider(usecase),
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