import 'dart:convert';

import 'package:citgroupvn_ecommerce_delivery/data/model/response/conversation_model.dart';

class MessageModel {
  int? totalSize;
  int? limit;
  int? offset;
  bool? status;
  Conversation? conversation;
  List<Message>? messages;

  MessageModel({this.totalSize, this.limit, this.offset, this.messages,  this.status});

  MessageModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    status = json['status'] ?? false;
    conversation = json['conversation'] != null ? Conversation.fromJson(json['conversation']) : null;
    if (json['messages'] != null) {
      messages = <Message>[];
      json['messages'].forEach((v) {
        messages!.add(Message.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['status'] = status;
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Message {
  int? id;
  int? conversationId;
  int? senderId;
  String? message;
  List<String>? files;
  int? isSeen;
  String? createdAt;
  String? updatedAt;

  Message({
    this.id,
    this.conversationId,
    this.senderId,
    this.message,
    this.files,
    this.isSeen,
    this.createdAt,
    this.updatedAt,
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    message = json['message'];
    if(json['file'] != null && json['file'] != 'null'){
      files = jsonDecode(json['file']).cast<String>();
    }
    isSeen = json['is_seen'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['message'] = message;
    data['file'] = files;
    data['is_seen'] = isSeen;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;

    return data;
  }
}