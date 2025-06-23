/// Data wrapper class for handling backend requests.
class ScheduleJob {
  int delay;
  int duration;

  ScheduleJob(this.delay, this.duration);

  Map<String, dynamic> toJson() => {'delay': delay, 'duration': duration};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleJob &&
          other.delay == delay &&
          other.duration == duration);

  @override
  int get hashCode => Object.hash(delay, duration);
}
