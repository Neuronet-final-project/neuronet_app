import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'channel.freezed.dart';
part 'channel.g.dart';

@freezed
abstract class Channel with _$Channel {
  const factory Channel({
    @JsonKey(name: 'channel_id') required String channelId,
    @JsonKey(name: 'name') required String channelName,
    String? description,
    @JsonKey(name: 'is_group') @Default(false) bool isGroup,
    @JsonKey(name: 'is_subscribed') @Default(false) bool isFollowed,
    @JsonKey(name: 'counselor_id') @Default('') String counselorId,
    @JsonKey(name: 'channel_type', unknownEnumValue: ChannelType.educational)
    @Default(ChannelType.educational)
    ChannelType channelType,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'subscriber_count') @Default(0) int subscriberCount,
    @Default(true) bool isActive,
    @Default(true) bool allowComments,
    @Default(true) bool allowReactions,
    @Default(false) bool isFeatured,
  }) = _Channel;

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);
}

@freezed
abstract class ChannelPost with _$ChannelPost {
  const factory ChannelPost({
    required String id,
    @JsonKey(name: 'channel_id') required String channelId,
    @JsonKey(name: 'counselor_id') required String counselorId,
    @JsonKey(name: 'counselor_name') String? counselorName,
    required String title,
    required String content,
    @JsonKey(name: 'post_type') @Default('article') String postType,
    @JsonKey(name: 'is_educational') @Default(false) bool isEducational,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @JsonKey(name: 'allow_comments') @Default(true) bool allowComments,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'reaction_count') @Default(0) int reactionCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'is_reacted') @Default(false) bool isReacted,
  }) = _ChannelPost;

  factory ChannelPost.fromJson(Map<String, dynamic> json) =>
      _$ChannelPostFromJson(json);
}

@freezed
abstract class ChannelInteraction with _$ChannelInteraction {
  const factory ChannelInteraction({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') String? userName,
    @JsonKey(name: 'interaction_type') required String interactionType,
    @JsonKey(name: 'reaction_type') String? reactionType,
    String? content,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_visible') @Default(true) bool isVisible,
  }) = _ChannelInteraction;

  factory ChannelInteraction.fromJson(Map<String, dynamic> json) =>
      _$ChannelInteractionFromJson(json);
}
