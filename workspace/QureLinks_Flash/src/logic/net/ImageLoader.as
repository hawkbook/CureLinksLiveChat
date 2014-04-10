package logic.net
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import mx.core.FlexGlobals;

	public class ImageLoader extends Loader
	{
		public var no:int;
		public var img:Bitmap;
		
		public function ImageLoader(no:int, url:String)
		{
			//			Security.loadPolicyFile("http://localhost/crossdomain.xml");
			super();
			this.no = no;
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			this.load(new URLRequest(url));
		}
		
		private function completeHandler(e:Event):void
		{
			img = Bitmap(this.content);
			var cnt:int = ++mx.core.FlexGlobals.topLevelApplication.logic.imageLoadCount;
			if (mx.core.FlexGlobals.topLevelApplication.logic.keepItemListCount <= cnt)
			{
				mx.core.FlexGlobals.topLevelApplication.logic.itemSet();
			}
		}
		
	}
}