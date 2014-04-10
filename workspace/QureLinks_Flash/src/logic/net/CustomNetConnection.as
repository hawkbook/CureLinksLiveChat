package logic.net
{
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.net.SharedObject;
	
	import logic.config.ConstValues;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	
	public class CustomNetConnection extends NetConnection
	{
		private var sendMsgHandler:Function;		// sendMsg ハンドラ
		
		public function CustomNetConnection(rtmp:String, netStatusHandler:Function=null, param1:String=null, param2:String=null, param3:String=null, param4:String=null, param5:String=null)
		{
			super();
			
			if (netStatusHandler == null)
			{
				netStatusHandler = _netStatusEventHandler;
			}
//			this.objectEncoding = ObjectEncoding.AMF3;		// AMF3はActionScript3.0以上のみ
			this.objectEncoding = ObjectEncoding.AMF0;		// 事務所側がActionScript2.0のままなのでAMF0とする
			
			this.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler);

			this.connect(rtmp, param1, param2, param3, param4, param5);
			
		}
		
		private function _securityErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
		}
		
		private function _netStatusEventHandler(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
//					trace("Stream not found: " + videoURL);
					break;
			}
		}
		
		private function connectStream():void 
		{
		}
		
		// チャット用 FMS-SO取得
		public function getSo(soName:String,handler:Function ):SharedObject
		{
			var so:SharedObject;
//			so = SharedObject.getRemote(soName, this.uri, true);
			so = SharedObject.getRemote(soName, this.uri);
			so.addEventListener(SyncEvent.SYNC , handler);
			so.connect(this);
			so.client = this;
			return so;
		}
		
		public function setSendMsgHandler(handler:Function):void
		{
			sendMsgHandler = handler;
		}
		
		// Shared Object Change Handler
		public function sendMsg(JobType:String, msg:String, ChatId:String="", UserId:String="", UserName:String="" , ExUserIds:String=""):void
		{
			sendMsgHandler(JobType, msg, ChatId, UserId, UserName, ExUserIds);
		}
		
		// 視聴者数取得
		public function RtnUserCount(dat1:Number):void 
		{
//			mx.core.FlexGlobals.topLevelApplication.loginInfo1.text  = dat1.toString();	
		}
		
		// 待ち人数取得
		public function RtnWaitUserCount(dat1:Number):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.rtnWaitUserCount(dat1);	
		}
		
		// 再ログイン
		public function RtnWaitUserIn(dat1:Number):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.rtnWaitUserIn(dat1);	
		}
		
		// 再ログイン
		public function WaitReLogin():void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.waitReLogin();	
		}
		
		
		public function onBWCheck(dummy:Object):void
		{
			trace("onBWCheck");
		}
		
		public function onBWDone(bandwidth:Number, not_use:Number, not_use2:Number, wait_time:Number):void
		{
			trace("bandwidth = " + bandwidth);
		}
		
		// キャストログアウト（ユーザ時はクローズする）
		public function CastLogout(dat1:Number):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.castLogout();
		}
		
		public function NG():void
		{
			mx.core.FlexGlobals.topLevelApplication.errorMessageBox.errorMess.text = "既に入室しています。";
			mx.core.FlexGlobals.topLevelApplication.errorMessageBox.visible = true;
			this.close();
		}
		
		public function CastHelthCheck():String
		{
			return ("OK");
		}
		
		public function payHandler(data:String):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.checkPoint(data);
		}
		
		public function telPayHandler(data:String):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.checkTelPoint(data);
		}
		
//		public function MicCount(data:Number):void
//		{
//			mx.core.FlexGlobals.topLevelApplication.logic.setMicCount(data);
//		}
		
//		public function loginUserInfo(id:String, name:String, micNum:Number=null):void
		public function loginUserInfo(id:String, name:String):void
		{
//			Alert.show("id:"+id + ", name:"+name+", micNum:"+micNum);
			mx.core.FlexGlobals.topLevelApplication.logic.loginUserInfo(id,name);
		}
		
		public function logoutUserInfo(id:String, name:String):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.logoutUserInfo(id,name);
		}
		
		public function startSessionTimer(count:Number):void 
		{
			mx.core.FlexGlobals.topLevelApplication.logic.startSessionTimerCount(count);
		}
		
		public function userSessionTimerStop():void 
		{
			mx.core.FlexGlobals.topLevelApplication.logic.stopSessionTimerCount();
		}
		
	}
}