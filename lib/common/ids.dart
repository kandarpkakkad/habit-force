import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// UUID v7: time-ordered, so id order is creation order (D21). Events minted
/// by Kotlin are the exception and are ordered by their `at` instead.
String newId() => _uuid.v7();
