import '../platform/bridge/native_bridge.dart';
import '../platform/storage/database.dart';
import 'services.dart';

/// Opens the one database connection and wires the repositories to the
/// publisher. Nothing here waits on Kotlin: the first plan is published once
/// the app is on screen.
Future<Services> boot() async {
  final db = await openAppDatabase();
  return Services.wire(db, ChannelNativeBridge());
}
