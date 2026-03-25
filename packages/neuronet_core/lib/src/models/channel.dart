import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'channel.freezed.dart';
part 'channel.g.dart';

@freezed
abstract class Channel with _$Channel {
  const factory Channel({
    required String channelId,
    required String counselorId,
    required String channelName,
    required String description,
    required ChannelType channelType,
    required DateTime createdAt,
    @Default(true) bool isActive,
    @Default(true) bool allowComments,
    @Default(true) bool allowReactions,
    @Default(false) bool isFeatured,
    @Default(false) bool isFollowed,
    @Default(0) int subscriberCount,
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
