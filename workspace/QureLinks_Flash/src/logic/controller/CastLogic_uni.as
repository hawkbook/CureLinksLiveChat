package logic.controller
{
	import components.NgwordMsgDataListSkin;
	import components.chatMsgDataListSkin;
	
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display.Sprite;
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
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.system.fscommand;
	import flash.utils.Timer;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
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
	
	import flashx.textLayout.elements.*;
	import flashx.textLayout.compose.*;
	
	import flash.text.TextFormat;
	
	/**
	 * cast.mxmlに対するメインのロジッククラス.
	 * 
	 * <br>view(cast.mxml)の部品イベントのハンドラを自動生成するために 
	 * 	Logic2クラスを継承する。
	 */
	public class CastLogic_uni extends Logic2
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
//		[Bindable]
//		public var acChatMsg:ArrayCollection = new ArrayCollection();
/*		public var acChatMsg:ArrayCollection = new ArrayCollection(
			[
				 {msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
				,{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
			]);
*/
		
		private var _castId:String;			// キャストID
		private var _castName:String;			// キャスト名
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
//		private var _volumeBounds:Rectangle = new Rectangle(425,402,505-425,402-402);
		private var _volumeBounds:Rectangle = new Rectangle(275,391,505-425,0);
		private var micLevelTimer:Timer;	// マイクレベルメータのタイマー
		private var connectionNgTimer:Timer;	// マイクレベルメータのタイマー
//		private var selectTimer:Timer;		// 抽選開始までのタイマー
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
		
		/**
		 * コンストラクタ.
		 */
		public function CastLogic_uni()
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
			_castName = view.parameters.name;
			begin_time = view.parameters.begin_time;
			begin_time_str = view.parameters.begin_time_str;
			profile = view.parameters.profile;
			schedule_id = view.parameters.schedule_id;
			schedulelist = view.parameters.schedulelist;
			_chatStartTime = view.parameters.session_time;
			
			if (_castId == null)
			{
				// デバッグ
				_castId = "1234567890";
			}
			
			view.chatTitle.text = _castName + "\n" + begin_time_str;
			view.profile_disp.text = profile;
			
			view.schedule_disp.text = schedulelist;
			
//			keepChatTitle = view.parameters.ctitle;		// チャットタイトル
//			view.chatTitle.text = keepChatTitle;
			view.chat_msg_box.addEventListener(KeyboardEvent.KEY_UP, chat_msg_boxOnKeyUpHandler);
			
			// マイクボリュームバー設定
			view.volume_mic.x = 275+(ConstValues.MIC_GAIN*0.7);
			view.volume_bar.width = view.volume_mic.x - 275;
			
			if (view.stage != null)
			{
				view.stage.scaleMode = StageScaleMode.SHOW_ALL;
			}
			else
			{
				view.addEventListener(Event.ADDED_TO_STAGE, setScaleMode);
			}
			
			// タイマーの初期化
			connectionNgTimer = new Timer(ConstValues.TIMER_CONNECTION,1);		// コネクションNGタイマー
			connectionNgTimer.addEventListener(TimerEvent.TIMER, connectionNgHandler);	// タイマーイベントを設定
			
			micLevelTimer = new Timer(ConstValues.TIMER_MICLEVEL,0);		// マイクレベルタイマー
			micLevelTimer.addEventListener(TimerEvent.TIMER, micActiveBarHandler);		// タイマーイベントを設定

			chatTimer = new Timer(ConstValues.TIMER_CHAT,0);		// チャットタイマー
			chatTimer.addEventListener(TimerEvent.TIMER, chatTimerHandler);		// タイマーイベントを設定
			
//ql			isAliveTimer = new Timer(ConstValues.TIMER_ALIVE, 0);
//ql			isAliveTimer.addEventListener(TimerEvent.TIMER, isAliveTimerHandler);		// タイマーイベントを設定
			
//			selectTimer = new Timer(ConstValues.TIMER_SELECT,1);				// コネクションNGタイマー
//			selectTimer.addEventListener(TimerEvent.TIMER, selectTimerHandler);	// タイマーイベントを設定
			
			waitSlotTimer = new Timer(ConstValues.TIMER_WAIT_SLOT,1);					// NGタイマー
			waitSlotTimer.addEventListener(TimerEvent.TIMER, waitStateTimerHandler);	// タイマーイベントを設定
			
			waitSelectedTimer = new Timer(ConstValues.TIMER_WAIT_SELECTED,1);				// NGタイマー
			waitSelectedTimer.addEventListener(TimerEvent.TIMER, waitStateTimerHandler);	// タイマーイベントを設定
			
			waitCallingTimer = new Timer(ConstValues.TIMER_WAIT_CALLING,1);				// NGタイマー
			waitCallingTimer.addEventListener(TimerEvent.TIMER, waitStateTimerHandler);	// タイマーイベントを設定
			
			waitSpeakStartTimer = new Timer(ConstValues.TIMER_WAIT_SPEAKSTART,1);				// NGタイマー
			waitSpeakStartTimer.addEventListener(TimerEvent.TIMER, waitStateTimerHandler);	// タイマーイベントを設定
			
			sendEntryStartTimer = new Timer(ConstValues.TIMER_LOOP_ENTRY_START,0);				// NGタイマー
			sendEntryStartTimer.addEventListener(TimerEvent.TIMER, sendEntryStartTimerHandler);	// タイマーイベントを設定
			
			// デバッグ
//			acEntryFree.addEventListener(CollectionEvent.COLLECTION_CHANGE, acSelectEntryEventHandler);

			//ql
			startChatConnection();
			
//			itemSet();
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
			view.loginBtn.visible = false;
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
//			view.testFineBtn.visible = false;
//			view.testNormalBtn.visible = false;
//			view.testFineStopBtn.visible = false;
//			view.testNormalStopBtn.visible = false;

			view.loginBtn.visible = false;
			view.logoutBtn.visible = true;
			
			view.chat_send_btn.enabled = true;
			view.mic_on_btn.enabled = true;
			view.mic_on_btn.visible = true;
			view.mic_off_btn.enabled = false;
			view.mic_off_btn.visible = false;
			
			view.chat_msg_box.text = "";

			if (fme)
			{
				view.volume_mic.visible = false;
				view.volume_bar.visible = false;
			}
			else
			{
				view.volume_mic.visible = true;
				view.volume_bar.visible = true;
			}
			
			chatTimer.start();		// チャットタイマーを動かす
			
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
//ql			mx.core.FlexGlobals.topLevelApplication.currentState='Testing';
//ql			getCastInitData();		// キャスト初期データ
//ql			getCastData();			// キャストデータ
			
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
		 * 配信開始ボタンクリックハンドラ.
		 * 
		 * 配信開始メニューを可視化する。
		 * @param event
		 */
		public function loginBtnOnClickHandler(event:Event):void
		{
			_state = mx.core.FlexGlobals.topLevelApplication.currentState;
			if ( _state == 'Testing' ) 
			{
				view.login_menu.visible = true;
			}
		}
		
		/**
		 * 配信終了ボタンクリックハンドラ.
		 * 
		 * 配信終了メニューを可視化する。
		 * @param event
		 */
		public function logoutBtnOnClickHandler(event:Event):void
		{
			view.logout_menu.visible = true;
		}
		
		/**
		 * チャットタブボタンクリックハンドラ.
		 * <ul>
		 * <li>ＮＧワードリストを不可視化する</li>
		 * <li>チャット機能をイネーブルにする</li>
		 * </ul>
		 * 
		 * @param event
		 */
/*		public function chat_btnOnClickHandler(event:Event):void
		{
//			mx.core.FlexGlobals.topLevelApplication.currentState='NGWords';
			view.ngword_msg.visible = false;
			view.ngword_send_btn.visible = false;
			view.ngword_msg_box.visible = false;
			view.ngword_del_btn.visible = false;
			view.chat_disp.visible = true;
			view.chat_send_btn.visible = true;
			view.chat_msg_box.visible = true;
			view.ngwordArea.visible = false;
		}
*/		
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
			var str:String = send_str.replace(/\n/g,"");
			str = str.replace(/\r/g,"");
			
			if (str.length > 0)
			{
				sendText = sendText.replace(/\n/g,"<br>");
				if (_isIconBClicked)
				{
					sendText = "<b>" + sendText + "</b>";
				}
				sendText = sendText + "<br/><br/>"
				_so.send("sendMsg", "*"+_castName, _castName+"\n"+sendText, "CAST:"+_date.getTime(), "CAST"+_castId, _castName);
				
				view.chat_msg_box.text="";
				sendText = "";
				//				view.chat_msg_box.callLater(clear_chat_msg_box);
			}
		}
		
		/**
		 * チャット入力ボックス内Enterキーハンドラ.
		 * 
		 * chat_send_btnOnClickHandler()を呼び出すのみ。
		 * @param event
		 */
		public function chat_msg_boxOnKeyUpHandler(event:Event):void
		{
			var _date:Date = new Date();
			var keyEvent:KeyboardEvent = event as KeyboardEvent;
			sendText = view.chat_msg_box.text;
			if (keyEvent.keyCode == 13)
			{
				if (view.enter_chat_in.selected)
				{
					var str:String = sendText.replace(/\n/g,"");
					str = str.replace(/\r/g,"");
					
					if (str.length > 0)
					{
						//						sendText += str.charCodeAt(0);
						sendText = sendText.substr(0,sendText.length-1);
//						chat_send_btnOnClickHandler(event);
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
			if (theMic != null)
			{
				view.mic_on_btn.enabled = false;
				view.mic_on_btn.visible = false;
				view.mic_off_btn.enabled = true;
				view.mic_off_btn.visible = true;
				theMic.setSilenceLevel(100);		// ミュート
				theMic.gain = 0;
			}
		}
		
		/**
		 * ボリュームＯＦＦボタンクリックハンドラ.
		 * 
		 * マイクのゲインを０に設定し、サイレンスレベルを１００に設定する。
		 * @param event
		 */
		public function mic_off_btnOnClickHandler(event:Event):void
		{
			if (theMic != null)
			{
				view.mic_on_btn.enabled = true;
				view.mic_on_btn.visible = true;
				view.mic_off_btn.enabled = false;
				view.mic_off_btn.visible = false;
				theMic.setSilenceLevel(ConstValues.MIC_SILENCELEVEL);	// サイレンスレベル
				theMic.gain = _micCurrentGain;
			}
		}
		
		/**
		 * マイクボリュームマウスダウンハンドラ.
		 * 
		 * マイクボリュームのドラッグ開始処理。
		 * @param event
		 */
		public function volume_micOnMouseDownHandler(event:MouseEvent):void
		{
			_dragActive = true;
			view.volume_mic.startDrag(false,_volumeBounds);
		}
		
		/**
		 * マイクボリュームマウスアップハンドラ.
		 * マイクボリュームドラッグ終了処理。
		 * @param event
		 */
		public function volume_micOnMouseUpHandler(event:MouseEvent):void
		{
			_dragActive = false;
			view.volume_mic.stopDrag();
		}
		
		/**
		 * マイクボリュームマウスアウトハンドラ.
		 * 
		 * マイクボリュームドラッグ終了。
		 * @param event
		 */
		public function volume_micOnMouseOutHandler(event:MouseEvent):void
		{
			_dragActive = false;
			view.volume_mic.stopDrag();
		}
		
		/**
		 * マイクボリュームマウスムーブハンドラ.
		 * 
		 * マイクボリュームドラッグ処理。
		 * 
		 * @param event
		 */
		public function volume_micOnMouseMoveHandler(event:MouseEvent):void 
		{
			if (_dragActive)
			{
				//videoClip.audioVol(425,505,this._x);
//				_micCurrentGain = 80 + view.volume_mic.x - 505;
				var vol:int = view.volume_mic.x - _volumeBounds.x
				_micCurrentGain = ConstValues.MIC_GAIN * (vol/_volumeBounds.width);
//				view.volume_bar.width = view.volume_mic.x - 425;
				view.volume_bar.width = vol;
				
				if (view.mic_off_btn.enabled == true)
				{
					theMic.gain = _micCurrentGain;
				}
			}
		}
		
		/**
		 * NGワード削除ボタンクリックハンドラ.
		 * 
		 * NGワードアレイコレクションからチェックされたNGワードを削除する。
		 * 
		 * @param event
		 */
/*		public function ngword_del_btnOnClickHandler(event:Event):void
		{
			var length:int = acNgword.length;
			for(var i:int=length-1; i >=0 ; i--)
			{
				var obj:Object = acNgword.getItemAt(i);
				if ( obj.msgCheck)
				{
//					_so.send("sendMsg", "MSGDEL", "", obj.msgNo);
					acNgword.removeItemAt(i);
				}
			}
		}
*/		
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
			
			if (!fme)
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
				var vol:int = view.volume_mic.x - _volumeBounds.x
				_micCurrentGain = ConstValues.MIC_GAIN * (vol/_volumeBounds.width);
				view.volume_bar.width = vol;
				
				theMic.gain = _micCurrentGain;
				
				// コネクションを張る
				rtmp = "rtmp://" + DefineNetConnection.url_fms + "/cast/" + _castId;
				_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler_Normal, _castId, "CAST");
				
			}
			else
			{
				// FMEコネクションを張る
				rtmp = "rtmp://" + DefineNetConnection.url_fms + "/castLive/" + _castId;
				_ncFme = new CustomNetConnection(rtmp, this.netConnectionStatusHandler_Fme, _castId, "CAST");
				
				view.chat_msg_box.text = rtmp;
				
				// コネクションを張る
				rtmp = "rtmp://" + DefineNetConnection.url_fms + "/cast/" + _castId;
				_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler_Chat, _castId, "CAST");
				
			}
			
			// チャット用データプロバイダ設定
//			view.chat_msg.dataProvider = acChatMsg;
			
			// 禁止ワード用データプロバイダ設定
//ql			view.ngword_msg.dataProvider = acNgword;
			
			view.chat_send_btn.visible = true;
		}
		
		private function setActivityTimer(event:Event):void
		{
			micLevelTimer.start();
			theMic.gain = _micCurrentGain;
		}
		
		// マイク音量レベル表示
		private function micActiveBarHandler(e:Event):void
		{
			var level:int = theMic.activityLevel;
//			trace (level);
			view.micActiveLevel.inLevel.micLevel.width = level*239/100 ;
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
					receiveVideo();		// Video受信
					_chatstats();
					_so = _nc.getSo("ourText"+_castId, soSyncEventHandler);		// チャットSO
					_nc.setSendMsgHandler(sendMsgHanler);		// SO 送信ハンドラ
					connectionNgTimer.start();				//Timerを動かす
//ql					isAliveTimer.start();		// アライブタイマースタート
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
//ql					isAliveTimer.start();		// アライブタイマースタート
					break;
				case "NetStream.Play.StreamNotFound":
					//					trace("Stream not found: " + videoURL);
					break;
			}
		}
		
		/**
		 * NetConnection 高画質ビデオコネクトステータスハンドラ（高品質配信時）.
		 * <p>高画質ビデオを受信開始する。</p>
		 * @param e
		 */
		public function netConnectionStatusHandler_Fme(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					//					_so4 = _nc.getSo("statsTxt"+_castId, so4SyncEventHandler);		// チャットステータス
					receiveVideo_Fme();		// Video受信
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
			
//			_so4.removeEventListener(SyncEvent.SYNC , so4SyncEventHandler);
			
		}
		
		// チャット用 FMS-SO (ourText)ハンドラ
		private function soSyncEventHandler(event:SyncEvent):void
		{
			trace("SyncEvent." + event.type);
//			receiveChat();

			if (event.type == "sync")
			{
				var msg:String;
				msg = _castName + "先生が\n入室されました。\n\n";
				var _date:Date = new Date();
				_so.send("sendMsg", "USER_LOGIN", msg, "CAST:" + _date.getTime(),"CAST"+_castId );
				
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
//			publish_ns.publish("cast"+_castId);
			publish_ns.publish("cast"+_castId,  "record");
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
		
		// ビデオ受信
		private function receiveVideo():void
		{
			rcv_ns = new NetStream(_nc);
			rcv_ns.addEventListener(NetStatusEvent.NET_STATUS, receiveNetStreamStatusEventHandler);
			rcv_ns.bufferTime = 1;
			rcv_ns.play("cast"+_castId);
			rcv_video = new Video();
			rcv_video.width = ConstValues.CAMERA_WIDTH;
			rcv_video.height = ConstValues.CAMERA_HEIGHT;
			rcv_video.attachNetStream(rcv_ns);
			rcv_ns.receiveAudio(false);			// ハウリング対策
			view.receive_video.addChild(rcv_video as DisplayObject);
			
		}
		
		// FMEビデオ受信
		private function receiveVideo_Fme():void
		{
			rcv_ns = new NetStream(_ncFme);
			rcv_ns.addEventListener(NetStatusEvent.NET_STATUS, receiveNetStreamStatusEventHandler);
			rcv_ns.bufferTime = 1;
			rcv_ns.play("cast"+_castId);
			rcv_video = new Video();
			rcv_video.width = ConstValues.CAMERA_WIDTH;
			rcv_video.height = ConstValues.CAMERA_HEIGHT;
			rcv_video.attachNetStream(rcv_ns);
			rcv_ns.receiveAudio(false);			// ハウリング対策
			view.receive_video.addChild(rcv_video as DisplayObject);
			
			rcv_ns.client = this;
			
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
		
		/**
		 * connectionNgTimerのハンドラ（６０秒後もまだ配信していない）
		 **/
		private function connectionNgHandler(event:Event):void
		{
			if (theCamera.activityLevel == -1)
			{
				view.errorMessageBox.errorMess.text = "ビデオを取得できませんでした。";
				view.errorMessageBox.visible = true;
				
				_nc.call("CastOFF",null);		// オフライン
				
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
		
		// キャスト初期情報取得ハンドラ
		private function chatInitDataHandler(event:Event):void
		{
			var castData:String = _loader1.data;
			_loader1=null;
			
			if (castData == "RTN=0")
			{
//				view.currentState = "ErrorState";
				view.errorMessageBox.errorMess.text = "接続エラーが発生しました。 ERR:1051";
				view.errorMessageBox.visible = true;
				return;
			}
			
			var work:Array;
			work = castData.split("<TAB>");
//			keepChatTitle = work[3];
//			view.chatTitle.text = keepChatTitle;
			_castName = work[20];
			
			_keepCategory = work[0];
			_keepItemList = work[1];
			_keepItemEtcName = work[2];
//			keepChatTitle = work[3];
//			ChatTitle.text = Keep_ChatTitle;
//			_chatStartTime = 0;
			_chatNo = work[17];
			_chatViewCount = work[18];
//			_workNgWordList = work[19].split(",");
			
			// ＮＧワード追加
/*			for (var z:int = 0; z < _workNgWordList.length; z++) 
			{
				if(_workNgWordList[z] != "")
				{
					setNgWord(_workNgWordList[z], "CAST" + _castId);
				}
			}
*/			
			//延視聴者数セット
//			view.loginInfo1.text = (int(_chatViewCount)+1).toString();

		}
		
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
		 * キャスト初期情報取得.
		 * 
		 */
		public function getCastInitData():void
		{
			// キャスト初期情報取得
			_loader1 = new CustomURLLoader();
			if (!_loader1.customLoad(true, "http://" + DefineNetConnection.url_web + "/cast/chat_init_data.cgi?dat1=" + _castId, _castId, chatInitDataHandler))
			{
				view.errorMessageBox.errorMess.text = "接続エラーが発生しました。 ERR:1050";
				view.errorMessageBox.visible = true;
//				Alert.show("接続エラーが発生しました。 ERR:1052", "接続エラー");
			}
		}
		
		/**
		 * キャスト情報取得.
		 * 
		 */
		public function getCastData():void
		{
			// キャスト初期情報取得
			_loader2 = new CustomURLLoader();
			if (!_loader2.customLoad(true, "http://" + DefineNetConnection.url_web + "/cast/castdata.cgi?type=name", _castId, castDataHandler))
			{
				view.errorMessageBox.errorMess.text = "名前の取得に失敗しました。ERR1030";
				view.errorMessageBox.visible = true;
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
//			if (!_loader3.customLoad("http://" + DefineNetConnection.url_web + "/cast/cast_chat_start.cgi?" + _castId, castChatStartHandler, _castId))
//			if (!_loader3.customLoad(false, "http://" + DefineNetConnection.url_web + "/cast/cast_chat_start.cgi?CAST_ID=" + _castId + "&FME=" + fme, null, castChatStartHandler))
			var fme_flg:String = "false";
			if (fme)
			{
				fme_flg = "true";
			}
/*ql			if (!_loader3.customLoad(true, "http://" + DefineNetConnection.url_web + "/cast/cast_chat_start.cgi", null, castChatStartHandler,null,_castId,fme_flg))
			{
				view.errorMessageBox.errorMess.text = "DBの書き込みに失敗しました。";
				view.errorMessageBox.visible = true;
			}
*/			
			// for QL
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
			
			debugOut1(JobType);		// デバッグ
			
			switch (JobType)
			{
				case "MSGDEL":
				case "SEND_NGWORD":
					return;
				case "USER_LOGIN":
				case "USERLIKE":
				default:
					if(UserId.indexOf("CAST") >= 0)
					{
						color = 0x005000;
					}
					else
					{
						color = 0x000000;
					}
					break;
			}
			
			if (msg != "")
			{
//ql				msg = replaceNgword(msg);
				setChatMsg(msg, ChatId, UserId, UserName, color);
			}
			
		}
		
		// NGワード置換
/*		private function replaceNgword(msg:String):String
		{
			var ptn1:RegExp;
			for(var i:int=0; i<acNgword.length; i++)
			{
				if (acNgword.source[i].msg != "")
				{
					ptn1 = new RegExp(acNgword.source[i].msg);
					msg = msg.replace(ptn1, "***");
				}
			}
			return msg;
		}
*/		
		
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
//			msg = msg.replace(/&e...:/g, '<img src="{' + e001 + '}" />');
			
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
		
/*		
		private function setChatMsg(msg:String, chatId:String, userId:String, userName:String, color:Number):void
		{
			var chatSkin:chatMsgDataListSkin = view.chat_msg.skin as chatMsgDataListSkin;
			var obj:Object = new Object();
			obj.msg = msg;					// メッセージ
			obj.msgNo = chatId;				// 
			obj.msgUser = userId;
			obj.msgUserName = userName;
			obj.msgCheck = false;
			obj.msgColor = color;
			acChatMsg.addItem(obj);
			
			//			acChatMsg.refresh();
			
			chatSkin.dataGroup.callLater(chatScroll);	// スクロールは後から
		}
*/		
		// チャットスクロール
/*		private function chatScroll():void
		{
//			var chatSkin:chatMsgDataListSkin = view.chat_msg.skin as chatMsgDataListSkin;
//			chatSkin.vscrollbar.value = chatSkin.vscrollbar.maximum;
//			chatSkin.dataGroup.callLater(chatScroll2);	// スクロールは後から
		}
*/		
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
		
		/**
		 * 生電話エントリー開始処理.
		 * 
		 * <p>
		 * エントリー開始ボタンがクリックされたら呼ばれる。
		 * <ul>
		 * <li>前回のエントリーをクリアする</li>
		 * <li>ENTRY_STARTメッセージを送る</li>
		 * </ul>
		 * </p>
		 */
/*		public function entryStart():void
		{
			var i:int;
			var exceptUserId:String = "";
			var count:int;
			var obj:Object;
			
			// エントリーを初期化
			acEntryFree.removeAll();
			acEntryPay.removeAll();
			userMicCount = 0;
			view.telInfo.logic.setMicCount(userMicCount);
			
//			_so.send("sendMsg", "ENTRY_START", "", "",exceptUserId );
			_so.send("sendMsg", "ENTRY_START", "", "");
			sendEntryStartTimer.start();		// 一定時間ごとにENTRY_STARTを送る
		}
*/		
		private function sendEntryStartTimerHandler(e:Event):void
		{
			_so.send("sendMsg", "ENTRY_START", "", "" );
		}
		
		/**
		 * エントリー中止処理.
		 * 
		 * Shared Objectで ENTRY_STOP メッセージを送る。
		 */
		public function entryStop():void
		{
			_so.send("sendMsg", "ENTRY_STOP", "", "" );
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
		 * 抽選開始処理.
		 * 
		 * <p>エントリー受付終了ボタンクリック時に呼ばれる</p>
		 * 
		 * <ol>
		 * <li>既に当選している人（acSelectedに登録されている人）は抽選からはずす</li>
		 * <li>有料エントリーがあればその中から抽選する</li>
		 * <li>無料エントリーがあればその中から抽選する</li>
		 * <li>SLOT_STARTメッセージをSharedObjectで送る</li>
		 * </ol>
		 * 
		 */
		public function slotStart():void
		{
			var i:int;
			var obj:Object;
			var exceptUserId:String = "";
			
			acSelect_Free = new ArrayCollection();
			acSelect_Pay = new ArrayCollection();
			
//			debugOut2();
			
			sendEntryStartTimer.reset();
			
			setAcFree();	// あたっていない無料エントリー
			setAcPay();		// あたっていない有料エントリー
			
			// だれもいなかったらあたり済みをクリアしてもう一度
			if ((acSelect_Free.length + acSelect_Pay.length) == 0 )
			{
				acSelected.removeAll();
				setAcFree();	// あたっていない無料エントリー
				setAcPay();		// あたっていない有料エントリー
			}
			
			// 既に当選した人は除外
			for each(obj in acSelected)
			{
				exceptUserId += "," + obj.id;
			}
			
			if (acSelect_Pay.length > 0)
			{
				// 有料抽選
				i = Math.floor(Math.random() * acSelect_Pay.length);
				obj = acSelect_Pay.getItemAt(i);
debugOut1("有料あたり：i=" + i.toString() + ":" + obj.id + ":" + obj.name + "\nEx:"+ exceptUserId);
				_so.send("sendMsg", "SLOT_START", "", "", obj.id, obj.name, exceptUserId );
			}
			else if (acSelect_Free.length > 0)
			{
				// 無料抽選
				i = Math.floor(Math.random() * acSelect_Free.length);
				obj = acSelect_Free.getItemAt(i);
debugOut1("無料あたり：i=" + i.toString() + ":" + obj.id + ":" + obj.name + "\nEx:"+ exceptUserId);
				_so.send("sendMsg", "SLOT_START", "", "", obj.id, obj.name, exceptUserId );
			}
			else
			{
//				upOrEnd();
				_so.send("sendMsg", "SELECT_END", "", "" );
			}
			
		}
		
		// 抽選開始からのステート間タイマータイムアウト
		private function waitStateTimerHandler(e:Event):void
		{
			telEnd();
		}
		
		/**
		 * 生電話終了処理.
		 * 
		 * <p>Shared ObjectでSPEAK_ENDメッセージを送信する。</p>
		 */
		public function telEnd():void
		{
			_so.send("sendMsg", "SPEAK_END", "", "", telUserId, telUserName);
		}

		/**
		 * ユーザ追放処理.
		 * 
		 * <p>Shared ObjectでUSERKICKメッセージを送信する。</p>
		 */
		public function telKickOut():void
		{
			_so.send("sendMsg", "USERKICK", "", "", telUserId, telUserName);
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
			
		}
		
		//--------------------------------------
		// View-Logic Binding
		//--------------------------------------
		
		/** 画面 */
		public var _view:cast_uni;
		
		/**
		 * 画面を取得します
		 */
		public function get view():cast_uni
		{
			if (_view == null)
			{
				_view = super.document as cast_uni;
			}
			return _view;
		}
		
		/**
		 * 画面をセットします。
		 *
		 * @param view セットする画面
		 */
		public function set view(view:cast_uni):void
		{
			_view = view;
		}
		
	}
}