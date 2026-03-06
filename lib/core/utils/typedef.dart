import 'package:monster_livescore/core/error/failures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ResultFuture<T>
// ─────────────────────────────────────────────────────────────────────────────
//
// This is the ONLY return type used by every repository method and use case
// in the app. Understanding it is essential for reading any domain contract.
//
// WHAT IT IS
//   A Future of a Dart 3 named record with two nullable fields:
//     { T? data, Failure? failure }
//
// INVARIANT (always holds):
//   Exactly ONE field is non-null. Never both, never neither.
//     ✅ (data: someValue, failure: null)   → success
//     ✅ (data: null, failure: SomeFailure) → error
//     ❌ (data: someValue, failure: SomeFailure) — never
//     ❌ (data: null, failure: null)             — never
//
// WHY NOT dartz / fpdart?
//   Dart 3 records give us the same compile-time guarantee without an
//   external dependency. `switch` on the record fields is exhaustive.
//
// HOW TO READ A RESULT IN A BLOC
//   final result = await getExamples(const NoParams());
//   if (result.failure != null) {
//     // handle result.failure (a Failure subtype)
//   } else {
//     // use result.data (guaranteed non-null here)
//   }
//
// HOW TO RETURN A RESULT FROM A REPOSITORY IMPL
//   On success : return (data: entities, failure: null);
//   On failure : return (data: null,     failure: ServerFailure(message: '…'));
//
// ─────────────────────────────────────────────────────────────────────────────

/// Universal return type for all repository methods and use cases.
///
/// See the inline comments above for the full contract, invariants,
/// and usage examples.
typedef ResultFuture<T> = Future<({T? data, Failure? failure})>;

