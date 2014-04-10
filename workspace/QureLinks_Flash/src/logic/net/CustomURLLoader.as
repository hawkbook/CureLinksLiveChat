package logic.net
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	public class CustomURLLoader extends URLLoader
//	public class CustomURLLoader extends Loader
	{
		private var request:URLRequest;
		private var variables:URLVariables;
		
		public function CustomURLLoader()
		{
//			Security.loadPolicyFile("http://localhost/crossdomain.xml");
			super();
//			super();
		}
		
		public function customLoad(postMethod:Boolean, url:String, dat1:String=null, handler:Function=null, type:String=null, castId:String=null, fme:String=null, dat2:String=null):Boolean
		{
			request = new URLRequest(url);
			//			request.contentType = "text/plain"; 
			request.contentType = ""; 
/*			if (dat1 != null)
			{
				request.data	= "dat1=" + dat1;		// 送るデータ
			}
*/			
			
			if (postMethod)
			{
				variables = new URLVariables();
				request.method	= URLRequestMethod.POST;
				if (dat1 != null)
				{
					variables.dat1 = dat1;
				}
				if (dat2 != null)
				{
					variables.dat2 = dat2;
				}
				if (type != null)
				{
					variables.type = type;
				}
				if (castId != null)
				{
					variables.CAST_ID = castId;
				}
				if (fme != null)
				{
					variables.FME = fme;
				}
				request.data = variables;
			}
			else
			{
				request.method	= URLRequestMethod.GET;
			}
			
			var lc:LoaderContext = new LoaderContext();
			lc.checkPolicyFile = true;

			
			if (handler == null)
			{
				handler = this.loadHandler;		// ハンドラ
			}
			
			this.addEventListener(Event.COMPLETE, handler);
			
			try 
			{
				this.load(request);	// CGI呼び出し
//				this.load(request,lc);	// CGI呼び出し
			}
			catch (error:ArgumentError)
			{
				trace("An Argument Error: " + error);
				return false;
			}
			catch (error:SecurityError)
			{
				trace("An Security Error: " + error);
				return false;
			}
			return true;
		}
		
		private function loadHandler(event:Event):void
		{
		}
	}
}