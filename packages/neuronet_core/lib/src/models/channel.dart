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
    required String postId,
    required String channelId,
    required String counselorId,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isPinned,
    @Default(true) bool allowComments,
    @Default(0) int viewCount,
    @Default(0) int reactionCount,
    @Default(false) bool isReacted,
  }) = _ChannelPost;

  factory ChannelPost.fromJson(Map<String, dynamic> json) =>
      _$ChannelPostFromJson(json);
}

@freezed
abstract class ChannelInteraction with _$ChannelInteraction {
  const factory ChannelInteraction({
    required String interactionId,
    required String postId,
    required String adolescentId,
    required InteractionType interactionType,
    String? content,
    required DateTime createdAt,
    @Default(true) bool isVisible,
  }) = _ChannelInteraction;

  factory ChannelInteraction.fromJson(Map<String, dynamic> json) =>
      _$ChannelInteractionFromJson(json);
}
