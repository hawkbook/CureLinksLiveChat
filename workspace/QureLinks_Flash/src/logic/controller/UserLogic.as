package logic.controller
{
	import components.NgwordMsgDataListSkin;
	import components.chatMsgDataListSkin;
	
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.events.SyncEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.system.SecurityPanel;
	import flash.system.fscommand;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import logic.Logic2;
	import logic.config.ConstValues;
	import logic.config.DefineNetConnection;
	import logic.entity.CustomCamera;
	import logic.entity.CustomMicrophone;
	import logic.net.CustomNetConnection;
	import logic.net.CustomURLLoader;
	import logic.net.ImageLoader;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.controls.ComboBox;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
	import mx.core.DragSource;
	import mx.core.FlexGlobals;
	import mx.core.IFactory;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.DragManager;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.messaging.AbstractConsumer;
	import mx.messaging.messages.ErrorMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.RichEditableText;
	import spark.components.RichText;
	import spark.components.mediaClasses.DynamicStreamingVideoSource;

	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	
	/**
	 * cast.mxmlに対するメインのロジッククラス.
	 * 
	 * <br>view(cast.mxml)の部品イベントのハンドラを自動生成するために 
	 * Logic2クラスを継承する。
	 */
	public class UserLogic extends Logic2
	{
		//--------------------------------------
		// Variables
		//--------------------------------------
		
		/**
		 * チャットメッセージアレイコレクション.
		 * <p>
		 * あらかじめ空白メッセージを用意しておく。
		 * 一つのメッセージは複数の子を持つ Objectとして処理される
		 * <li>obj.msg        ：　メッセージ</li>
		 * <li>obj.msgNo      ：　IDと送信時間 "XXXX:hh:mi:ss"</li>
		 * <li>obj.msgUser    ：　ユーザID</li>
		 * <li>obj.msgUserName：　ユーザ名</li>
		 * <li>obj.msgCheck   ：　チェックボックスのチェック(true/false)</li>
		 * <li>obj.msgColor   ：　メッセージ文字色</li>
		 * </p>
		 */		
		[Bindable]
		public var acChatMsg:ArrayCollection = new ArrayCollection([
			{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
		]);
		
		[Bindable]
		public var msgText:RichEditableText = new RichEditableText();
		
		/**
		 * 追放ユーザー保存用アレイコレクション（未使用）.
		 */
		public var acKickUsers:ArrayCollection = new ArrayCollection();
		
		private var _castId:String;		// キャストログインID
		private var _castName:String;			// キャスト名
		private var _userId:String;			// ユーザID
		private var _userAccessCode:String;	// アクセスコード
		private var _userName:String;			// ユーザ名
		private var _userPoint:int;			// ユーザ名
		private var _nc:CustomNetConnection;		// カスタムネットコネクション
		private var _nc_wait:CustomNetConnection;		// カスタムネットコネクション
		private var _ncFme:CustomNetConnection;	// FME用ネットコネクション
		private var _state:String;				// アプリケーションのステート
		private var _castState:String = "initial";			// キャストの状態
		private var _loader1:CustomURLLoader;			// CGI呼び出し用
		private var _loader2:CustomURLLoader;			// CGI呼び出し用
		private var _loader3:CustomURLLoader;			// Animation呼び出し用
		private var _loader4:CustomURLLoader;			// 呼び出し用
		private var _loader5:CustomURLLoader;			// 呼び出し用
		private var _loader6:CustomURLLoader;			// 呼び出し用
		private var _loader7:CustomURLLoader;			// 呼び出し用
		private var _loader8:CustomURLLoader;			// 呼び出し用
//		private var _dispatcher:EventDispatcher;
		
		private var vid:Video;			// ビデオ
		private var stream:NetStream;
		private var theCamera:Camera;		// カメラ
		private var theMic:Microphone;		// マイク
		private var publish_ns:NetStream;	// 配信ストリーム
		private var _micCurrentGain:int = ConstValues.MIC_GAIN;		
		private var _dragActive:Boolean;
		private var _volumeBounds:Rectangle;
		private var micLevelTimer:Timer;	// マイクレベルメータのタイマー
		private var connectionNgTimer:Timer;	// マイクレベルメータのタイマー
		private var chatTimer:Timer;		// 放送時間のタイマー
		private var _chatStartTime:int = 60*60;
		private var userAliveTimer:Timer;		// ユーザのFMS接続タイマー
		private var checkWaitInTimer:Timer;
//		private var waitInTimer:Timer;
		private var payTimer:Timer;
		private var likeEndTimer:Timer;
		private var rcv_ns:NetStream;		// 受信ストリーム
		private var rcv_video:Video;		// 受信ビデオ
		
		private var _so:SharedObject;		// so
		private var _so4:SharedObject;		// ステータス用SO
		private var _so4Stats:String;		// soステータス
		
		private var _chatDelCounter:int;	// チャット削除カウンタ
		private var _ngwordDelCounter:int;	// NGワード削除カウンタ
		
		private var soundVolume:Number = 0.8;
		
		private var keepCategory:String = "";	// プレゼントカテゴリー
		private var keepItemList:String = "";	// プレゼントリスト
		private var keepItemEtcName:String;	// その他のプレゼント名
		private var keepChatTitle:String;	// チャットタイトル
		private var keepDspPrice:int;		// チャット単価
		private var keepItemPrice:Array = new Array();	// チャットタイトル
		private var keepItemName:Array = new Array();	// チャットタイトル
		private var keepItemNo:Array = new Array();	// チャットタイトル
		private var chatStartTime:int;	// チャットタイトル
		private var chatNo:String;	// チャット番号
		private var chatViewCount:String;	// チャットタイトル
		private var ngWordList:Array = new Array();	// チャットタイトル
		private var fmeFlg:String;	// FMEフラグ
		private var fanclubFlg:String;		// ファンクラブフラグ
		private var giftItemPage:int = 1;
		private var giftItemPrice:Array = new Array();
		private var giftItemName:Array = new Array();
		private var giftItemNo:Array = new Array();
		private var loginType:String = "";
		private var startTimeSecondCount:String;		// タイム秒カウンタ
		private var arAnimeId:Array = new Array();
		private var imgLoader1:Loader;
		private var imgLoader2:Loader;
		private var imgLoader3:Loader;
		private var imgLoader4:Loader;
		private var imgLoader5:Loader;
		private var acGiftView:ArrayCollection = new ArrayCollection();
		private var keep_Otamesi_Count:int;

		private var _isIconBClicked:Boolean = false;
		private var sendText:String = "";

		private var begin_time:String;
		private var begin_time_str:String;
		private var profile:String;
		private var schedule_id:String;
		private var schedulelist:String;
		
		private var report_url:String;
		private var session_id:String;
		
		/**
		 * プレゼントアイテム数.
		 * @default 0
		 */
		public var keepItemListCount:int=0;
		/**
		 * プレゼントイメージ読込み数.
		 * @default なし
		 */
		public var imageLoadCount:int;
//		public var buyGiftNo:int;
		/**
		 * プレゼントアイテム名.
		 * @default なし
		 */
		public var gift_name:String;
		/**
		 * プレゼントアイテム番号.
		 * @default なし
		 */
		public var gift_no:String;
		/**
		 * プレゼントアイテムポイント.
		 * @default なし
		 */
		public var gift_point:int;
		/**
		 * 一度プレゼントを贈ったフラグ.
		 * @default false;
		 */
		public var send_present:Boolean = false;
		
		/**
		 * 追放カウント.
		 * @default なし
		 */
		public var _kickOutCount:int;
		
		private var tel_ns:NetStream = null;
		private var telPrice:int;
		
		private var debug:Boolean = true;			// デバッグ
		
		/**
		 * コンストラクタ.
		 */
		public function UserLogic()
		{
			super();
		}
		
		/**
		 * 画面が生成された後の初期化処理オーバーライド.
		 * 
		 * <p>Logic2スーパークラスの関数オーバーライド。各初期化処理を行う。</p>
		 * <ul>
		 * <li>SWF起動時パラメータのログインIDをキャストIDとしてを読み込む。</li>
		 * <li>画面にキーアップハンドラを追加。</li>
		 * <li>画面の大きさがスケールに従うモードに設定。</li>
		 * <li>クラス内各タイマー初期化。</li>
		 * <li>スピーカーボリューム初期化。</li>
		 * <li>initVars()を呼んで引数からチャット情報を初期化。</li>
		 * <li>ファンクラブ限定での画面初期化。</li>
		 * </ul>
		 * 
		 * @param event FlexEvent
		 */
		override protected function onCreationCompleteHandler(event:FlexEvent):void
		{
			trace("at onCreationCompleteHandler Enter");
			
			_castId = view.parameters.counselor_id;
			_castName = view.parameters.counselor_name;
			begin_time = view.parameters.begin_time;
			begin_time_str = view.parameters.begin_time_str;
			profile = view.parameters.profile;
			schedule_id = view.parameters.schedule_id;
			schedulelist = view.parameters.schedulelist;
			_chatStartTime = view.parameters.session_time;
			_userId = view.parameters.client_id;
			_userName = view.parameters.client_name;
			report_url = view.parameters.report_url;
			session_id = view.parameters.session_id;
			
			if (_castId == null)
			{
				_castId = "1234567890";
			}
			
			view.chatTitle.text = _castName + "\n" + begin_time_str;
			view.profile_disp.text = profile;
			
			view.schedule_disp.text = schedulelist;
			
			trace("_castId=" + _castId);
			
//			view.addEventListener(KeyboardEvent.KEY_UP, appKeyHandler);
			view.chat_msg_box.addEventListener(KeyboardEvent.KEY_DOWN, chat_msg_boxOnKeyDownHandler);
			view.chat_msg_box.addEventListener(KeyboardEvent.KEY_UP, chat_msg_boxOnKeyUpHandler);
			
			if (view.stage != null)
			{
				view.stage.scaleMode = StageScaleMode.SHOW_ALL;
			}
			else
			{
				view.addEventListener(Event.ADDED_TO_STAGE, setScaleMode);
			}
			
			// タイマーの初期化
			chatTimer = new Timer(ConstValues.TIMER_CHAT,0);		// チャットタイマー
			chatTimer.addEventListener(TimerEvent.TIMER, chatTimerHandler);		// タイマーイベントを設定
			
			userAliveTimer = new Timer(ConstValues.TIMER_USER_ALIVE,0);		// ユーザアライブ
			userAliveTimer.addEventListener(TimerEvent.TIMER, userAliveTimerHandler);	// ユーザアライブ
			
			payTimer = new Timer(ConstValues.TIMER_PAY,0);		// 一分課金タイマー
			payTimer.addEventListener(TimerEvent.TIMER, payDspPoint);		// タイマーイベントを設定
			
			micLevelTimer = new Timer(ConstValues.TIMER_MICLEVEL,0);		// マイクレベルタイマー
			micLevelTimer.addEventListener(TimerEvent.TIMER, micActiveBarHandler);		// タイマーイベントを設定
			
			// ボリューム
			_volumeBounds = new Rectangle(view.volume_bar.x -4, view.volume_bar.y - (view.volume_sound.height / 3) , 80,0);
			view.volume_sound.x = soundVolume * 80 + (view.volume_bar.x -4);
			view.volume_bar.width = 80 * soundVolume;
			
			// 引数：チャット情報読み込み
			initVars();		
			
			loginType = "";
			gotoChat();
			
		}
		
		// マイク音量レベル表示
		private function micActiveBarHandler(e:Event):void
		{
			var level:int = theMic.activityLevel;
			//			trace (level);
			view.micActiveLevel.inLevel.micLevel.width = level*240/100 ;
		}
		
		// ブラウザスケールに合わせる
		private function setScaleMode(e:Event = null):void 
		{ 
			// scaleModeをSHOW_ALLに設定する
			view.stage.scaleMode = StageScaleMode.SHOW_ALL;
			// ADDED_TO_STAGEイベントを削除する
			view.removeEventListener(Event.ADDED_TO_STAGE, setScaleMode);
		} 
		
		/**
		 * アプリケーションが生成された後の初期化処理オーバーライド.
		 * <p>何も行わない。</p>
		 * 
		 * @param event FlexEvent
		 */
		override protected function onUpdateCompleteHandler(event:FlexEvent):void
		{
		}
		
		// チャット初期情報取得ハンドラ
		private function initVars():void
		{
			keepCategory = FlexGlobals.topLevelApplication.parameters.category;
			keepItemList = FlexGlobals.topLevelApplication.parameters.item_list;	// ",1,2,3,4,5,6,"
			keepItemEtcName = FlexGlobals.topLevelApplication.parameters.item_name;
			keepChatTitle = FlexGlobals.topLevelApplication.parameters.chat_title;
//			view.chatTitle.text = keepChatTitle;
			keepDspPrice = FlexGlobals.topLevelApplication.parameters.keeplist1000;
			chatStartTime = FlexGlobals.topLevelApplication.parameters.chat_start_time;
			chatNo = FlexGlobals.topLevelApplication.parameters.chat_id;
			chatViewCount = FlexGlobals.topLevelApplication.parameters.chat_view_count;
			if (FlexGlobals.topLevelApplication.parameters.ng_word != null)
			{
				ngWordList = FlexGlobals.topLevelApplication.parameters.ng_word.split(",");
			}
			
			_castName = FlexGlobals.topLevelApplication.parameters.cast_name;
			fmeFlg = FlexGlobals.topLevelApplication.parameters.fme_flg;
//			_cast_id = FlexGlobals.topLevelApplication.parameters.cast_id;
			fanclubFlg = FlexGlobals.topLevelApplication.parameters.fanclub_flg;
			
			if (keepItemList)
			{
				// プレゼント一時除外
				var buf:Array = new Array();
				buf = keepItemList.split(",6");		// 除外
				keepItemList = buf.join("");		// 
				
			}
			if (chatNo)
			{
				if(chatStartTime == 0){
					return;
				}else{
				}
				
				//放送時間セット
				chatStartTime = chatStartTime - 60;
				//				_global.chenge_id1 = setInterval(chatStartTime,1000);
				_chatStartTime = chatStartTime;
//				chatTimer.start();
			}
			
		}
		
		/**
		 * Initalステート Enter イベントハンドラ.
		 * <p>cast.mxml 画面の InitialステートにEnterイベントが発生した時のハンドラ</p>
		 * <ul>
		 * <li>配信開始ボタンの可視化</li>
		 * <li>配信終了ボタンの不可視化</li>
		 * <li>チャット削除ボタンのディセーブル</li>
		 * <li>チャット書き込みボタンのディセーブル</li>
		 * <li>禁止ワード削除ボタンのディセーブル</li>
		 * <li>禁止ワード書き込みボタンのディセーブル</li>
		 * <li>追放ボタンのディセーブル</li>
		 * <li>Likeボタンのディセーブル</li>
		 * <li>アンケート質問ボタンのディセーブル</li>
		 * <li>ボリュームONボタンのディセーブル</li>
		 * <li>ボリュームOFFボタンのイネーブル</li>
		 * </ul>
		 **/
		public function InitialOnEnterStateHandler(event:Event):void
		{
			trace("at Initial State Enter");
			
//			initVars();		// 引数：チャット情報読み込み

			// enable
			view.chat_msg_box.enabled = false;
			view.chat_send_btn.enabled = false;
			view.volume_icon_btn.enabled = false;
			view.volume_sound.enabled = false;
			
			view.mic_off_btn.enabled = false;
			view.mic_on_btn.enabled = true;
			
			// Timer リセット
			if (connectionNgTimer != null)
			{
				connectionNgTimer.reset();	// コネクションNGタイマー
			}
			
			if (chatTimer != null)
			{
				chatTimer.reset();			// チャットタイマー
			}
			
			if (theCamera)
			{
				theCamera = null;
			}
			if (theMic)
			{
				theMic.removeEventListener(ActivityEvent.ACTIVITY, setActivityTimer);
				theMic = null;
			}
		}
		
		/**
		 * Chatting ステート Enter イベントハンドラ.
		 * <p>cast.mxml 画面の ChattingステートにEnterイベントが発生した時のハンドラ</p>
		 * <ul>
		 * <li>配信開始ボタンの不可視化</li>
		 * <li>配信終了ボタンの可視化</li>
		 * <li>チャット削除ボタンのディセーブル</li>
		 * <li>チャット書き込みボタンのディセーブル</li>
		 * <li>禁止ワード削除ボタンのディセーブル</li>
		 * <li>禁止ワード書き込みボタンのディセーブル</li>
		 * <li>追放ボタンのディセーブル</li>
		 * <li>Likeボタンのディセーブル</li>
		 * <li>アンケート質問ボタンのディセーブル</li>
		 * <li>ボリュームONボタンのディセーブル</li>
		 * <li>ボリュームOFFボタンのイネーブル</li>
		 * </ul>
		 */
		public function ChattingOnEnterStateHandler(event:Event):void
		{
			trace("at Chatting State Enter");
			
			view.chat_msg_box.enabled = true;
			view.chat_send_btn.enabled = true;
			view.volume_icon_btn.enabled = true;
			view.volume_sound.enabled = true;

			cameraOff();
			micOff();
			
//			chatTimer.start();		// チャットタイマーを動かす
		}
		
		/**
		 * ChatEnd ステート Enter イベントハンドラ.
		 * 
		 * <p>cast.mxml 画面の ChatEnd移行時のイベントハンドラ</p>
		 * <ul>
		 * <li>FMSとのNetConnectionを閉じる。</li>
		 * <li>終了画面を表示する。</li>
		 * </ul>
		 * 
		 * @param event
		 */
		public function ChatEndOnEnterStateHandler(event:Event):void
		{
			trace("at ChatEnd State Enter");
			if (_nc)
			{
				_nc.close();
			}
			if (_ncFme != null)
			{
				_ncFme.close();
			}
			// enable
			view.chat_msg_box.enabled = false;
			view.chat_send_btn.enabled = false;
			view.volume_icon_btn.enabled = false;
			view.volume_sound.enabled = false;

			cameraOff();
			micOff();
			
			// 終了表示
			view.logoutMenu2.visible = true;
			
		}

		private function gotoChat():void
		{
			getLogin();	// チャット開始
		}
		
		/**
		 * お部屋へ行くボタンクリックハンドラ.
		 * <p>現在のログインタイプをクリアし、チャット開始処理を行う。</p>
		 * @param event 使用しない
		 */
		public function new_login_menu_btn1OnClickHandler(event:Event):void
		{
			loginType = "";
			gotoChat();
		}
		
		/**
		 * お試しボタンクリックハンドラ.
		 * <p>現在のログインタイプを"OTAMESI"にし、チャット開始処理を行う。</p>
		 * @param event 使用しない
		 */
		public function new_login_menu_btn2OnClickHandler(event:Event):void
		{
			loginType = "OTAMESI";
			gotoChat();
		}
		
		/**
		 * お部屋へ行く処理.
		 * 
		 * <p>現在のログインタイプをクリアし、チャット開始処理を行う。</p>
		 * @param event 使用しない
		 */
		public function gotoRoom():void
		{
			loginType = "";
			gotoChat();
		}
		
		// ページビューカウントアップハンドラ
		private function pageViewHandler(event:Event):void
		{
			// 何もしていない
		}

		/**
		 * 配信終了ボタンクリックハンドラ.
		 * 
		 * <p>配信終了メニューを表示する</p>
		 * 
		 * @param event 未使用
		 */
		public function logoutBtnOnClickHandler(event:Event):void
		{
			_so.send("sendMsg", "CHAT_ENDING", "", "");
//			view.logout_menu.visible = true;
		}
		
		/**
		 * チャット書き込みボタンクリックハンドラ.
		 * 
		 * <ul>
		 * <li>チャット入力文字列を取得する</li>
		 * <li>文字列があれば、SharedObjectにてメッセージを送信する</li>
		 * <li>チャット入力文字列をクリアする</li>
		 * </ul>
		 * 
		 * @param event
		 */
		public function chat_send_btnOnClickHandler(event:Event):void
		{
			sendText = view.chat_msg_box.text;
			send(sendText);
		}
		
		private function send(send_str:String):void
		{
			var _date:Date = new Date();
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "M/DD JJ:NN:SS";
			var tmpDate:String = formatter.format(_date);
			
			var str:String = send_str.replace(/\n/g,"");
			str = str.replace(/\r/g,"");
			
			if (str.length > 0)
			{
				sendText = sendText.replace(/\n/g,"<br>");
				if (_isIconBClicked)
				{
					sendText = "<b>" + sendText + "</b>";
				}
//				sendText = sendText + "<br/><br/>"
				_so.send("sendMsg", "USER_MSG", sendText, "USER:" + tmpDate, _userId, _userName);
				
				view.chat_msg_box.text="";
				sendText = "";
				//				view.chat_msg_box.callLater(clear_chat_msg_box);
			}
		}
		
		private function clear_chat_msg_box():void
		{
			view.chat_msg_box.text="";
		}
		
		private var downKey:Number;
		
		public function chat_msg_boxOnKeyDownHandler(event:Event):void
		{
			var keyEvent:KeyboardEvent = event as KeyboardEvent;
			downKey = keyEvent.keyCode;
		}
		
		/**
		 * チャット入力ボックス内でエンターキ.
		 * 
		 * <p>chat_send_btnOnClickHandler()を呼んでチャット書き込み処理を行う。</p>
		 * 
		 * @param event
		 */
		public function chat_msg_boxOnKeyUpHandler(event:Event):void
		{
			var keyEvent:KeyboardEvent = event as KeyboardEvent;
			sendText = view.chat_msg_box.text;
			if (keyEvent.keyCode == 13)
			{
				if (keyEvent.keyCode != downKey)
				{
					return;
				}
				if (view.enter_chat_in.selected)
				{
					var str:String = sendText.replace(/\n/g,"");
					str = str.replace(/\r/g,"");
					
					if (str.length > 0)
					{
						send(sendText);
					}
					else
					{
						view.chat_msg_box.text="";
						sendText = "";
					}
				}
			}
		}
		
		public function chat_msg_boxOnChangeHandler(event:Event):void
		{
//			sendText = view.chat_msg_box.text;
		}
		
		/**
		 * カメラＯＮボタンクリックハンドラ.
		 * 
		 * @param event
		 */
		public function camera_on_btnOnClickHandler(event:Event):void
		{
			cameraOff();
		}
		
		/**
		 * カメラＯＦＦボタンクリックハンドラ.
		 * 
		 * マイクのゲインを０に設定し、サイレンスレベルを１００に設定する。
		 * @param event
		 */
		public function camera_off_btnOnClickHandler(event:Event):void
		{
			cameraOn();
		}
		
		/**
		 * 音量OFF.
		 * 
		 * <p>スピーカーボリュームをOFFにする</p>
		 * 
		 */
		public function soundOff():void
		{
			rcv_ns.soundTransform = new SoundTransform(0);
			view.volume_icon_btn.currentState = "off";
		}
		
		/**
		 * 音量ON.
		 * 
		 * <p>スピーカーボリュームをONにする</p>
		 * 
		 */
		public function soundOn():void
		{
			rcv_ns.soundTransform = new SoundTransform(soundVolume);
			view.volume_icon_btn.currentState = "on";
		}
		
		/**
		 * マイク音量OFF.
		 * 
		 * <p>スピーカーボリュームをOFFにする</p>
		 * 
		 */
		public function micOn():void
		{
			if (theMic != null)
			{
				view.mic_on_btn.enabled = true;
				view.mic_on_btn.visible = true;
				view.mic_off_btn.enabled = false;
				view.mic_off_btn.visible = false;
				view.mic_icon_btn.currentState = 'on';
				theMic.setSilenceLevel(ConstValues.MIC_SILENCELEVEL);	// サイレンスレベル
				theMic.gain = _micCurrentGain;
			}
		}
		
		/**
		 * 音量ON.
		 * 
		 * <p>スピーカーボリュームをONにする</p>
		 * 
		 */
		public function micOff():void
		{
			if (theMic != null)
			{
				view.mic_on_btn.enabled = false;
				view.mic_on_btn.visible = false;
				view.mic_off_btn.enabled = true;
				view.mic_off_btn.visible = true;
				view.mic_icon_btn.currentState = 'off';
				theMic.setSilenceLevel(100);		// ミュート
				theMic.gain = 0;
			}
		}
		
		/**
		 * カメラOFF.
		 * 
		 * <p>カメラをOFFにする</p>
		 * 
		 */
		public function cameraOff():void
		{
			if (theCamera != null)
			{
				view.camera_on_btn.enabled = false;
				view.camera_on_btn.visible = false;
				view.camera_off_btn.enabled = true;
				view.camera_off_btn.visible = true;
				view.camera_icon_btn.currentState = 'off';
				publish_ns.attachCamera(null);
				
				view.receive_video_self.visible = false;
				
				var _date:Date = new Date();
				var formatter:DateFormatter = new DateFormatter();
				formatter.formatString = "M/DD JJ:NN:SS";
				var tmpDate:String = formatter.format(_date);
				_so.send("sendMsg", "USER_CAMERA_OFF", "", "USER:" + tmpDate, _userId, _userName);
			}
		}
		
		/**
		 * カメラON.
		 * 
		 * <p>カメラをONにする</p>
		 * 
		 */
		public function cameraOn():void
		{
			if (theCamera != null)
			{
				view.camera_on_btn.enabled = true;
				view.camera_on_btn.visible = true;
				view.camera_off_btn.enabled = false;
				view.camera_off_btn.visible = false;
				view.camera_icon_btn.currentState = 'on';
				publish_ns.attachCamera(theCamera);
				
				view.receive_video_self.visible = true;
				
				var _date:Date = new Date();
				var formatter:DateFormatter = new DateFormatter();
				formatter.formatString = "M/DD JJ:NN:SS";
				var tmpDate:String = formatter.format(_date);
				_so.send("sendMsg", "USER_CAMERA_ON", "", "USER:" + tmpDate, _userId, _userName);
			}
		}
		
		/**
		 * ボリュームＯＮボタンクリックハンドラ.
		 * 
		 * <p>soundOn()を呼んでボリュームをONにする</p>
		 * 
		 * @param event 未使用
		 */
		public function mic_on_btnOnClickHandler(event:Event):void
		{
			micOff();
		}
		
		/**
		 * ボリュームＯＦＦボタンクリックハンドラ.
		 * 
		 * <p>soundOff()を呼んでボリュームをOFFにする</p>
		 * 
		 * @param event 未使用
		 */
		public function mic_off_btnOnClickHandler(event:Event):void
		{
			micOn();
		}
		
		/**
		 * マイクボリュームドラッグ開始.
		 * 
		 * <p>ドラッグ開始処理を行う</p>
		 * 
		 * @param event 未使用
		 */
		public function volume_soundOnMouseDownHandler(event:MouseEvent):void
		{
			_dragActive = true;
			view.volume_sound.startDrag(false,_volumeBounds);
		}
		
		/**
		 * マイクボリュームマウスアップハンドラ.
		 * 
		 * <p>ドラッグ終了処理を行う</p>
		 * 
		 * @param event 未使用
		 */
		public function volume_soundOnMouseUpHandler(event:MouseEvent):void
		{
			_dragActive = false;
			view.volume_sound.stopDrag();
		}
		
		/**
		 * マイクボリュームマウスドラッグアウトハンドラ.
		 * 
		 * <p>ドラッグ終了処理を行う</p>
		 * 
		 * @param event 未使用
		 */
		public function volume_soundOnMouseOutHandler(event:MouseEvent):void
		{
			_dragActive = false;
			view.volume_sound.stopDrag();
		}
		
		/**
		 * マイクボリュームドラッグ中ハンドラ.
		 * 
		 * <p>ドラッグ中ボリューム設定処理を行う</p>
		 * 
		 * @param event 未使用
		 */
		public function volume_soundOnMouseMoveHandler(event:MouseEvent):void 
		{
			if (_dragActive)
			{
				//videoClip.audioVol(425,505,this._x);
//				_micCurrentGain = 80 + view.volume_sound.x - 505;
				soundVolume = (view.volume_sound.x - view.volume_bar.x + 4) / 80;
				view.volume_bar.width = 80 * soundVolume;
				
				if (view.volume_icon_btn.currentState == "on")
				{
					rcv_ns.soundTransform = new SoundTransform(soundVolume);
				}
				
			}
		}
		
		/**
		 * チャットを開始する.
		 * <p>
		 * <li>カメラを取得する</li>
		 * <li>マイクを取得する</li>
		 * <li>マイクレベル取得用タイマーを作成しスタートする</li>
		 * <li>FMSにコネクションを張る</li>
		 * <li>チャット用データプロバイダを設定する</li>
		 * <li>禁止ワード用データプロバイダを設定する</li>
		 * </p>
		 */
		public function getLogin():void
		{
			// カメラとマイクの準備
			theCamera = logic.entity.CustomCamera.getCamera();			// カメラ
			theMic = logic.entity.CustomMicrophone.getMicrophone();		// マイク
			
			if ((theMic == null) || (theCamera == null))
			{
				return;
			}
			theMic.addEventListener(ActivityEvent.ACTIVITY, setActivityTimer);
			
			// マイクボリューム初期化
			var vol:int = view.volume_sound.x - _volumeBounds.x
			_micCurrentGain = ConstValues.MIC_GAIN * (vol/_volumeBounds.width);
			view.volume_bar.width = vol;
			
			theMic.gain = _micCurrentGain;
			
			var rtmp:String = "rtmp://" + DefineNetConnection.url_fms + "/cast/" + schedule_id;
			var rtmpFme:String = "rtmp://" + DefineNetConnection.url_fms + "/castLive/" + _castId;
			
			// 配信終了時は繋げない
			if (view.logoutMenu2.visible == true)
			{
				return;
			}
			
			// コネクションを張る
			_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler, _castId, "USER", _userName, null, _userId);
	
			view.chat_send_btn.visible = true;
			
		}
		
		private function setActivityTimer(event:Event):void
		{
			micLevelTimer.start();
//			theMic.gain = _micCurrentGain;
		}
		
		/**
		 * 通常コネクションステータスハンドラ.
		 * 
		 * @param e NetStatusEvent
		 */
		public function netConnectionStatusHandler(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Rejected":
//					trace(e.info.application.message);
					if (e.info.application.message == "MAXUSER")
					{
//						view.wait_menu_1.visible = true;
					}
					else if (e.info.application.message == "MAXUSER_100")
					{
						if (loginType == "OTAMESI")
						{
//							view.wait_menu_10.visible = true;
						}
						else
						{
//							view.wait_menu_9.visible = true;
						}
					}
					else if (e.info.application.message == "OTAMESI_ERR")
					{
//						view.login_menu2.visible = true;
					}
					
					_nc.close();
					if (_ncFme != null)
					{
						_ncFme.close();
					}
//					view.currentState = "Initial";
					break;
				case "NetConnection.Connect.Success":
					// 予約処理
					
					// ステータス用 SharedObject
					_so4 = _nc.getSo("statsTxt"+_castId, so4SyncEventHandler);		// チャットSO
					// 動画スタート
					connectStream();
					// 課金処理開始
					keep_Otamesi_Count = 0;
					// 開始された
					view.currentState = "Chatting";
					break;
				case "NetStream.Play.StreamNotFound":
					//					trace("Stream not found: " + videoURL);
					break;
			}
		}
		
		private function payDspPoint(e:Event):void
		{
			
			if(loginType == "OTAMESI")
			{
//				view.login_menu.otameshi_mask.visible = true;
				
				keep_Otamesi_Count++;
				if(keep_Otamesi_Count > 1)
				{
					view.currentState = "ChatEnd";
				}
			}
			else
			{
//				view.login_menu.otameshi_mask.visible = false;
				_nc.call("UserPayPoint",null,_userId,_userAccessCode,"1000");		// 課金
			}
		}
		
		// コネクト
		private function connectStream():void
		{
			// テキスト用 SharedObject
			_so = _nc.getSo("ourText"+_castId, soSyncEventHandler);	// チャットSO
			_nc.setSendMsgHandler(sendMsgHanler);		// SO 送信ハンドラ
			
			publishVideo();		// Videoパブリッシュ
			receiveVideo(_nc);				// 相手Video受信
			receiveVideo_self();		// 自分Video受信

		}
		
		// ビデオパブリッシュ
		private function publishVideo():void
		{
			publish_ns = new NetStream(_nc);
			publish_ns.addEventListener(NetStatusEvent.NET_STATUS, publishNetStatusEventHandler);
			publish_ns.attachCamera(theCamera);
			publish_ns.attachAudio(theMic);
			publish_ns.publish("client"+_userId,  "record");
			theMic.gain = ConstValues.MIC_GAIN;
		}
		
		/**
		 * パブリッシュビデオのステータスハンドラ.
		 * @param e
		 */
		public function publishNetStatusEventHandler(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					break;
				case "NetStream.Play.StreamNotFound":
					//					trace("Stream not found: " + videoURL);
					break;
			}
		}
		
		// ビデオ受信
		private function receiveVideo(nc:CustomNetConnection):void
		{
			rcv_ns = new NetStream(nc);
			rcv_ns.addEventListener(NetStatusEvent.NET_STATUS, receiveNetStreamStatusEventHandler);
			rcv_ns.client = this;
			rcv_ns.bufferTime = 0.1;
			rcv_ns.play("cast"+_castId);
			rcv_video = new Video();
			rcv_video.width = ConstValues.CAMERA_WIDTH;
			rcv_video.height = ConstValues.CAMERA_HEIGHT;
			rcv_video.attachNetStream(rcv_ns);
			view.receive_video.addChild(rcv_video as DisplayObject);
			
		}
		
		private var rcv_ns_self:NetStream;		// 受信ストリーム
		private var rcv_video_self:Video;		// 受信ビデオ
		
		// ビデオ受信
		private function receiveVideo_self():void
		{
			rcv_video_self = new Video();
			rcv_video_self.width = view.receive_video_self.width;
			rcv_video_self.height = view.receive_video_self.height;
			rcv_video_self.attachCamera(theCamera);
			view.receive_video_self.addChild(rcv_video_self as DisplayObject);
		}
		
		/**
		 * 受信ストリームステータスハンドラ.
		 * @param e
		 */
		public function receiveNetStreamStatusEventHandler(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetStream.Play.StreamNotFound":
					//					trace("Stream not found: " + videoURL);
					break;
			}
		}
		
		/**
		 * コネクトセキュリティエラーハンドラ.
		 * @param event
		 */
		public function _securityErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
		}
		
		// チャットステータス用 FMS-SO (statsTxt)ハンドラ
		private function so4SyncEventHandler(event:SyncEvent):void
		{
			trace("SyncEvent." + event.type);
			_so4Stats = _so4.data.msg;
			trace("so4.data.msg = " + _so4Stats);
			if (_so4Stats == "undefined") 
			{
				_so4Stats = "0";
				_so4.data.msg = "0";
			}
			
//			_so4.removeEventListener(SyncEvent.SYNC , so4SyncEventHandler);
			
		}
		
		// チャット用 FMS-SO (ourText)ハンドラ
		private function soSyncEventHandler(event:SyncEvent):void
		{
			trace("SyncEvent." + event.type);
			if (event.type == "sync")
			{
				var msg:String;
				var chatId:String;
				var _date:Date = new Date();
				var formatter:DateFormatter = new DateFormatter();
				formatter.formatString = "M/DD JJ:NN:SS";
				var tmpDate:String = formatter.format(_date);
				
				chatId = "SYSTEM" + tmpDate;
				msg = "<b>" + _userName + "</b>さんが入室されました。";
				_so.send("sendMsg", "USER_LOGIN", msg, chatId,"SYSTEM" );
				
			}
		}
		
		private function userAliveTimerHandler(e:Event):void
		{
			_nc.call("TimerResetCount",null);		// オフライン
		}
		
		public function startSessionTimerCount(count:Number):void
		{
			_chatStartTime -= count;
			chatTimer.start();		// チャットタイマーを動かす
		}
		
		public function stopSessionTimerCount():void
		{
			chatTimer.stop();		// チャットタイマー停止
		}
		
		private function chatTimerHandler(e:Event):void
		{
			var chatTimeHH:int;
			var chatTimeMI:int;
			var chatTimeSS:int;
			var hh:String;
			var mi:String;
			var ss:String;
			
			_chatStartTime--;
			
			if(_chatStartTime >= 0)
			{
				chatTimeHH = _chatStartTime / 3600;
				chatTimeMI = (_chatStartTime % 3600) / 60;
				chatTimeSS = _chatStartTime % 60;
				
				if(chatTimeHH < 10)
				{
					hh = "0" + chatTimeHH.toString();
				}
				else
				{
					hh = chatTimeHH.toString();
				}
				if(chatTimeMI < 10)
				{
					mi = "0" + chatTimeMI.toString();
				}
				else
				{
					mi = chatTimeMI.toString();
				}
				if(chatTimeSS < 10)
				{
					ss = "0" + chatTimeSS.toString();
				}
				else
				{
					ss = chatTimeSS.toString();
				}
				
				view.chatTime.text = hh + ":" + mi + ":" + ss;
			}
			else
			{
				view.chatTime.text = _chatStartTime.toString();
			}
		}
		
		private var totalTime:Number;
		/**
		 * 
		 * @param param
		 */
		public function onMetaData(param:Object):void 
		{
			totalTime = param.duration;
		}

		// デバッグ
		private function debugOut1(msg:String):void
		{
			if (debug)
			{
				var color:Number = 0x008800;
				// デバッグ
				setChatMsg(msg, "", _userId, "デバッグ", color);
			}
		}

		// 
		/**
		 * SharedObject メッセージハンドラ.
		 * 
		 * <p>メッセージ送信時に使用する。
		 * また受信時はSharedObjectのChange イベントにより呼ばれる。</p>
		 * 
		 * @param JobType メッセージタイプ
		 * @param msg メッセージの内容
		 * @param ChatId チャットID
		 * @param UserId ユーザーID
		 * @param UserName ユーザー名
		 * @param ExUserIds 拡張ユーザーID
		 */
		public function sendMsgHanler(JobType:String, msg:String, ChatId:String="1", UserId:String="1", UserName:String="A", ExUserIds:String=""):void
		{
//			var chatSkin:chatMsgDataListSkin_user = view.chat_msg.skin as chatMsgDataListSkin_user;
//			var chatSkin:chatMsgDataListSkin = view.chat_msg.skin as chatMsgDataListSkin;
			var color:Number;
			var work:Array;
			var i:int;
			var detected:Boolean = false;
			var datetime:String;

//			debugOut1(JobType + ":" + UserId + ":" + UserName + ":" + ExUserIds);		// デバッグ
			
			switch (JobType)
			{
				case "CHAT_ENDING":
					view.logout_menu.visible = true;
					return;
				case "TUHO_ENDING":
					if(UserId.indexOf("CAST") < 0)
					{
						view.logout_menu2.visible = true;
					}
					return;
				case "TUHO_END":
					view.currentState = "ChatEnd";
					view.logoutMenu2.visible = true;
					return;
				case "USER_CAMERA_OFF":
				case "USER_CAMERA_ON":
					return;
				case "CAST_CAMERA_OFF":
					view.receive_video.visible = false;
					return;
				case "CAST_CAMERA_ON":
					view.receive_video.visible = true;
					return;
				case "USER_LOGIN":
				case "CAST_LOGIN":
				case "USER_MSG":
				case "CAST_MSG":
				default:
					if(UserId.indexOf("CAST") >= 0)
					{
						color = 0x005000;
					}
					else
					{
						color = 0x000000;
					}
					
					var addMsg:String = "";
					if (ChatId.indexOf("SYSTEM") >=0)
					{
						addMsg = ChatId.replace(/SYSTEM/g, "<font color = \"#ff3d68\"><b>システム</b></font>:  <font color = \"#999999\">");
						addMsg += "</font><br>";
					}
					else if ((ChatId.indexOf("CAST") == -1) && (UserId == _userId))
					{
						datetime = ChatId.replace(/USER:/, "");
						addMsg = "<font color = \"#ff6600\"><b>" + UserName + "</b></font><font color = \"#4b4039\">の発言</font>:  <font color = \"#999999\">" + datetime + "</font><br>";
					}
					else
					{
						datetime = ChatId.replace(/CAST:/, "");
						addMsg = "<font color = \"#5789BB\"><b>" + UserName + "</b></font><font color = \"#4b4039\">の発言</font>:  <font color = \"#999999\">" + datetime + "</font><br>";
					}
					
					break;
			}
			
			if (msg != "")
			{
//				msg = replaceNgword(msg);
				msg = addMsg + "<font color = \"#524740\">　" + msg + "</font>";
				setChatMsg(msg, ChatId, UserId, UserName, color);
			}
		
		}
		
		private function setChatMsg(msg:String, chatId:String, userId:String, userName:String, color:Number):void
		{
			var html_text:String = view.chat_disp.htmlText;
			view.chat_disp.htmlText = html_text + msg;
			
			view.chat_disp.callLater(chatScroll);
		}
		
		// チャットスクロール
		private function chatScroll():void
		{
			view.chat_disp.verticalScrollPosition = view.chat_disp.maxVerticalScrollPosition;
		}
		
		/**
		 * キャストログアウトハンドラ.
		 * 
		 * <p>画面ステートをChatEndにして終了メッセージを表示する。</p>
		 */
		public function castLogout():void
		{
			view.currentState = "ChatEnd";
			view.logoutMenu2.visible = true;
		}
		
		/**
		 * 太文字ボタンクリックハンドラ.
		 * 
		 * <p>メッセージを太文字にする</p>
		 */
		public function bold_btnOnClickHandler(e:Event):void
		{
			view.bold_btn.visible = false;
			view.bold_btn_on.visible = true;
			_isIconBClicked = true;
		}
		
		/**
		 * 太文字ONボタンクリックハンドラ.
		 * 
		 * <p>メッセージを通常文字にする</p>
		 */
		public function bold_btn_onOnClickHandler(e:Event):void
		{
			view.bold_btn.visible = true;
			view.bold_btn_on.visible = false;
			_isIconBClicked = false;
		}
		
		/**
		 * 絵文字ボタンクリックハンドラ.
		 * 
		 * <p>絵文字ウインドウを開く</p>
		 */
		public function emoji_btnOnClickHandler(e:Event):void
		{
			view.emoji_btn.visible = false;
			view.emoji_btn_on.visible = true;
		}
		
		/**
		 * 絵文字ONボタンクリックハンドラ.
		 * 
		 * <p>メッセージを通常文字にする</p>
		 */
		public function emoji_btn_onOnClickHandler(e:Event):void
		{
			view.emoji_btn.visible = true;
			view.emoji_btn_on.visible = false;
		}
		
		/**
		 * 顔文字ボタンクリックハンドラ.
		 * 
		 * <p>顔文字ウインドウを開く</p>
		 */
		public function kao_btnOnClickHandler(e:Event):void
		{
			view.kao_btn.visible = false;
			view.kao_btn_on.visible = true;
			
			view.panel_kao.visible = true;
		}
		
		/**
		 * 顔文字ONボタンクリックハンドラ.
		 * 
		 * <p>メッセージを通常文字にする</p>
		 */
		public function kao_btn_onOnClickHandler(e:Event):void
		{
			view.kao_btn.visible = true;
			view.kao_btn_on.visible = false;
			
			view.panel_kao.visible = false;
		}
		
		/**
		 * 顔文字クリック
		 * 
		 * あらかじめ読込んでいたプレゼント情報をプレゼントページ数に従って５つづつ表示する。
		 * 
		 */
		public function onClickKao(moji:String):void
		{
			view.chat_msg_box.text += moji;
		}
		
		/**
		 * スケジュールONボタンクリックハンドラ.
		 * 
		 * <p></p>
		 */
		public function schedule_btn_onOnClickHandler(e:Event):void
		{
		}
		
		/**
		 * スケジュールOFFボタンクリックハンドラ.
		 * 
		 * <p></p>
		 */
		public function schedule_btn_offOnClickHandler(e:Event):void
		{
			view.schedule_btn_on.visible = true;
			view.schedule_btn_on.enabled = false;
			view.schedule_btn_off.visible = false;
			view.profile_btn_on.visible = false;
			view.profile_btn_off.visible = true;
			
			view.schedule_disp.visible = true;
			view.profile_disp.visible = false;
		}
		
		/**
		 * プロフィールONボタンクリックハンドラ.
		 * 
		 * <p></p>
		 */
		public function profile_btn_onOnClickHandler(e:Event):void
		{
		}
		
		/**
		 * プロフィールOFFボタンクリックハンドラ.
		 * 
		 * <p></p>
		 */
		public function profile_btn_offOnClickHandler(e:Event):void
		{
			view.schedule_btn_on.visible = false;
			view.schedule_btn_off.visible = true;
			view.profile_btn_on.visible = true;
			view.profile_btn_on.enabled = false;
			view.profile_btn_off.visible = false;
			
			view.schedule_disp.visible = false;
			view.profile_disp.visible = true;
		}
		
		/**
		 * 通報するボタンクリックハンドラ.
		 * 
		 * <p></p>
		 */
		public function tuho_btnOnClickHandler(e:Event):void
		{
			_so.send("sendMsg", "TUHO_ENDING", "", "", "");
			//			view.logout_menu2.visible = true;
		}
		
		public function tuhoEnd():void
		{
			_so.send("sendMsg", "TUHO_END", "", "", "");
			//			view.logout_menu2.visible = true;
		}
		
		public function reportForm():void
		{
			view.report_form.start_time.text = begin_time_str;
			view.report_form.client_name.text = _userName;
			view.report_form.counselor_name.text = _castName;
			view.report_form.reporting_name.text = _userName;
			
			view.report_form.visible = true;
		}
		
		public function report(txt:String):void
		{
			// キャスト初期情報取得
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(report_url);
			request.contentType = ""; 
			request.method	= URLRequestMethod.POST;
			var variables:URLVariables = new URLVariables();
			
			variables.archive_path_cast = "/applications/cast/streams/" + schedule_id + "/cast" + _castId + ".flv";
			variables.archive_path_user = "/applications/cast/streams/" + schedule_id + "/user" + _userId + ".flv";
			variables.session_type = "通報あり中断"　;
			variables.datetime = begin_time_str　;
			variables.session_id　= session_id　;
			variables.counselor_id　= _castId　;
			variables.client_id　= _userId　;
			variables.notifier　= _userId　;
			variables.report = txt　;
			variables.chat_log = view.chat_disp.text　;
			
			var lc:LoaderContext = new LoaderContext();
			lc.checkPolicyFile = true;
			
			try 
			{
				loader.load(request);	// CGI呼び出し
				//				this.load(request,lc);	// CGI呼び出し
			}
			catch (error:ArgumentError)
			{
				trace("An Argument Error: " + error);
				view.errorMessageBox.errorMess.text = "通報接続エラーが発生しました。";
				view.errorMessageBox.visible = true;
				//				Alert.show("接続エラーが発生しました。 ERR:1052", "接続エラー");
			}
			catch (error:SecurityError)
			{
				trace("An Security Error: " + error);
				view.errorMessageBox.errorMess.text = "通報接続セキュリティエラーが発生しました。";
				view.errorMessageBox.visible = true;
				//				Alert.show("接続エラーが発生しました。 ERR:1052", "接続エラー");
			}
			
		}
		
		//--------------------------------------
		// View-Logic Binding
		//--------------------------------------
		
		/** 画面 */
		public var _view:user;
		
		/**
		 * 画面を取得します
		 */
		public function get view():user
		{
			if (_view == null)
			{
				_view = super.document as user;
			}
			return _view;
		}
		
		/**
		 * 画面をセットします。
		 *
		 * @param view セットする画面
		 */
		public function set view(view:user):void
		{
			_view = view;
		}
		
	}
}