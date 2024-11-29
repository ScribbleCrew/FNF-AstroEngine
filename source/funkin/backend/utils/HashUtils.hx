package funkin.backend.utils;

import haxe.crypto.Sha1;
import haxe.crypto.Md5;

enum HashType
{
	MD5;
	SHA1;
	NONE;
}

class HashUtils
{
    
	public static function hash(txt:String, type:HashType = MD5)
        {
            switch (type)
            {
                case MD5:
                    return Md5.encode(txt);
                case SHA1:
                    return Sha1.encode(txt);
                default:
                    throw "Unsupported hash type: " + type;
            }
        }
        
	public static inline function convertHashType(hashTxt:String):HashType
	{
		var thingy:HashType = null;
		switch (hashTxt.toLowerCase())
		{
			case 'md5':
				thingy = MD5;
			case 'sha1':
				thingy = SHA1;
			default:
				thingy = NONE;
		};

		return thingy;
	}
}
