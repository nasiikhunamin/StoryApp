import 'package:json_annotation/json_annotation.dart';

part 'server_response.g.dart';

@JsonSerializable()
class ServerResponse {
  bool? error;
  String? message;

  ServerResponse({this.error, this.message});

  factory ServerResponse.fromJson(Map<String, dynamic> json) =>
      _$ServerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ServerResponseToJson(this);
}
