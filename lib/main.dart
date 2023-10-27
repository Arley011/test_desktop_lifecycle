import 'package:flutter/material.dart';
import 'package:flutter_desktop_sleep/flutter_desktop_sleep.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _statusesListNotifier = ValueNotifier<List<String>>([]);
  late final AppLifecycleListener _appLifecycleListener;

  @override
  void initState() {
    super.initState();

    // Initialize the AppLifecycleListener class and pass callbacks
    _appLifecycleListener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );

    // Initialize plugin's listener
    FlutterDesktopSleep flutterDesktopSleep = FlutterDesktopSleep();
    flutterDesktopSleep.setWindowSleepHandler((String? s) async {
      _statusesListNotifier.value = [
        ..._statusesListNotifier.value,
        '${DateTime.now().toIso8601String()} -> FlutterDesktopSleep plugin -> $s',
      ];
    });
  }

  @override
  void dispose() {
    // Do not forget to dispose the listener
    _appLifecycleListener.dispose();

    super.dispose();
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    _statusesListNotifier.value = [
      ..._statusesListNotifier.value,
      '${DateTime.now().toIso8601String()} -> AppLifecycleListener -> ${state.name}',
    ];
    switch (state) {
      case AppLifecycleState.detached:
        _onDetached();
      case AppLifecycleState.resumed:
        _onResumed();
      case AppLifecycleState.inactive:
        _onInactive();
      case AppLifecycleState.hidden:
        _onHidden();
      case AppLifecycleState.paused:
        _onPaused();
    }
  }

  void _onDetached() => print('detached');

  void _onResumed() => print('resumed');

  void _onInactive() => print('inactive');

  void _onHidden() => print('hidden');

  void _onPaused() => print('paused');

  void _clear() {
    _statusesListNotifier.value = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Here are states history:',
            ),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                  valueListenable: _statusesListNotifier,
                  builder: (context, statuses, _) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: statuses.length,
                      itemBuilder: (_, index) {
                        return Text(statuses[index]);
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clear,
        tooltip: 'Clear',
        child: const Icon(Icons.cleaning_services_rounded),
      ),
    );
  }
}
