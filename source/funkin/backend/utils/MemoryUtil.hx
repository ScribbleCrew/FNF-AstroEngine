package funkin.backend.utils;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.system.System;

using StringTools;

class MemoryUtil
{
	public static function getTotalMem():Float
	{
		#if windows
		return funkin.backend.utils.native.WindowUtil.getTotalRam();
		#elseif mac
		return funkin.backend.utils.native.Mac.getTotalRam();
		#elseif linux
		return funkin.backend.utils.native.Linux.getTotalRam();
		#else
		return 0;
		#end
	}

	public static inline function currentMemUsage()
	{
		#if cpp
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#elseif hl
		return Gc.stats().currentMemory;
		#elseif sys
		return cast(cast(System.totalMemory, UInt), Float);
		#else
		return 0;
		#end
	}
}
