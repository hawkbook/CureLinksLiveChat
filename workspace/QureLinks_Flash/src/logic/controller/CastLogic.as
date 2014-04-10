package logic.controller
{
	import components.NgwordMsgDataListSkin;
	import components.chatMsgDataListSkin;
	
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
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
	import flash.system.IME;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.system.fscommand;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import flashx.textLayout.compose.*;
	import flashx.textLayout.elements.*;
	
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
	import mx.events.CollectionEvent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.DragManager;
	import mx.managers.SystemManager;
	import mx.messaging.AbstractConsumer;
	import mx.messaging.messages.ErrorMessage;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.CheckBox;
	import spark.components.Image;
	import spark.components.mediaClasses.DynamicStreamingVideoSource;

	import flash.net.URLVariables;
	import flash.system.LoaderContext;

	/**
	 * cast.mxmlに対するメインのロジッククラス.
	 * 
	 * <br>view(cast.mxml)の部品イベントのハンドラを自動生成するために 
	 * 	Logic2クラスを継承する。
	 */
	public class CastLogic extends Logic2
	{
		//--------------------------------------
		// Variables
		//--------------------------------------
		
		private var _userId:String;		// クライアントID
		private var _castId:String;			// キャストID
		private var _castName:String;			// キャスト名
		private var client_name:String;			// キャスト名
		private var _nc:CustomNetConnection;		// 通常カスタムネットコネクション
		private var _ncFme:CustomNetConnection;	// FME用カスタムネットコネクション
		private var _state:String;				// アプリケーションのステート
		private var _castState:String = "initial";			// キャストの状態
		private var _loader1:CustomURLLoader;			// CGI呼び出し用
		private var _loader2:CustomURLLoader;			// CGI呼び出し用
		private var _loader3:CustomURLLoader;			// CGI呼び出し用
		private var _loader4:CustomURLLoader;			// CGI呼び出し用
		private var _dispatcher:EventDispatcher;
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
		private var isAliveTimer:Timer;	// FMSへの通知タイマー
		private var waitSlotTimer:Timer;	// スロット待ちタイマー
		private var waitSelectedTimer:Timer;	// 当選待ちタイマー
		private var waitCallingTimer:Timer;	// 呼び出し待ちタイマー
		private var waitSpeakStartTimer:Timer;	// 会話開始待ちタイマー
		private var sendEntryStartTimer:Timer;	// Entry_START 繰り返しタイマー
		
		private var _totalAnswer01:int;	// 集計値１
		private var _totalAnswer02:int;	// 集計値２
		private var _totalAnswer03:int;	// 集計値３
		private var _totalAnswer04:int;	// 集計値４
		private var _keepQuest01:String;	// 選択肢１
		private var _keepQuest02:String;	// 選択肢２
		private var _keepQuest03:String;	// 選択肢３
		private var _keepQuest04:String;	// 選択肢４
		
		private var _so:SharedObject;		// so
		private var _so4:SharedObject;		// ステータス用SO
		private var _so4Stats:String;		// soステータス
		
		private var _chatDelCounter:int;	// チャット削除カウンタ
		private var _ngwordDelCounter:int;	// NGワード削除カウンタ
		private var keepChatTitle:String;	// チャットタイトル
		
		private var arAnimeId:Array = new Array();
		
		private var fme:Boolean = true;
		
		private var acMicUser:ArrayCollection = new ArrayCollection();			// マイクユーザ
		private var acSelected:ArrayCollection = new ArrayCollection();		// 当選済みユーザ
		private var acEntryFree:ArrayCollection = new ArrayCollection();		// エントリー（無料）ユーザ
		private var acEntryPay:ArrayCollection = new ArrayCollection();		// エントリー（有料）ユーザ
		
		private var acSelect_Free:ArrayCollection;		// 抽選無料
		private var acSelect_Pay:ArrayCollection;		// 抽選有料
		
		private var userMicCount:int;
		private var selectMode:String;
		private var tel_ns:NetStream;
		private var telUserId:String;
		private var telUserName:String;
		
		private var debug:Boolean = false;			// デバッグ
		private var sendText:String = "";
		private var _isIconBClicked:Boolean = false;

		private var acEmoji:ArrayCollection = new ArrayCollection();
		private var keepItemPrice:Array = new Array();	// チャットタイトル
		private var keepItemName:Array = new Array();	// チャットタイトル
		private var keepItemNo:Array = new Array();	// チャットタイトル
		public var keepItemListCount:int=0;
		public var imageLoadCount:int;
		
		private var begin_time:String;
		private var begin_time_str:String;
		private var profile:String;
		private var schedule_id:String;
		private var schedulelist:String;
		
		private var soundVolume:Number = 0.8;
		private var report_url:String;
		private var session_id:String;
		
		/**
		 * コンストラクタ.
		 */
		public function CastLogic()
		{
			super();
		}
		
		/**
		 * 画面が生成された後の初期化処理オーバーライド.
		 * 
		 * <p>Logic2スーパークラスの関数をオーバーライドし、以下の処理を行う。
		 * <li>SWF起動時パラメータのログインIDをキャストIDとしてを読み込む。</li>
		 * <li>SWF起動時パラメータのチャットタイトルを読み込んで表示する</li>
		 * <li>MXMLを可視化する</li>
		 * <li>タイマーを初期化する</li>
		 * </p>
		 * @param event FlexEvent
		 */
		override protected function onCreationCompleteHandler(event:FlexEvent):void
		{
			_castId = view.parameters.counselor_id;
			_castName = view.parameters.counselor_name;
			begin_time = view.parameters.begin_time;
			begin_time_str = view.parameters.begin_time_str;
			profile = view.parameters.profile;
			schedule_id = view.parameters.schedule_id;
			schedulelist = view.parameters.schedulelist;
			_chatStartTime = view.parameters.session_time;
			_userId = view.parameters.client_id;
			client_name = view.parameters.client_name;
			report_url = view.parameters.report_url;
			session_id = view.parameters.session_id;
			
			if (_castId == null)
			{
				// デバッグ
				_castId = "1234567890";
			}
			
			view.chatTitle.text = _castName + "\n" + begin_time_str;
			view.profile_disp.text = profile;
			
			view.schedule_disp.text = schedulelist;
			
			view.chat_msg_box.addEventListener(KeyboardEvent.KEY_DOWN, chat_msg_boxOnKeyDownHandler);
			view.chat_msg_box.addEventListener(KeyboardEvent.KEY_UP, chat_msg_boxOnKeyUpHandler);
			
			// ボリューム
			_volumeBounds = new Rectangle(view.volume_bar.x -4, view.volume_bar.y - (view.volume_sound.height / 3) , 80,0);
			view.volume_sound.x = soundVolume * 80 + (view.volume_bar.x -4);
			view.volume_bar.width = 80 * soundVolume;
			
			if (view.stage != null)
			{
				view.stage.scaleMode = StageScaleMode.SHOW_ALL;
			}
			else
			{
				view.addEventListener(Event.ADDED_TO_STAGE, setScaleMode);
			}
			
			// タイマーの初期化
			micLevelTimer = new Timer(ConstValues.TIMER_MICLEVEL,0);		// マイクレベルタイマー
			micLevelTimer.addEventListener(TimerEvent.TIMER, micActiveBarHandler);		// タイマーイベントを設定

			chatTimer = new Timer(ConstValues.TIMER_CHAT,0);		// チャットタイマー
			chatTimer.addEventListener(TimerEvent.TIMER, chatTimerHandler);		// タイマーイベントを設定
			
			startChatConnection();
			
		}
		
		// アイテムを追加
/*		private function addEmoji():void
		{
			view.emoji_items.visible = false;

			var img:Image = new spark.components.Image();
			img.id = "e087";
			img.visible=true;
			view.emoji_items.addChild(img);
			
			var item:Object;
			keepItemListCount++;
			item = new Object;
			item.string = "&087:";
			item.loader = new ImageLoader(0, "http://localhost/syo/test2/assets/picface/pic/item/087.gif");
			acEmoji.addItem(item);
			
		}
*/		
		
		/**
		 * ブラウザスケールに合わせる.
		 * 
		 * @param e
		 */
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
		
		/**
		 * Initalステート Enter イベントハンドラ.
		 * <p>
		 * cast.mxml 画面の InitialステートにEnterイベントが発生した時のハンドラ
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
		 * <li>タイマーリセット</li>
		 * <li>ネットコネクションの初期化</li>
		 * <li>カメラとマイクの初期化</li>
		 * </ul>
		 * </p>
		 **/
		public function InitialOnEnterStateHandler(event:Event):void
		{
			trace("at Initial State Enter");
			// visible
//			view.loginBtn.visible = false;
			view.logoutBtn.visible = false;
			// enable
			view.chat_send_btn.enabled = false;
			view.mic_off_btn.enabled = false;
			view.mic_on_btn.enabled = true;
			
			// Timer リセット
			if (connectionNgTimer != null)
			{
				connectionNgTimer.reset();	// コネクションNGタイマー
			}
			if (micLevelTimer != null)
			{
				micLevelTimer.reset();		// マイクレベルタイマー
			}
			if (chatTimer != null)
			{
				chatTimer.reset();			// チャットタイマー
			}
			
			if (publish_ns)
			{
				publish_ns.close();
				publish_ns = null;
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
			
			view.chat_msg_box.text = "";
			
//			addEmoji();
			
		}
		
		// Chattingステート開始
		/**
		 * Chatting ステート Enter イベントハンドラ.
		 * <p>
		 * cast.mxml 画面の ChattingステートにEnterイベントが発生した時のハンドラ
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
		 * </p>
		 */
		public function ChattingOnEnterStateHandler(event:Event):void
		{
			trace("at Chatting State Enter");
			// visible
			view.logoutBtn.visible = true;
			
			view.chat_send_btn.enabled = true;
			view.mic_on_btn.enabled = true;
			view.mic_on_btn.visible = true;
			view.mic_off_btn.enabled = false;
			view.mic_off_btn.visible = false;
			
			view.chat_msg_box.text = "";

			view.volume_sound.visible = true;
			view.volume_bar.visible = true;
			
			// call javascript
			var result:uint = ExternalInterface.call("session_start");
			
		}
		
		/**
		 * ChatEnd ステータス Enterハンドラ.
		 * <p>チャットの終了処理。
		 * ボタン類をディセーブルにする。
		 * </p>
		 * 
		 * @param event
		 */
		public function ChatEndOnEnterStateHandler(event:Event):void
		{
			trace("at ChatEnd State Enter");
			_nc.close();
			if (_ncFme != null)
			{
				_ncFme.close();
			}
			// enable
			view.chat_send_btn.enabled = false;
			cameraOff();
			micOff();
			
			// 終了表示
			view.logoutMenu2.visible = true;
			
			// call javascript
			var result:uint = ExternalInterface.call("session_end");
		}
		
		/**
		 * 通常配信テストボタンクリックハンドラ.
		 * <ul>
		 * <li>fmeフラグをfalseにする</li>
		 * <li>スタータスをTestingにする</li>
		 * <li>キャスト情報を初期化にする</li>
		 * </ul>
		 * @param event
		 */
		public function testNormalBtnOnClickHandler(event:Event):void
		{
			//ql
			_castName = "森田";

			startChatConnection();
		}
		
		/**
		 * 通常配信テストボタンクリックハンドラ.
		 * <ul>
		 * <li>fmeフラグをfalseにする</li>
		 * <li>スタータスをTestingにする</li>
		 * <li>キャスト情報を初期化にする</li>
		 * </ul>
		 * @param event
		 */
		public function startChatConnection():void
		{
			fme = false;		// FMEモードOFF
			chatStart();	//ql チャット開始 castDataHandler()から移動
			
			// ql
			mx.core.FlexGlobals.topLevelApplication.currentState='Chatting';
			castChatStart();	// loginBtn
		}
		
		
		/**
		 * 高画質テスト配信ストップボタンクリックハンドラ.
		 * <ul>
		 * <li>ネットコネクションをcloseする</li>
		 * <li>高画質ネットコネクションをcloseする</li>
		 * <li>スタータスをInitialにする</li>
		 * </ul>
		 * @param event
		 */
		public function testFineStopBtnOnClickHandler(event:Event):void
		{
			_nc.close();
			_ncFme.close();
			mx.core.FlexGlobals.topLevelApplication.currentState='Initial';
		}
		
		/**
		 * 通常テスト配信ストップボタンクリックハンドラ.
		 * <ul>
		 * <li>ネットコネクションをcloseする</li>
		 * <li>スタータスをInitialにする</li>
		 * </ul>
		 * @param event
		 */
		public function testNormalStopBtnOnClickHandler(event:Event):void
		{
			if (_nc){
				_nc.close();
			}
			mx.core.FlexGlobals.topLevelApplication.currentState='Initial';
		}
		
		/**
		 * 配信終了ボタンクリックハンドラ.
		 * 
		 * 配信終了メニューを可視化する。
		 * @param event
		 */
		public function logoutBtnOnClickHandler(event:Event):void
		{
			_so.send("sendMsg", "CHAT_ENDING", "", "");
		}
		
		/**
		 * 絵文字クリック
		 * 
		 * あらかじめ読込んでいたプレゼント情報をプレゼントページ数に従って５つづつ表示する。
		 * 
		 */
		public function onClickImage(id:String):void
		{
			view.chat_msg_box.text += '&' + id + ':';
			
//			doInsertInlineImg();
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
		 * チャット書き込みボタンクリックハンドラ.
		 * 
		 * <ul>
		 * <li>チャット入力ボックスのメッセージ文字列を取得する</li>
		 * <li>メッセージが空でなかったら、ShareObjectでメッセージを送信する</li>
		 * <li>チャットボックスをクリアする</li>
		 * </ul>
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
				_so.send("sendMsg", "CAST_MSG", sendText, "CAST:"+tmpDate, _castId, _castName);
				
				view.chat_msg_box.text="";
				sendText = "";
				//				view.chat_msg_box.callLater(clear_chat_msg_box);
			}
		}
		
		private var downKey:Number;
		
		public function chat_msg_boxOnKeyDownHandler(event:Event):void
		{
			var keyEvent:KeyboardEvent = event as KeyboardEvent;
			downKey = keyEvent.keyCode;
		}
		
		/**
		 * チャット入力ボックス内Enterキーハンドラ.
		 * 
		 * chat_send_btnOnClickHandler()を呼び出すのみ。
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
		 * ボリュームＯＮボタンクリックハンドラ.
		 * 
		 * マイクにゲインを設定し、サイレンスレベルを設定する。
		 * @param event
		 */
		public function mic_on_btnOnClickHandler(event:Event):void
		{
			micOff();
		}
		
		/**
		 * ボリュームＯＦＦボタンクリックハンドラ.
		 * 
		 * マイクのゲインを０に設定し、サイレンスレベルを１００に設定する。
		 * @param event
		 */
		public function mic_off_btnOnClickHandler(event:Event):void
		{
			micOn();
		}
		
		/**
		 * マイクボリュームマウスダウンハンドラ.
		 * 
		 * マイクボリュームのドラッグ開始処理。
		 * @param event
		 */
		public function volume_soundOnMouseDownHandler(event:MouseEvent):void
		{
			_dragActive = true;
			view.volume_sound.startDrag(false,_volumeBounds);
		}
		
		/**
		 * マイクボリュームマウスアップハンドラ.
		 * マイクボリュームドラッグ終了処理。
		 * @param event
		 */
		public function volume_soundOnMouseUpHandler(event:MouseEvent):void
		{
			_dragActive = false;
			view.volume_sound.stopDrag();
		}
		
		/**
		 * マイクボリュームマウスアウトハンドラ.
		 * 
		 * マイクボリュームドラッグ終了。
		 * @param event
		 */
		public function volume_soundOnMouseOutHandler(event:MouseEvent):void
		{
			_dragActive = false;
			view.volume_sound.stopDrag();
		}
		
		/**
		 * マイクボリュームマウスムーブハンドラ.
		 * 
		 * マイクボリュームドラッグ処理。
		 * 
		 * @param event
		 */
		public function volume_soundOnMouseMoveHandler(event:MouseEvent):void 
		{
			if (_dragActive)
			{
				soundVolume = (view.volume_sound.x - view.volume_bar.x + 4) / 80;
				view.volume_bar.width = 80 * soundVolume;
				
				if (view.volume_icon_btn.currentState == "on")
				{
					rcv_ns.soundTransform = new SoundTransform(soundVolume);
				}
				
			}
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
		 * マイクON.
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
		 * マイクOFF.
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
				_so.send("sendMsg", "CAST_CAMERA_OFF", "", "CAST:" + tmpDate, _castId, _castName);

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
				_so.send("sendMsg", "CAST_CAMERA_ON", "", "CAST:" + tmpDate, _castId, _castName);
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
		public function chatStart():void
		{
			var rtmp:String;
			
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
			
			// コネクションを張る
			rtmp = "rtmp://" + DefineNetConnection.url_fms + "/cast/" + schedule_id;
			_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler_Normal, _castId, "CAST");
			
			view.chat_send_btn.visible = true;
		}
		
		private function setActivityTimer(event:Event):void
		{
			micLevelTimer.start();
		}
		
		// マイク音量レベル表示
		private function micActiveBarHandler(e:Event):void
		{
			var level:int = theMic.activityLevel;
//			trace (level);
			view.micActiveLevel.inLevel.micLevel.width = level*240/100 ;
		}
		
		public function startSessionTimerCount(count:Number):void
		{
			_chatStartTime -= count;
			chatTimer.start();		// チャットタイマーを動かす
		}
		
		// チャットタイマーハンドラ
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
		
		/**
		 * NetConnection コネクトステータスハンドラ（通常時）.
		 * 
		 * <p>コネクト成功時の処理を行う。</p>
		 * <ul>
		 * <li>ビデオをパブリッシュする</li>
		 * <li>ビデオを受信開始する</li>
		 * <li>SharedObjectを取得する。</li>
		 * <li>コネクションNGタイマーを起動する</li>
		 * <li>配信者アライブタイマーを起動する</li>
		 * </ul>
		 * 
		 * @param e NetStatusEvent
		 */
		public function netConnectionStatusHandler_Normal(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					_so4 = SharedObject.getRemote("statsTxt"+_castId, _nc.uri);
					publishVideo();		// Videoパブリッシュ
					receiveVideo();				// 相手Video受信
					receiveVideo_self();		// 自分Video受信
					_chatstats();
					_so = _nc.getSo("ourText"+_castId, soSyncEventHandler);		// チャットSO
					_nc.setSendMsgHandler(sendMsgHanler);		// SO 送信ハンドラ
					if (connectionNgTimer != null)
					{
						connectionNgTimer.start();				//Timerを動かす
					}
					
					break;
				case "NetStream.Play.StreamNotFound":
					//					trace("Stream not found: " + videoURL);
					break;
			}
		}
		
		/**
		 * NetConnection チャットコネクトステータスハンドラ（高品質配信時）.
		 * 
		 * <p>コネクト成功時の処理を行う。</p>
		 * <ul>
		 * <li>SharedObjectを取得する。</li>
		 * <li>配信者アライブタイマーを起動する</li>
		 * </ul>
		 * 
		 * @param e NetStatusEvent
		 */
		public function netConnectionStatusHandler_Chat(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					//					_so4 = _nc.getSo("statsTxt"+_castId, so4SyncEventHandler);		// チャットステータス
					_so4 = SharedObject.getRemote("statsTxt"+_castId, _nc.uri);
					_chatstats();
					_so = _nc.getSo("ourText"+_castId, soSyncEventHandler);		// チャットSO
					_nc.setSendMsgHandler(sendMsgHanler);		// SO 送信ハンドラ
					break;
				case "NetStream.Play.StreamNotFound":
					//					trace("Stream not found: " + videoURL);
					break;
			}
		}
		
		// チャットステータス用
		private function _chatstats():void
		{
			_so4.addEventListener(SyncEvent.SYNC , so4SyncEventHandler);
			_so4.connect(_nc);
			_so4.client = this;
			
		}
		
		/**
		 * コネクトセキュリティエラーハンドラ.
		 * 
		 * @param event SecurityErrorEvent
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
				msg = "<b>" + _castName + "</b>先生が入室されました。";
				_so.send("sendMsg", "CAST_LOGIN", msg, chatId,"SYSTEM" );
				
			}
		}
		
		private function receiveChat():void
		{
//			createListData();
		}
		
		
		// ビデオパブリッシュ
		private function publishVideo():void
		{
			publish_ns = new NetStream(_nc);
			publish_ns.addEventListener(NetStatusEvent.NET_STATUS, publishNetStatusEventHandler);
			publish_ns.attachCamera(theCamera);
			publish_ns.attachAudio(theMic);
			publish_ns.publish("cast" + _castId,  "record");
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
		
		private var rcv_ns:NetStream;		// 受信ストリーム
		private var rcv_video:Video;		// 受信ビデオ
		private var rcv_ns_self:NetStream;		// 受信ストリーム
		private var rcv_video_self:Video;		// 受信ビデオ
		
		// ビデオ受信
		private function receiveVideo():void
		{
			rcv_ns = new NetStream(_nc);
			rcv_ns.addEventListener(NetStatusEvent.NET_STATUS, receiveNetStreamStatusEventHandler);
			rcv_ns.bufferTime = 0.1;
			rcv_ns.play("client"+_userId);
			rcv_video = new Video();
			rcv_video.width = view.receive_video.width;
			rcv_video.height = view.receive_video.height;
			rcv_video.attachNetStream(rcv_ns);
			view.receive_video.addChild(rcv_video as DisplayObject);
		}
		
		// ビデオ受信
		private function receiveVideo_self():void
		{
			rcv_video_self = new Video();
			rcv_video_self.width = view.receive_video_self.width;
			rcv_video_self.height = view.receive_video_self.height;
			rcv_video_self.attachCamera(theCamera);
			view.receive_video_self.addChild(rcv_video_self as DisplayObject);
		}
		
		private var totalTime:Number;
		
		/**
		 * FMSからのメタデータ受信ハンドラ.
		 * 
		 * @param param
		 */
		public function onMetaData(param:Object):void 
		{
			totalTime = param.duration;
		}

		/**
		 * 受信ストリームステータスハンドラ.
		 * 
		 * @param e
		 */
		public function receiveNetStreamStatusEventHandler(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Stream not found: ");
					break;
			}
		}
		
		// いらない？
		private var _keepCategory:String;
		private var _keepItemList:String;
		private var _keepItemEtcName:String;
		private var _keepCastName:String;
		private var _chatNo:String;
		private var _chatViewCount:String;
		private var _workNgWordList:Array = new Array();
		
		// FMSへ生存通知タイマーハンドラ
		private function isAliveTimerHandler(e:Event):void
		{
			_nc.call("castAlive", null);
		}
		
		// キャスト初期情報取得ハンドラ
		private function castDataHandler(event:Event):void
		{
			var castData:String = _loader2.data;
			_loader2=null;
			
			if (castData == "")
			{
				view.errorMessageBox.errorMess.text = "接続エラーが発生しました。 ERR:1051";
				view.errorMessageBox.visible = true;
				return;
			}
			
			var work:Array;
			work = castData.split("RTN=");
			var ptn1:RegExp = new RegExp("%26");
			var ptn2:RegExp = new RegExp("\n");
			
			_keepCastName = work[0].replace(ptn1, "&");
			_keepCastName = _keepCastName.replace(ptn2, "");
			
			chatStart();	// チャット開始
		}
		
		// チャットスタートハンドラ
		private function castChatStartHandler(event:Event):void
		{
			var castData:String = _loader3.data;
			_loader3=null;
			
			var loader:CustomURLLoader = event.target as CustomURLLoader;
			if (loader.data != "1")
			{
				_nc.close();
				view.errorMessageBox.errorMess.text = "DBの書き込みに失敗しました。";
				view.errorMessageBox.visible = true;
				
			}
			else
			{
				mx.core.FlexGlobals.topLevelApplication.currentState='Chatting';			
			}
		}
		
		/**
		 * 配信開始.
		 * 
		 */
		public function castChatStart():void
		{
			// キャスト初期情報取得
			_loader3 = new CustomURLLoader();
			var fme_flg:String = "false";
			if (fme)
			{
				fme_flg = "true";
			}
			mx.core.FlexGlobals.topLevelApplication.currentState='Chatting';			

		}
		
		// デバッグ
		private function debugOut2():void
		{
			if (debug)
			{
				var msg:String;
				var obj:Object;
				// デバッグ
				for each(obj in acEntryFree)
				{
					msg = "acEntryFree id:" + obj.id + "\n  name:" + obj.name ;
					setChatMsg(msg, "", _castId, _castName, 0x008800);
				}
				for each(obj in acEntryPay)
				{
					msg = "acEntryPay id:" + obj.id + "\n  name:" + obj.name ;
					setChatMsg(msg, "", _castId, _castName, 0x008800);
				}
				for each(obj in acSelected)
				{
					msg = "acSelected id:" + obj.id + "\n  name:" + obj.name ;
					setChatMsg(msg, "", _castId, _castName, 0x008800);
				}
			}
		}
		
		// デバッグ
		private function debugOut1(msg:String):void
		{
			if (debug)
			{
				var color:Number = 0x008800;
				// デバッグ
				setChatMsg(msg, "", _castId, "デバッグ", color);
			}
		}
		
		/**
		 * Shared Object メッセージ受信処理.
		 * 
		 * @param JobType
		 * @param msg
		 * @param ChatId
		 * @param UserId
		 * @param UserName
		 */
		public function sendMsgHanler(JobType:String, msg:String, ChatId:String="", UserId:String="", UserName:String=null, ExUsers:String=null):void
		{
			var color:Number;
			var acKickUsers:ArrayCollection;
			var detected:Boolean = false;
			var obj:Object;
			var i:int;
			var datetime:String;
			
			debugOut1(JobType);		// デバッグ
			
			switch (JobType)
			{
				case "CHAT_ENDING":
					view.logout_menu.visible = true;
					return;
				case "TUHO_ENDING":
					if(UserId.indexOf("CAST") >= 0)
					{
						view.logout_menu2.visible = true;
					}
					return;
				case "TUHO_END":
					view.currentState = "ChatEnd";
					view.logoutMenu2.visible = true;
					return;
				case "CAST_CAMERA_OFF":
				case "CAST_CAMERA_ON":
					return;
				case "USER_CAMERA_OFF":
					view.receive_video.visible = false;
					return;
				case "USER_CAMERA_ON":
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
					else if (ChatId.indexOf("CAST") >=0)
					{
						datetime = ChatId.replace(/CAST:/, "");
						addMsg = "<font color = \"#ff6600\"><b>" + UserName + "</b></font><font color = \"#4b4039\">の発言</font>:  <font color = \"#999999\">" + datetime + "</font><br>";
					}
					else
					{
						datetime = ChatId.replace(/USER:/, "");
						addMsg = "<font color = \"#5789BB\"><b>" + UserName + "</b></font><font color = \"#4b4039\">の発言</font>:  <font color = \"#999999\">" + datetime + "</font><br>";
					}
					
					break;
			}
			
			if (msg != "")
			{
//ql				msg = replaceNgword(msg);
				msg = addMsg + "<font color = \"#524740\">　" + msg + "</font>";
				setChatMsg(msg, ChatId, UserId, UserName, color);
			}
			
		}
		
/*		private function doInsertInlineImg():void{
			// f_richEditableTextは RichEditableText
//			var textFlow:TextFlow  = view.f_richEditableText.textFlow as TextFlow;
			var textFlow:TextFlow  = view.msgarea.textFlow as TextFlow;
			
			//　全体のテキストの中で何番目の文字の前にキャレットがあるか？
			//			var absPos:int = view.f_richEditableText.selectionAnchorPosition;
			var absPos:int = 0;
			
			//  「行」を取得する
			
			var line:TextFlowLine = textFlow.flowComposer.findLineAtPosition(absPos);
			var para:ParagraphElement = line.paragraph;
			
			//  選択した「行」の何番目かの文字列か？
			var linePos:int = absPos - line.absoluteStart;
			//			var linePos:int = 0;
			
			//  行のパラグラフから、対象となる要素(ふつうは SpanElementかな )を取得する
			var targetElement:FlowLeafElement = line.paragraph.findLeaf(linePos);
			
			//  要素が始まる場所を全体の位置から引いて、要素内の何番目かを調べる
			var elementPos:int = absPos - targetElement.getAbsoluteStart();
			
			var rf:InlineGraphicElement;
			var childAt:int;
			
			if(targetElement.textLength > elementPos){
				var ele:FlowElement = targetElement.splitAtPosition(elementPos);
				childAt = para.getChildIndex(ele);
				rf = new InlineGraphicElement();
				rf.source = drawRect("[挿入文字]");
				para.addChildAt(childAt,rf);
			}
			else{
				//  ここに来ることはないはず・・・
			}
		}
		
		private function drawRect(label:String,height:int = 14):Sprite
		{
			var rect:Sprite = new Sprite();
			var text:TextField = new TextField();
			text.height = height;
			text.text = label;
			
			var width:int = text.width + 10;
			
			rect.addChild(text);
			rect.graphics.beginFill(0xff0000);
			rect.graphics.drawRect(0,0,width,height);
			rect.graphics.endFill();
			text.width = width;
			rect.width = width;
			return rect;
			
//			var tf:TextField = new TextField();
//			tf.htmlText = "";
		}
		
		[Embed(source='assets/picface/pic/001.gif')]
		[Bindable]
		private var e001:Class;

		// メッセージ
		private var msgtxt:TextField=new TextField();	// メッセージ内容
		private var msgcontent:Sprite=new Sprite();		// メッセージエリア
//		private var msgcontent:TextFlow=new TextFlow();		// メッセージエリア
*/
/*
		private var estr_arr:Array=["&01:","&02:","&03:","&04:","&05:"];
		private var elibs_arr:Array=["emo_1","emo_2","emo_3","emo_4","emo_5"];
		private var emotes_reg:RegExp=new RegExp("("+estr_arr.join("|")+")","gis");
		
		private function addTextToMsgArea(str:String):void{
			
			var t1:TextFormat=new TextFormat();
			t1.font = "MS ゴシック";//"Verdana";
			t1.color = 0x524740;
			t1.size = 14;
			t1.leading = 6;　
			t1.kerning = true;
			t1.letterSpacing = 1;
			t1.rightMargin = 10;
			t1.leftMargin = 10;
			
			customAppendText(str, t1);
		}
		
		private function customAppendText(str:String,tf:TextFormat):void {
			//trace("customAppendText");
			
			var old_index:int=msgtxt.length-1;
			var tmp_htmltext = msgtxt.htmlText;
			
			//msgtxt.appendText(str+"\n");
			msgtxt.htmlText += str;
			msgtxt.defaultTextFormat = tf;
//			msgarea.source=msgcontent;
			view.msgarea.textFlow = msgcontent;
			
			
			var nowtxt:String=msgtxt.text;
			//trace("nowtxt:"+nowtxt);
			var obj:Object=emotes_reg.exec(nowtxt);
			while (obj!=null) 
			{
				trace("obj:"+obj);
				var rectangle:Rectangle=msgtxt.getCharBoundaries(obj.index+1);
				trace("rectangle:"+rectangle );	//msgtxt.text.substr(rectangle.x,1)
				
				trace("-1:"+msgtxt.getCharBoundaries(obj.index-1));
				
				if(rectangle==null) break;
				addEmote(obj[0],rectangle);
				obj=emotes_reg.exec(nowtxt);
				
			}
			
			var end_index:int=msgtxt.length-1;
			str=str.replace(emotes_reg,"　　");
			//trace("str:"+str);
			msgtxt.replaceText(old_index,end_index,str);
			msgtxt.htmlText = tmp_htmltext;
			msgtxt.htmlText += str;
			
//			view.msgarea.update();
			_scrollToEnd();
		}
		
		private function addEmote(str:String,rectangle:Rectangle):void {
			var libname:String=getEmoteLibsName(str);
			trace("libname:"+libname);
			var libmc:MovieClip=getEmoteLibsMC(libname);
			libmc.x=rectangle.x-2;
			libmc.y=rectangle.y;
			if(libmc.x == 26){
				libmc.x = 39;
				libmc.y = libmc.y+5;
				trace("libmc:"+libmc.x+","+libmc.y );	//msgtxt.text.substr(rectangle.x,1)
				
			}
			msgcontent.addChild(libmc);
		}
		
		private function getEmoteLibsName(str:String):String {
			for (var each in estr_arr) {
				if (str==estr_arr[each]) {
					return String(elibs_arr[each]);
					break;
				}
				import flash.display.Shape;
				import flash.geom.ColorTransform;
				
			}
			throw new Error("Error:can't find "+str+" in estr_arr");
		}
		
		private function getEmoteLibsMC(str:String):MovieClip {
			var mcclass:Class=getDefinitionByName(str) as Class;
			if (mcclass!=null) {
				return MovieClip(new mcclass());
			}
			throw new Error("Error:can't find "+str+" in libs");
		}
		
		private function _scrollToEnd()
		{
			trace("scroll1:"+msgarea.maxVerticalScrollPosition);
			msgarea.verticalScrollPosition=msgarea.maxVerticalScrollPosition+30;
			trace("scroll2:"+msgarea.verticalScrollPosition);
			trace("scrollbar:"+msgarea.verticalScrollBar);
		}
*/		
		private function setChatMsg(msg:String, chatId:String, userId:String, userName:String, color:Number):void
		{
			msg = msg.replace(/&e...:/g, '<img src="http://' + DefineNetConnection.url_web + '/assets/picface/pic/001.gif" />');
			
			var html_text:String = view.chat_disp.htmlText;
			view.chat_disp.htmlText = html_text + msg;
			
			view.chat_disp.validateNow();
			view.chat_disp.callLater(chatScroll);
			
//			doInsertInlineImg();
			
//			addTextToMsgArea(msg);
			
		}
		
		// チャットスクロール
		private function chatScroll():void
		{
			view.chat_disp.verticalScrollPosition = view.chat_disp.maxVerticalScrollPosition;
		}
		
		// チャットスクロール
		private function chatScroll2():void
		{
//			var chatSkin:chatMsgDataListSkin = view.chat_msg.skin as chatMsgDataListSkin;
//			chatSkin.vscrollbar.value = chatSkin.vscrollbar.maximum;
		}
		
		private var _avm1:AVM1Movie;
		private var animeTimer:Timer;
		/**
		 * FMSからのキャストログアウト呼び出しハンドラ.
		 * 
		 * <p>プレースホルダのみで何もしていない</p>
		 */
		public function castLogout():void
		{
			// 何もしない
		}
		
		/**
		 * FMSからの待ちユーザカウント呼び出しハンドラ.
		 * 
		 * <p>プレースホルダのみで何もしていない</p>
		 * 
		 * @param dat1
		 */
		public function rtnWaitUserCount(dat1:Number):void
		{
			// 何もしない
		}
		
		/**
		 * FMSからのログインユーザ通知ハンドラ.
		 * 
		 * <p>ユーザーがFMSに接続時にFMSから通知される。
		 * ユーザIDと名前をアレイコレクションに登録する。
		 * 生電話時、ユーザの元データとして使用する。</p>
		 * 
		 * @param id 接続したユーザID
		 * @param name 接続したユーザ名
		 */
		public function loginUserInfo(id:String, name:String):void
		{
			var obj:Object = new Object();
			obj.id = id;
			obj.name = name;
			acMicUser.addItem(obj);		// 入れる
		}
		
		/**
		 * FMSからのログアウトユーザ通知ハンドラ.
		 * 
		 * <p>ユーザーがFMSから接続解除時にFMSから通知される。
		 * ユーザIDと名前をアレイコレクションから削除する。
		 * 生電話時、ユーザの元データとして使用する。</p>
		 * 
		 * @param id 接続解除したユーザID
		 * @param name 接続解除したユーザ名
		 */
		public function logoutUserInfo(id:String, name:String):void
		{
			var obj:Object = getMicUser(id);
			// マイクユーザ
			var i:int = acMicUser.getItemIndex(obj);
			if (i>=0)
			{
				acMicUser.removeItemAt(i);		// はずす
			}
			// 当選済みユーザ
			i = acSelected.getItemIndex(obj);
			if (i>=0)
			{
				acSelected.removeItemAt(i);		// はずす
			}
		}
		
		private function getMicUser(id:String):Object
		{
			for each (var obj:Object in acMicUser)
			{
				if (obj.id == id)
				{
					return obj;
				}
			}
			
			return new Object();
		}
		
		private function setAcFree():void
		{
			// あたってない人コピー（無料）
			for each(var obj:Object in acEntryFree)
			{
				if (acSelected.getItemIndex(obj) < 0 )
				{
					acSelect_Free.addItem(ObjectUtil.copy(obj));
				}
			}
		}
		
		private function setAcPay():void
		{
			// あたってない人コピー（有料）
			for each(var obj:Object in acEntryPay)
			{
				if (acSelected.getItemIndex(obj) < 0 )
				{
					acSelect_Pay.addItem(ObjectUtil.copy(obj));
				}
			}
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
			
			view.panel_moji.visible = true;
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
			
			view.panel_moji.visible = false;
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
		 * 通報するボタンクリックハンドラ.
		 * 
		 * <p></p>
		 */
		public function tuho_btnOnClickHandler(e:Event):void
		{
			_so.send("sendMsg", "TUHO_ENDING", "", "", "CAST");
//			view.logout_menu2.visible = true;
		}
		
		public function tuhoEnd():void
		{
			_so.send("sendMsg", "TUHO_END", "", "", "CAST");
			//			view.logout_menu2.visible = true;
		}
		
		public function reportForm():void
		{
			view.report_form.start_time.text = begin_time_str;
			view.report_form.client_name.text = client_name;
			view.report_form.counselor_name.text = _castName;
			view.report_form.reporting_name.text = _castName;
			
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
			variables.notifier　= _castId　;
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
		public var _view:cast;
		
		/**
		 * 画面を取得します
		 */
		public function get view():cast
		{
			if (_view == null)
			{
				_view = super.document as cast;
			}
			return _view;
		}
		
		/**
		 * 画面をセットします。
		 *
		 * @param view セットする画面
		 */
		public function set view(view:cast):void
		{
			_view = view;
		}
		
	}
}