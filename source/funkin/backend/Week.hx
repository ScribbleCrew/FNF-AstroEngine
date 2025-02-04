package funkin.backend;
class Week {
    public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

    inline public static function isWeekLocked(name:String):Bool
        {
            final curWeek:WeekData = WeekData.weeksLoaded.get(name);
            return (!curWeek.startUnlocked && curWeek.weekBefore.length > 0 && (!weekCompleted.exists(curWeek.weekBefore) || !weekCompleted.get(curWeek.weekBefore)));
        }
}