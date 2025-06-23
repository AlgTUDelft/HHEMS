/// Data wrapper class for handling backend requests.
class Job {
  int startTime;
  int endTime;

  Job(this.startTime, this.endTime);

  Job.fromJson(Map<String, dynamic> json)
    : startTime = json['startTime'] as int,
      endTime = json['endTime'] as int;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.startTime == startTime &&
          other.endTime == endTime);

  @override
  int get hashCode => Object.hash(startTime, endTime);
}
