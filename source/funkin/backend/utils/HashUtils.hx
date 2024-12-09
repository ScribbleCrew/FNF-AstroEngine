package funkin.backend.utils;

import haxe.crypto.*;

enum HashType
{
	// fr
	MD5;
	// sha idk?/?
	SHA1;
	SHA224;
	SHA256;
	// lua idfk
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
			case SHA224:
				return Sha224.encode(txt);
			case SHA256:
				return Sha256.encode(txt);
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
			case 'sha224':
				thingy = SHA1;
			case 'sha256':
				thingy = SHA1;
			default:
				thingy = NONE;
		};

		return thingy;
	}
}
