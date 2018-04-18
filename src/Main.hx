package;


import haxe.ds.ArraySort;
import haxe.ds.Vector;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.Assets;
import pxling.PixelFn;

import openfl.system.System;
import hxPixels.Pixels;
import pxling.PixelTools;


class Main extends Sprite {
	
	public function new () {
		
		super ();
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
    var bmd = Assets.getBitmapData("assets/lena.png");
		
		var bitmap = new Bitmap(bmd);
		bitmap.x = 1;
		bitmap.y = 1;
		addChild(bitmap);
    
    var outBmd = bmd.clone();
    var pixels:Pixels = outBmd;
    var outBitmap = new Bitmap(outBmd);
    outBitmap.x = bitmap.x + bmd.width + 1;
    outBitmap.y = bitmap.y;
    addChild(outBitmap);
    
    var t0 = haxe.Timer.stamp();
    
    function icmp(a:Int, b:Int) {
      return b - a;
    }
    
    inline function greyValue(x:Pixel) {
      return Std.int((x.R + x.G + x.B) / 3);
    }
    
    function greyCmp(a:Int, b:Int) {
      var greyA = greyValue(a);
      var greyB = greyValue(b);
      return greyA - greyB;
    }
    
    inline function createKernelRect(w:Int, h:Int):_Rect {
      var dx = w >> 1;
      var dy = h >> 1;
      return {x: -dx, y: -dy, w:w, h:h};
    }
    
    // process

    var dRect:_Rect = createKernelRect(5, 5);
    var k = dRect.w * dRect.h;
    var mid = (dRect.w * dRect.h) >> 1;
    var window = []; window[k - 1] = 0;
    var rectIter = new RectIterator(dRect);
    var a, r, g, b;
    for (i in PixelTools.enumerate(pixels)) {
      a = r = g = b = .0;
      rectIter.reset();
      for (d in rectIter) {
        var px = getBoundedPixel32(pixels, i.x + d.x, i.y + d.y);
        window[d.idx] = px;
        a += px.A;
        r += px.R;
        g += px.G;
        b += px.B;
      }
      //var idx = ArrayArgSort.argsort(window, icmp);
      var idx = ArrayArgSort.argsort(window, greyCmp);
      a = (a / k);
      r = (r / k);
      g = (g / k);
      b = (b / k);
      //i.pixel = Pixel.create(Std.int(a), Std.int(r), Std.int(g), Std.int(b));
      i.pixel = window[idx[mid]];
    }
    
    // apply
    pixels.applyToBitmapData(outBmd);
    
    trace("ELAPSED: " + (haxe.Timer.stamp() - t0) + "s");
	}
	
  inline static function clamp<T:Float>(v:T, min:T, max:T):T {
    return v <= min ? min : v >= max ? max : v;
  }
  
  inline static function iclamp<T:Int>(v:T, min:T, max:T):T {
    return v <= min ? min : v >= max ? max : v;
  }
  
  inline static function getBoundedPixel32(pixels:Pixels, x:Int, y:Int) {
    x = iclamp(x, 0, pixels.width - 1);
    y = iclamp(y, 0, pixels.height - 1);
    return pixels.getPixel32(x, y);
  }
  
  public function onKeyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == 27) {
      quit();
		}
	}
  
  static public function quit()
  {
    #if (flash || html5)
			System.exit(1);
		#else
			Sys.exit(1);
		#end
  }
}