/// MockData — the single source of truth for the in-memory mock backend.
///
/// Seeds itself with the EXACT data from `docs/design/mockups/app-v2.html`:
/// 4 Isles (LSAT crew, Morning runners, HLS '26, Book club), each with sparks
/// (a mix of ritual + metric modes), posts, messages, and memberships.
///
/// Use the model constructors directly (NOT fromJson). Dates are pinned to
/// early July 2026 so the mockup stays stable.
library;

import '../../models/dependency.dart';
import '../../models/enums.dart';
import '../../models/friend.dart';
import '../../models/isle.dart';
import '../../models/membership.dart';
import '../../models/message.dart';
import '../../models/metric.dart';
import '../../models/post.dart';
import '../../models/spark.dart';
import '../../models/user.dart';

/// A singleton bag of in-memory state. All Riverpod notifiers in
/// `mock_providers.dart` initialize from [instance].
class MockData {
  MockData._() {
    currentUser = _seedCurrentUser();
    isles = _seedIsles();
    memberships = _seedMemberships();
    friends = _seedFriends();
    discover = _seedDiscover();
  }

  /// The single shared instance.
  static final MockData instance = MockData._();

  /// Stable user ids used across memberships / messages / friends.
  static const String meId = 'u-jasper';
  static const String samId = 'u-sam';
  static const String priyaId = 'u-priya';
  static const String diegoId = 'u-diego';
  static const String miaId = 'u-mia';
  static const String liaId = 'u-lia';
  static const String alexId = 'u-alex';
  static const String jordanId = 'u-jordan';
  static const String tomId = 'u-tom';

  /// Isle ids.
  static const String lsatIsleId = 'is-lsat';
  static const String runnersIsleId = 'is-runners';
  static const String hlsIsleId = 'is-hls';
  static const String booksIsleId = 'is-books';

  /// The signed-in account.
  late final User currentUser;

  /// All Isles (active + inactive). Active = has at least one spark.
  late final List<Isle> isles;

  /// Memberships keyed by isleId. Creator is always index 0.
  late final Map<String, List<Membership>> memberships;

  /// Friend relationships from the current user's perspective.
  late final List<Friend> friends;

  /// Discoverable public Isles (raw rows, matching the mockup).
  late final List<Map<String, dynamic>> discover;

  // ---------------------------------------------------------------------------
  // SEEDERS
  // ---------------------------------------------------------------------------

  User _seedCurrentUser() => const User(
        id: meId,
        name: 'Jasper',
        handle: 'jasper',
        avatar: '🧑',
        bio: 'Studying for the December LSAT. Shooting for a 170+. 📈',
      );

  List<Isle> _seedIsles() {
    final created = DateTime(2026, 6, 1);
    return [
      // ---- LSAT crew ----
      Isle(
        id: lsatIsleId,
        name: 'LSAT crew',
        emoji: '📈',
        purpose: 'crushing the December test together',
        color: 'blue',
        visibility: IsleVisibility.private,
        createdBy: meId,
        createdAt: created,
        sparks: [
          // 0 — Weekly average (metric, personal, main)
          Spark(
            id: 'lsat-0',
            isleId: lsatIsleId,
            emoji: '📈',
            title: 'Weekly average',
            mode: SparkMode.metric,
            scope: SparkScope.personal,
            state: SparkState.lit,
            streak: 4,
            timerMode: TimerMode.weekly,
            isMain: true,
            metric: const Metric(
              template: MetricTemplate.avgImprove,
              target: 0,
              currentValue: 168,
              previousValue: 162,
              trend: 'up',
            ),
            thread: [
              Message(
                id: 'lsat-0-t1',
                chatId: 'thread-lsat-0',
                senderId: meId,
                senderName: 'Jasper',
                senderAvatar: '🧑',
                content: '168 on PT 89 today',
                createdAt: DateTime(2026, 7, 7, 8, 0),
              ),
              Message(
                id: 'lsat-0-t2',
                chatId: 'thread-lsat-0',
                senderId: priyaId,
                senderName: 'Priya',
                senderAvatar: '👩',
                big: '🔥',
                createdAt: DateTime(2026, 7, 7, 8, 5),
              ),
              Message(
                id: 'lsat-0-t3',
                chatId: 'thread-lsat-0',
                senderId: samId,
                senderName: 'Sam',
                senderAvatar: '🧑‍🦰',
                content: 'got a 174!!',
                createdAt: DateTime(2026, 7, 7, 5, 0),
              ),
            ],
            createdAt: created,
          ),
          // 1 — Study (ritual, shared)
          Spark(
            id: 'lsat-1',
            isleId: lsatIsleId,
            emoji: '📚',
            title: 'Study',
            mode: SparkMode.ritual,
            scope: SparkScope.shared,
            state: SparkState.lit,
            streak: 7,
            timerMode: TimerMode.daily,
            dependencies: [
              Dependency(
                id: 'lsat-1-d0',
                sparkId: 'lsat-1',
                emoji: '📚',
                satisfied: true,
                createdAt: created,
              ),
            ],
            createdAt: created,
          ),
          // 2 — Timed sections (metric, personal)
          Spark(
            id: 'lsat-2',
            isleId: lsatIsleId,
            emoji: '⏱️',
            title: 'Timed sections',
            mode: SparkMode.metric,
            scope: SparkScope.personal,
            state: SparkState.lit,
            streak: 2,
            timerMode: TimerMode.weekly,
            metric: const Metric(
              template: MetricTemplate.count,
              target: 3,
              currentValue: 3,
              previousValue: 2,
              trend: 'up',
            ),
            createdAt: created,
          ),
          // 3 — LR drilling (ritual, shared, greyed)
          Spark(
            id: 'lsat-3',
            isleId: lsatIsleId,
            emoji: '🧩',
            title: 'LR drilling',
            mode: SparkMode.ritual,
            scope: SparkScope.shared,
            state: SparkState.greyed,
            streak: 0,
            timerMode: TimerMode.daily,
            dependencies: [
              Dependency(
                id: 'lsat-3-d0',
                sparkId: 'lsat-3',
                emoji: '🧩',
                satisfied: false,
                createdAt: created,
              ),
            ],
            createdAt: created,
          ),
        ],
        posts: [
          Post(
            id: 'lsat-p0',
            authorId: priyaId,
            authorName: 'Priya',
            authorAvatar: '👩',
            text: 'Got into Columbia!! ',
            emoji: '🎉',
            imageUrl: 'https://picsum.photos/seed/lsat-score/280/120',
            audience: const [lsatIsleId],
            createdAt: DateTime(2026, 7, 7, 6, 0),
          ),
        ],
        msgs: [
          Message(
            id: 'lsat-m1',
            chatId: lsatIsleId,
            senderId: priyaId,
            senderName: 'Priya',
            senderAvatar: '👩',
            content: 'got a 174 on PT 89 today',
            createdAt: DateTime(2026, 7, 7, 7, 0),
          ),
          Message(
            id: 'lsat-m2',
            chatId: lsatIsleId,
            senderId: samId,
            senderName: 'Sam',
            senderAvatar: '🧑‍🦰',
            big: '🔥',
            createdAt: DateTime(2026, 7, 7, 7, 2),
          ),
          Message(
            id: 'lsat-m3',
            chatId: lsatIsleId,
            senderId: diegoId,
            senderName: 'Diego',
            senderAvatar: '🧑‍🦱',
            content: 'anyone doing games tonight?',
            createdAt: DateTime(2026, 7, 7, 7, 10),
          ),
        ],
      ),

      // ---- Morning runners ----
      Isle(
        id: runnersIsleId,
        name: 'Morning runners',
        emoji: '🏃',
        purpose: '5K before coffee',
        color: 'green',
        visibility: IsleVisibility.private,
        createdBy: meId,
        createdAt: created,
        sparks: [
          // 0 — Morning run (ritual, shared, main)
          Spark(
            id: 'run-0',
            isleId: runnersIsleId,
            emoji: '🏃',
            title: 'Morning run',
            mode: SparkMode.ritual,
            scope: SparkScope.shared,
            state: SparkState.lit,
            streak: 12,
            timerMode: TimerMode.daily,
            isMain: true,
            dependencies: [
              Dependency(
                id: 'run-0-d0',
                sparkId: 'run-0',
                emoji: '🏃',
                satisfied: true,
                createdAt: created,
              ),
            ],
            createdAt: created,
          ),
          // 1 — Hydrate (ritual, shared)
          Spark(
            id: 'run-1',
            isleId: runnersIsleId,
            emoji: '💧',
            title: 'Hydrate',
            mode: SparkMode.ritual,
            scope: SparkScope.shared,
            state: SparkState.lit,
            streak: 5,
            timerMode: TimerMode.daily,
            dependencies: [
              Dependency(
                id: 'run-1-d0',
                sparkId: 'run-1',
                emoji: '💧',
                satisfied: true,
                createdAt: created,
              ),
            ],
            createdAt: created,
          ),
        ],
        posts: const [],
        msgs: [
          Message(
            id: 'run-m1',
            chatId: runnersIsleId,
            senderId: liaId,
            senderName: 'Lia',
            senderAvatar: '👩',
            content: '5K done!',
            createdAt: DateTime(2026, 7, 7, 7, 30),
          ),
          Message(
            id: 'run-m2',
            chatId: runnersIsleId,
            senderId: meId,
            senderName: 'Jasper',
            senderAvatar: '🧑',
            big: '🏃',
            createdAt: DateTime(2026, 7, 7, 7, 33),
          ),
        ],
      ),

      // ---- HLS '26 ----
      Isle(
        id: hlsIsleId,
        name: "HLS '26",
        emoji: '🎓',
        purpose: 'Harvard Law admitted 2026',
        color: 'violet',
        visibility: IsleVisibility.public,
        createdBy: meId,
        createdAt: created,
        sparks: [
          // 0 — Welcome post (ritual, personal, main, greyed)
          Spark(
            id: 'hls-0',
            isleId: hlsIsleId,
            emoji: '🎓',
            title: 'Welcome post',
            mode: SparkMode.ritual,
            scope: SparkScope.personal,
            state: SparkState.greyed,
            streak: 0,
            timerMode: TimerMode.monthly,
            isMain: true,
            createdAt: created,
          ),
        ],
        posts: [
          Post(
            id: 'hls-p0',
            authorId: alexId,
            authorName: 'Alex',
            authorAvatar: '🧑',
            text: 'So excited to meet everyone in August! ',
            emoji: '🎓',
            audience: const [hlsIsleId],
            createdAt: DateTime(2026, 7, 6, 10, 0),
          ),
        ],
        msgs: [
          Message(
            id: 'hls-m1',
            chatId: hlsIsleId,
            senderId: alexId,
            senderName: 'Alex',
            senderAvatar: '🧑',
            content: 'orientation dates are up',
            createdAt: DateTime(2026, 7, 6, 10, 5),
          ),
        ],
      ),

      // ---- Book club ----
      Isle(
        id: booksIsleId,
        name: 'Book club',
        emoji: '📖',
        purpose: 'one book a month',
        color: 'amber',
        visibility: IsleVisibility.private,
        createdBy: meId,
        createdAt: created,
        sparks: [
          // 0 — Read (ritual, shared, main, dull/uncomp)
          Spark(
            id: 'book-0',
            isleId: booksIsleId,
            emoji: '📖',
            title: 'Read',
            mode: SparkMode.ritual,
            scope: SparkScope.shared,
            state: SparkState.dull,
            streak: 0,
            timerMode: TimerMode.daily,
            isMain: true,
            dependencies: [
              Dependency(
                id: 'book-0-d0',
                sparkId: 'book-0',
                emoji: '📖',
                satisfied: false,
                createdAt: created,
              ),
            ],
            createdAt: created,
          ),
        ],
        posts: const [],
        msgs: const [],
      ),
    ];
  }

  Map<String, List<Membership>> _seedMemberships() {
    final joined = DateTime(2026, 6, 1);
    return {
      lsatIsleId: [
        Membership(
          isleId: lsatIsleId,
          userId: meId,
          userName: 'Jasper',
          userAvatar: '🧑',
          role: 'creator',
          joinedAt: joined,
        ),
        Membership(
          isleId: lsatIsleId,
          userId: samId,
          userName: 'Sam',
          userAvatar: '🧑‍🦰',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: lsatIsleId,
          userId: priyaId,
          userName: 'Priya',
          userAvatar: '👩',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: lsatIsleId,
          userId: diegoId,
          userName: 'Diego',
          userAvatar: '🧑‍🦱',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: lsatIsleId,
          userId: miaId,
          userName: 'Mia',
          userAvatar: '🧑‍🦲',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: lsatIsleId,
          userId: liaId,
          userName: 'Lia',
          userAvatar: '👩',
          role: 'member',
          joinedAt: joined,
        ),
      ],
      runnersIsleId: [
        Membership(
          isleId: runnersIsleId,
          userId: meId,
          userName: 'Jasper',
          userAvatar: '🧑',
          role: 'creator',
          joinedAt: joined,
        ),
        Membership(
          isleId: runnersIsleId,
          userId: liaId,
          userName: 'Lia',
          userAvatar: '👩',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: runnersIsleId,
          userId: samId,
          userName: 'Sam',
          userAvatar: '🧑‍🦰',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: runnersIsleId,
          userId: diegoId,
          userName: 'Diego',
          userAvatar: '🧑‍🦱',
          role: 'member',
          joinedAt: joined,
        ),
      ],
      hlsIsleId: [
        Membership(
          isleId: hlsIsleId,
          userId: meId,
          userName: 'Jasper',
          userAvatar: '🧑',
          role: 'creator',
          joinedAt: joined,
        ),
        Membership(
          isleId: hlsIsleId,
          userId: alexId,
          userName: 'Alex',
          userAvatar: '🧑',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: hlsIsleId,
          userId: jordanId,
          userName: 'Jordan',
          userAvatar: '👩',
          role: 'member',
          joinedAt: joined,
        ),
      ],
      booksIsleId: [
        Membership(
          isleId: booksIsleId,
          userId: meId,
          userName: 'Jasper',
          userAvatar: '🧑',
          role: 'creator',
          joinedAt: joined,
        ),
        Membership(
          isleId: booksIsleId,
          userId: liaId,
          userName: 'Lia',
          userAvatar: '👩',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: booksIsleId,
          userId: miaId,
          userName: 'Mia',
          userAvatar: '🧑‍🦱',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: booksIsleId,
          userId: tomId,
          userName: 'Tom',
          userAvatar: '👨',
          role: 'member',
          joinedAt: joined,
        ),
        Membership(
          isleId: booksIsleId,
          userId: priyaId,
          userName: 'Priya',
          userAvatar: '👩',
          role: 'member',
          joinedAt: joined,
        ),
      ],
    };
  }

  List<Friend> _seedFriends() {
    final added = DateTime(2026, 6, 15);
    return [
      Friend(
        id: 'fr-sam',
        userId: meId,
        friendId: samId,
        friendName: 'Sam',
        friendAvatar: '🧑‍🦰',
        status: 'accepted',
        createdAt: added,
      ),
      Friend(
        id: 'fr-lia',
        userId: meId,
        friendId: liaId,
        friendName: 'Lia',
        friendAvatar: '👩',
        status: 'accepted',
        createdAt: added,
      ),
      Friend(
        id: 'fr-priya',
        userId: meId,
        friendId: priyaId,
        friendName: 'Priya',
        friendAvatar: '👩',
        status: 'accepted',
        createdAt: added,
      ),
      Friend(
        id: 'fr-mia',
        userId: meId,
        friendId: miaId,
        friendName: 'Mia',
        friendAvatar: '🧑‍🦱',
        status: 'pending_in',
        createdAt: added,
      ),
      Friend(
        id: 'fr-tom',
        userId: meId,
        friendId: tomId,
        friendName: 'Tom',
        friendAvatar: '👨',
        status: 'pending_out',
        createdAt: added,
      ),
    ];
  }

  /// Discoverable public Isles. Color stored as the plain swatch name so it
  /// stays consistent with [Isle.color].
  List<Map<String, dynamic>> _seedDiscover() => [
        {
          'name': 'Columbia Law 2026',
          'emoji': '⚖️',
          'color': 'blue',
          'members': 128,
          'sub': 'admitted students',
        },
        {
          'name': 'NYU Law 2026',
          'emoji': '🗽',
          'color': 'teal',
          'members': 96,
          'sub': 'admitted students',
        },
        {
          'name': 'LSAT December',
          'emoji': '📝',
          'color': 'orange',
          'members': 312,
          'sub': 'everyone taking the Dec test',
        },
        {
          'name': 'Yale Law 2026',
          'emoji': '🎓',
          'color': 'indigo',
          'members': 34,
          'sub': 'admitted students',
        },
        {
          'name': '170+ Club',
          'emoji': '🎯',
          'color': 'rose',
          'members': 87,
          'sub': 'shooting for top scores',
        },
        {
          'name': 'Logic Games Gang',
          'emoji': '🧩',
          'color': 'green',
          'members': 54,
          'sub': 'LG drilling',
        },
      ];
}
