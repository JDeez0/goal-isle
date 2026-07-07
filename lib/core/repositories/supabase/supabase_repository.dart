import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/enums.dart';
import '../../models/isle.dart';
import '../../models/spark.dart';
import '../../models/metric.dart';
import '../../models/dependency.dart';
import '../../models/message.dart';
import '../../models/post.dart';
import '../../models/membership.dart';
import '../../models/friend.dart';
import '../../models/spark_shape.dart';
import 'supabase_client.dart';

/// Central data repository — all Supabase queries.
/// Each method maps raw Postgres rows to/from our model classes.
class SupabaseRepository {
  static SupabaseClient get _db => SupabaseConfig.client;
  static String? get _uid => _db.auth.currentUser?.id;

  // ============================================================
  // ISLES
  // ============================================================

  /// Fetch all Isles the current user is a member of, with nested sparks.
  static Future<List<Isle>> fetchIsles() async {
    if (_uid == null) return [];

    // Get isle IDs from memberships
    final memberRows = await _db.from('memberships').select('isle_id').eq('user_id', _uid!);
    final isleIds = (memberRows as List).map((r) => (r as Map)['isle_id'] as String).toList();

    if (isleIds.isEmpty) return [];

    // Fetch isles
    final isleRows = await _db.from('isles').select().inFilter('id', isleIds);
    final publicIsles = await _db.from('isles').select().eq('visibility', 'public');
    
    // Merge (member isles + public isles, deduped)
    final allIsleRows = <Map<String, dynamic>>[];
    final seenIds = <String>{};
    for (final row in [...isleRows, ...publicIsles]) {
      final id = row['id'] as String;
      if (!seenIds.contains(id)) {
        seenIds.add(id);
        allIsleRows.add(row);
      }
    }

    // For each isle, fetch its sparks
    final isles = <Isle>[];
    for (final row in allIsleRows) {
      final isleId = row['id'] as String;
      final sparks = await fetchSparks(isleId);
      final posts = await fetchPostsForIsle(isleId);
      final msgs = await fetchMessages(isleId);

      isles.add(Isle(
        id: isleId,
        name: row['name'] ?? '',
        emoji: row['main_emoji'] ?? '',
        purpose: row['purpose'],
        color: row['color'] ?? 'blue',
        visibility: row['visibility'] == 'public' ? IsleVisibility.public : IsleVisibility.private,
        createdBy: row['created_by'] ?? '',
        createdAt: DateTime.parse(row['created_at']),
        sparks: sparks,
        posts: posts,
        msgs: msgs,
      ));
    }
    return isles;
  }

  static Future<Isle> createIsle(Isle isle, String creatorId) async {
    final row = await _db.from('isles').insert({
      'name': isle.name,
      'main_emoji': isle.emoji,
      'purpose': isle.purpose,
      'color': isle.color,
      'visibility': isle.visibility.name,
      'created_by': creatorId,
    }).select().single();

    final newId = row['id'] as String;

    // Auto-create creator membership
    await _db.from('memberships').insert({
      'isle_id': newId,
      'user_id': creatorId,
      'role': 'creator',
    });

    return isle.copyWith(id: newId, createdBy: creatorId);
  }

  static Future<void> updateIsle(Isle isle) async {
    await _db.from('isles').update({
      'name': isle.name,
      'main_emoji': isle.emoji,
      'purpose': isle.purpose,
      'color': isle.color,
      'visibility': isle.visibility.name,
    }).eq('id', isle.id);
  }

  static Future<void> deleteIsle(String isleId) async {
    await _db.from('isles').delete().eq('id', isleId);
  }

  // ============================================================
  // SPARKS
  // ============================================================

  static Future<List<Spark>> fetchSparks(String isleId) async {
    final rows = await _db.from('sparks').select().eq('isle_id', isleId).order('created_at');
    final sparks = <Spark>[];
    for (final row in rows) {
      final deps = await _fetchDependencies(row['id'] as String);
      sparks.add(_rowToSpark(row, deps));
    }
    return sparks;
  }

  static Future<Spark> createSpark(Spark spark) async {
    final row = await _db.from('sparks').insert({
      'isle_id': spark.isleId,
      'main_emoji': spark.emoji,
      'title': spark.title,
      'mode': spark.mode.name,
      'scope': spark.scope.name,
      'shape': spark.shape.toJson(),
      'state': spark.state.name,
      'streak': spark.streak,
      'timer_mode': spark.timerMode.name,
      'streak_breaks_on_miss': spark.streakBreaksOnMiss,
      'metric': spark.metric?.toJson(),
      'is_main': spark.isMain,
    }).select().single();

    final newId = row['id'] as String;

    // Insert dependencies
    for (final dep in spark.dependencies) {
      await _db.from('dependencies').insert({
        'spark_id': newId,
        'emoji': dep.emoji,
        'label': dep.label,
        'satisfied': dep.satisfied,
      });
    }

    return spark.copyWith(id: newId);
  }

  static Future<void> updateSpark(Spark spark) async {
    await _db.from('sparks').update({
      'main_emoji': spark.emoji,
      'title': spark.title,
      'shape': spark.shape.toJson(),
      'state': spark.state.name,
      'streak': spark.streak,
      'metric': spark.metric?.toJson(),
      'last_completed_at': spark.lastCompletedAt?.toIso8601String(),
      'cycle_due_at': spark.cycleDueAt?.toIso8601String(),
    }).eq('id', spark.id);

    // Update dependency satisfaction states
    for (final dep in spark.dependencies) {
      await _db.from('dependencies').update({
        'satisfied': dep.satisfied,
      }).eq('id', dep.id);
    }
  }

  static Future<void> deleteSpark(String sparkId) async {
    await _db.from('sparks').delete().eq('id', sparkId);
  }

  static Spark _rowToSpark(Map<String, dynamic> row, List<Dependency> deps) {
    return Spark(
      id: row['id'],
      isleId: row['isle_id'],
      emoji: row['main_emoji'] ?? '',
      title: row['title'],
      mode: enumFromString(SparkMode.values, row['mode'] ?? 'ritual'),
      scope: enumFromString(SparkScope.values, row['scope'] ?? 'shared'),
      shape: row['shape'] != null ? SparkShape.fromJson(row['shape']) : SparkShape.rhomboid,
      state: enumFromString(SparkState.values, row['state'] ?? 'dull'),
      streak: row['streak'] ?? 0,
      timerMode: enumFromString(TimerMode.values, row['timer_mode'] ?? 'daily'),
      streakBreaksOnMiss: row['streak_breaks_on_miss'] ?? true,
      dependencies: deps,
      metric: row['metric'] != null ? Metric.fromJson(row['metric']) : null,
      isMain: row['is_main'] ?? false,
      thread: [],
      lastCompletedAt: row['last_completed_at'] != null
          ? DateTime.parse(row['last_completed_at'])
          : null,
      cycleDueAt: row['cycle_due_at'] != null
          ? DateTime.parse(row['cycle_due_at'])
          : null,
      createdAt: DateTime.parse(row['created_at']),
    );
  }

  // ============================================================
  // DEPENDENCIES
  // ============================================================

  static Future<List<Dependency>> _fetchDependencies(String sparkId) async {
    final rows = await _db.from('dependencies').select().eq('spark_id', sparkId);
    return rows.map<Dependency>((r) => Dependency(
      id: r['id'],
      sparkId: r['spark_id'],
      emoji: r['emoji'] ?? '',
      label: r['label'],
      satisfied: r['satisfied'] ?? false,
      createdAt: DateTime.parse(r['created_at']),
    )).toList();
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  static Future<List<Message>> fetchMessages(String chatId) async {
    final rows = await _db.from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
    return rows.map<Message>(_rowToMessage).toList();
  }

  static Future<Message> sendMessage(Message msg) async {
    final row = await _db.from('messages').insert({
      'chat_id': msg.chatId,
      'sender_id': msg.senderId,
      'sender_name': msg.senderName,
      'sender_avatar': msg.senderAvatar,
      'content': msg.content,
      'big': msg.big,
      'content_type': msg.contentType,
      'image_url': msg.imageUrl,
    }).select().single();

    return msg.copyWith(id: row['id'], createdAt: DateTime.parse(row['created_at']));
  }

  static Future<void> updateMessage(Message msg) async {
    await _db.from('messages').update({
      'reactions': msg.reactions.map((r) => {'emoji': r.emoji, 'users': r.users}).toList(),
    }).eq('id', msg.id);
  }

  /// Subscribe to realtime message inserts for a chat room.
  static RealtimeChannel subscribeToMessages(String chatId, void Function(Message) onNew) {
    return _db.channel('chat:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'chat_id', value: chatId),
          callback: (payload) {
            onNew(_rowToMessage(payload.newRecord));
          },
        )
        .subscribe();
  }

  static Message _rowToMessage(Map<String, dynamic> r) {
    final reactionList = (r['reactions'] as List?) ?? [];
    return Message(
      id: r['id'],
      chatId: r['chat_id'],
      senderId: r['sender_id'],
      senderName: r['sender_name'] ?? '',
      senderAvatar: r['sender_avatar'] ?? '🧑',
      content: r['content'],
      big: r['big'],
      contentType: r['content_type'] ?? 'text',
      reactions: reactionList.map<MessageReaction>((re) => MessageReaction(
        emoji: re['emoji'] ?? '',
        users: List<String>.from(re['users'] ?? []),
      )).toList(),
      imageUrl: r['image_url'],
      createdAt: DateTime.parse(r['created_at']),
    );
  }

  // ============================================================
  // POSTS
  // ============================================================

  static Future<List<Post>> fetchPostsForIsle(String isleId) async {
    final rows = await _db.from('posts')
        .select()
        .or('audience.cs.{${isleId}},audience.cs.{all}')
        .order('created_at', ascending: false);
    return rows.map<Post>(_rowToPost).toList();
  }

  static Future<List<Post>> fetchAllPosts() async {
    final rows = await _db.from('posts')
        .select()
        .order('created_at', ascending: false);
    return rows.map<Post>(_rowToPost).toList();
  }

  static Future<Post> createPost(Post post) async {
    final row = await _db.from('posts').insert({
      'author_id': post.authorId,
      'author_name': post.authorName,
      'author_avatar': post.authorAvatar,
      'text': post.text,
      'emoji': post.emoji,
      'image_url': post.imageUrl,
      'audience': post.audience,
    }).select().single();

    return post.copyWith(id: row['id'], createdAt: DateTime.parse(row['created_at']));
  }

  static Post _rowToPost(Map<String, dynamic> r) {
    return Post(
      id: r['id'],
      authorId: r['author_id'],
      authorName: r['author_name'] ?? '',
      authorAvatar: r['author_avatar'] ?? '🧑',
      text: r['text'],
      emoji: r['emoji'],
      imageUrl: r['image_url'],
      audience: List<String>.from(r['audience'] ?? []),
      createdAt: DateTime.parse(r['created_at']),
    );
  }

  // ============================================================
  // MEMBERSHIPS
  // ============================================================

  static Future<Map<String, List<Membership>>> fetchMemberships(List<String> isleIds) async {
    if (isleIds.isEmpty) return {};
    final rows = await _db.from('memberships').select().inFilter('isle_id', isleIds);
    final map = <String, List<Membership>>{};
    for (final raw in rows) {
      final r = raw as Map<String, dynamic>;
      final isleId = r['isle_id'] as String;
      map.putIfAbsent(isleId, () => []);
      map[isleId]!.add(Membership(
        isleId: isleId,
        userId: r['user_id'],
        userName: r['user_name'] ?? '',
        userAvatar: r['user_avatar'] ?? '🧑',
        role: r['role'] ?? 'member',
        joinedAt: DateTime.parse(r['joined_at']),
      ));
    }
    return map;
  }

  static Future<void> addMember(Membership m) async {
    await _db.from('memberships').insert({
      'isle_id': m.isleId,
      'user_id': m.userId,
      'user_name': m.userName,
      'user_avatar': m.userAvatar,
      'role': m.role,
    });
  }

  static Future<void> removeMember(String isleId, String userId) async {
    await _db.from('memberships').delete()
        .eq('isle_id', isleId)
        .eq('user_id', userId);
  }

  // ============================================================
  // FRIENDS
  // ============================================================

  static Future<List<Friend>> fetchFriends(String userId) async {
    final rows = await _db.from('friends').select().eq('user_id', userId);
    return rows.map<Friend>((r) => Friend(
      id: r['id'],
      userId: r['user_id'],
      friendId: r['friend_id'] ?? '',
      friendName: r['friend_name'] ?? '',
      friendAvatar: r['friend_avatar'] ?? '🧑',
      status: r['status'] ?? 'pending_out',
      createdAt: DateTime.parse(r['created_at']),
    )).toList();
  }
}
