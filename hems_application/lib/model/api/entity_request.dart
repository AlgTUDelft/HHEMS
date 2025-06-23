/// Data wrapper class for handling backend requests.
class EntityRequest {
  String entityId = '';
  String consumption = '';

  EntityRequest(this.entityId, this.consumption);

  EntityRequest.fromJson(Map<String, dynamic> json) {
    entityId = json['entity_id'] as String;
    consumption = json['consumption'] as String;
  }

  @override
  int get hashCode => Object.hash(entityId, consumption);

  @override
  bool operator ==(Object other) {
    return other is EntityRequest &&
        other.entityId == entityId &&
        other.consumption == consumption;
  }
}
