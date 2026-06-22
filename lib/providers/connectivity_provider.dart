import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  ConnectivityNotifier() : super(ConnectivityStatus.online) {
    // DISABLED FOR MOCKUP - connectivity_plus can cause issues on web
    // _init();
  }

  Future<void> _init() async {
    // DISABLED FOR MOCKUP
    // final connectivity = Connectivity();
    // final result = await connectivity.checkConnectivity();

    // state = result == ConnectivityResult.none
    //     ? ConnectivityStatus.offline
    //     : ConnectivityStatus.online;

    // // Listen for changes
    // connectivity.onConnectivityChanged.listen((result) {
    //   state = result == ConnectivityResult.none
    //       ? ConnectivityStatus.offline
    //       : ConnectivityStatus.online;
    // });
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});