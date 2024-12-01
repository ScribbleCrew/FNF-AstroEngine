package source;

#if !display
import sys.io.File;

final class Prebuild
{
  private inline static final title:String = "
    ▄▀█ █▀ ▀█▀ █▀█ █▀█   █▀▀ █▄░█ █▀▀ █ █▄░█ █▀▀
    █▀█ ▄█ ░█░ █▀▄ █▄█   ██▄ █░▀█ █▄█ █ █░▀█ ██▄
  ";

  private inline static final subtitle:String = "
          █▀▀ █▀█ █▀▄▀█ █▀█ █ █░░ █▀▀ █▀█
          █▄▄ █▄█ █░▀░█ █▀▀ █ █▄▄ ██▄ █▀▄
  ";
  private inline static final lines:String = "
    --------------------------------------------
  ";

  private inline static final owoquote:String = "
            erm, what the sigma? :3c
  ";

  private inline static final binded:String = '$lines$title$subtitle$owoquote$lines';

  static function main():Void
  {
    //trace('Building!');
    trace(binded);
  }
}
#end