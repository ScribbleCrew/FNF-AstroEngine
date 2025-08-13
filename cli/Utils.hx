package;

class Utils
{
    /**
     * [Description] Returns the build target based on the system name.
     * @return String The build target (e.g., "windows", "macos", "linux").
     */
    public static var buildTarget(get, null):String;
    @:noCompletion static var __buildTarget:String = null;
    @:noCompletion inline static function get__buildTarget():String {
        if (__buildTarget == null) {
            __buildTarget = switch (Sys.systemName().toUpperCase()) {
                case "WINDOWS": "windows";
                case "MAC":     "macos";
                case "LINUX":   "linux";
                default:        Sys.systemName().toLowerCase();
            };
        }
        return __buildTarget;
    }
}
