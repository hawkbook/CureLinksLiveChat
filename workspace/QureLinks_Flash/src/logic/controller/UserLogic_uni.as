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
	
	/**
	 * cast.mxmlに対するメインのロジッククラス.
	 * 
	 * <br>view(cast.mxml)の部品イベントのハンドラを自動生成するために 
	 * Logic2クラスを継承する。
	 */
	public class UserLogic_uni extends Logic2
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
/*		[Bindable]
		public var acChatMsg:ArrayCollection = new ArrayCollection(
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
		
/*		[Bindable]
		public var acChatMsg:ArrayCollection = new ArrayCollection([
			{msg:"", msgNo:"", msgUser:"",msgUserName:"",msgCheck:null,msgColor:null}
		]);
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
		
		private var _cast_login_id:String;		// キャストログインID
		private var _cast_id:String;			// キャストID
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
		private var _volumeBounds:Rectangle = new Rectangle(285,409,80,0);
		private var micLevelTimer:Timer;	// マイクレベルメータのタイマー
		private var connectionNgTimer:Timer;	// マイクレベルメータのタイマー
		private var chatTimer:Timer;		// 放送時間のタイマー
		private var _chatStartTime:int = 60*60;
		private var userAliveTimer:Timer;		// ユーザのFMS接続タイマー
		private var checkWaitInTimer:Timer;
		private var waitInTimer:Timer;
		private var payTimer:Timer;
		private var likeEndTimer:Timer;
		private var rcv_ns:NetStream;		// 受信ストリーム
		private var rcv_video:Video;		// 受信ビデオ
		
		private var _so:SharedObject;		// so
		private var _so4:SharedObject;		// ステータス用SO
		private var _so4Stats:String;		// soステータス
		
		private var _chatDelCounter:int;	// チャット削除カウンタ
		private var _ngwordDelCounter:int;	// NGワード削除カウンタ
		
		private var soundVolume:Number = 0.75;
		
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
		public function UserLogic_uni()
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
			
			_cast_login_id = view.parameters.counselor_id;
			_castName = view.parameters.name;
			begin_time = view.parameters.begin_time;
			begin_time_str = view.parameters.begin_time_str;
			profile = view.parameters.profile;
			schedule_id = view.parameters.schedule_id;
			schedulelist = view.parameters.schedulelist;
			_chatStartTime = view.parameters.session_time;
			
			if (_cast_login_id == null)
			{
				_cast_login_id = "1234567890";
			}
			if (_cast_id == null)
			{
				_cast_id = "181";
			}
			
			view.chatTitle.text = _castName + "\n" + begin_time_str;
			view.profile_disp.text = profile;
			
			view.schedule_disp.text = schedulelist;
			
			trace("_cast_login_id=" + _cast_login_id);
			trace("_cast_id=" + _cast_id);
			
//			view.addEventListener(KeyboardEvent.KEY_UP, appKeyHandler);
//			view.chat_msg_box.addEventListener(KeyboardEvent.KEY_DOWN, chat_msg_boxOnKeyDownHandler);
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
			connectionNgTimer = new Timer(ConstValues.TIMER_CONNECTION,1);		// コネクションNGタイマー
			connectionNgTimer.addEventListener(TimerEvent.TIMER, connectionNgHandler);	// タイマーイベントを設定
			
			chatTimer = new Timer(ConstValues.TIMER_CHAT,0);		// チャットタイマー
			chatTimer.addEventListener(TimerEvent.TIMER, chatTimerHandler);		// タイマーイベントを設定
			
			userAliveTimer = new Timer(ConstValues.TIMER_USER_ALIVE,0);		// ユーザアライブ
			userAliveTimer.addEventListener(TimerEvent.TIMER, userAliveTimerHandler);	// ユーザアライブ
			
			checkWaitInTimer = new Timer(ConstValues.TIMER_CHECK_WAIT_IN,0);		// 待ち人数チェックタイマー
			checkWaitInTimer.addEventListener(TimerEvent.TIMER, checkWaitInHandler);		// タイマーイベントを設定
			
			waitInTimer = new Timer(ConstValues.TIMER_WAIT_IN,0);		// 待ちタイマー
			waitInTimer.addEventListener(TimerEvent.TIMER, waitInHandler);		// タイマーイベントを設定
			
			payTimer = new Timer(ConstValues.TIMER_PAY,0);		// 一分課金タイマー
			payTimer.addEventListener(TimerEvent.TIMER, payDspPoint);		// タイマーイベントを設定
			
//			likeEndTimer = new Timer(ConstValues.TIMER_LIKE,1);		// LIKEタイマー
//			likeEndTimer.addEventListener(TimerEvent.TIMER, likeEndHandler);	// タイマーイベントを設定
			
			// ボリューム
			view.volume_mic.x = soundVolume * 80 + (view.volume_bar.x -4);
			view.volume_bar.width = 80 * soundVolume;
			
			// 引数：チャット情報読み込み
			initVars();		
			
			// visible
			if (fanclubFlg == "1")
			{
//				view.passwordMenu.visible = true;
//				view.login_menu.visible = false;
//				view.login_menu2.visible = false;
			}
			else
			{
//				view.passwordMenu.visible = false;
//				view.login_menu.visible = true;
//				view.login_menu2.visible = false;
			}
			
			// ql
			
			//msg area style
/*			var t1:TextFormat=new TextFormat();
			t1.font = "MS ゴシック";//"Verdana";
			t1.color = 0x524740; 　
			t1.kerning = true;
			t1.letterSpacing = 1;
			t1.rightMargin = 10;
			t1.leftMargin = 10; 
			
			//msg input style
			t1.leading = 2;
			t1.leftMargin = 3;
			view.chat_msg_box.setStyle("textFormat",t1);			
*/			
			
			loginType = "";
			gotoChat();
			
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
//					view.new_login_menu_btn1.enabled = false;
//					view.new_login_menu_btn2.enabled = false;
//					view.login_menu.new_login_menu_btn1.enabled = false;
//					view.login_menu.new_login_menu_btn2.enabled = false;
					return;
				}else{
//					view.new_login_menu_btn1.enabled = true;
//					view.new_login_menu_btn2.enabled = true;
//					view.login_menu.new_login_menu_btn1.enabled = true;
//					view.login_menu.new_login_menu_btn2.enabled = true;
//					view.loading_bg.visible = false;
//					view.loading_icon.visible = false;
					//				_root.login_btn.enabled = true;
				}
				
				//放送時間セット
				chatStartTime = chatStartTime - 60;
				//				_global.chenge_id1 = setInterval(chatStartTime,1000);
				_chatStartTime = chatStartTime;
				chatTimer.start();
			}
			
			//ページビューカウントアップ
			//				countPageView();	// カウントアップ
			
			//プレゼント表示は画像をロードし終わってからImageLoader で呼び出す。
			//				giftItemSet();		
			
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
			view.volume_mic.enabled = false;
			
			view.mic_off_btn.enabled = false;
			view.mic_on_btn.enabled = true;
			
			// Timer リセット
			if (connectionNgTimer != null)
			{
				connectionNgTimer.reset();	// コネクションNGタイマー
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
			view.volume_mic.enabled = true;

			view.mic_on_btn.enabled = true;
			view.mic_on_btn.visible = true;
			view.mic_off_btn.enabled = false;
			view.mic_off_btn.visible = false;
			
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
			view.volume_mic.enabled = false;
			
		}

		private function gotoChat():void
		{
//ql			getChatInitData();	// チャット初期情報取得
//ql			countPageView();	// カウントアップ
//ql			getUserData();		// 
			_userId = "7777";
			_userName = "テストユーザ";
			_userPoint = 5000;
			
			// ql
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
		
		/**
		 * チャット初期情報取得.
		 * 
		 * <p>CGIを呼んでチャット情報を取得する</p>
		 * 
		 * <ul>
		 * <li>CustomURLLoaderを作成する。</li>
		 * <li>/cast/chat_init_data.cgiを呼ぶ</li>
		 * </ul>
		 * 
		 */
/*		public function getChatInitData():void
		{
			// キャスト初期情報取得
			_loader1 = new CustomURLLoader();
			if (!_loader1.customLoad(true, "http://" + DefineNetConnection.url_web + "/cast/chat_init_data.cgi", _cast_login_id, chatInitDataHandler))
			{
				view.errorMessageBox.errorMess.text = "接続エラーが発生しました。 ERR:1050";
				view.errorMessageBox.visible = true;
			}
			
		}
*/		
		// チャット初期情報取得ハンドラ
/*		private function chatInitDataHandler(event:Event):void
		{
			var castData:String = _loader1.data;
			_loader1=null;
			
			if (castData == "RTN=0")
			{
				view.errorMessageBox.errorMess.text = "チャット情報の取得に失敗しました。";
				view.errorMessageBox.visible = true;
				
				return;
			}
			else
			{
				var rtn:Array;
				rtn = castData.split("RTN=");
				var work:Array;
				work = rtn[1].split("<TAB>");
				
				startTimeSecondCount = work[16];		// スタート秒カウンタ
				if ( (int(startTimeSecondCount)) > 60)
				{
					// 開始から６０秒たった（あたりまえ）
//					getUserData();
				}
				
				keepCategory = work[0];
				keepItemList = work[1];			// ",1,2,3,4,5,6,"
				keepItemEtcName = work[2];
//				keepChatTitle = work[3];
//				view.chatTitle.text = keepChatTitle;
				keepDspPrice = work[4];
				chatStartTime = work[16];
				chatNo = work[17];
				chatViewCount = work[18];
				ngWordList = work[19].split(",");
				
				_castName = work[20];
				fmeFlg = work[21];
//				_cast_id = work[22];
				fanclubFlg = work[23];
				telPrice = work[24];
				
				// プレゼント一時除外
				var buf:Array = new Array();
				buf = keepItemList.split(",6");		// 除外
				keepItemList = buf.join("");		// 
				
				if(chatStartTime < 60)
				{
//					view.new_login_menu_btn1.enabled = false;
//					view.new_login_menu_btn2.enabled = false;
//					view.login_menu.new_login_menu_btn1.enabled = false;
//					view.login_menu.new_login_menu_btn2.enabled = false;
					
					view.currentState = "ChatEnd";
					view.logoutMenu2.visible = true;
					
					return;
				}
				else
				{
//					view.new_login_menu_btn1.enabled = true;
//					view.new_login_menu_btn2.enabled = true;
//					view.login_menu.new_login_menu_btn1.enabled = false;
//					view.login_menu.new_login_menu_btn2.enabled = false;
//					view.loading_bg.visible = false;
//					view.loading_icon.visible = false;
					//				_root.login_btn.enabled = true;
				}
				
				//放送時間セット
				chatStartTime = chatStartTime - 60;
//				_global.chenge_id1 = setInterval(chatStartTime,1000);
				_chatStartTime = chatStartTime;
				chatTimer.start();
				
				//ページビューカウントアップ
//				countPageView();	// カウントアップ
				
				//プレゼント表示は画像をロードし終わってから
				// ImageLoader で呼び出す。
				//				giftItemSet();		
				
			}
		}
*/		
		// ページビューカウントアップ
		private function countPageView():void
		{
			// キャスト初期情報取得
			_loader3 = new CustomURLLoader();
			if (!_loader3.customLoad(true, "http://" + DefineNetConnection.url_web + "/cast/chatview.cgi", chatNo, pageViewHandler))
			{
				view.errorMessageBox.errorMess.text = "ページビュー登録エラー";
				view.errorMessageBox.visible = true;
			}
		}
		
		// ページビューカウントアップハンドラ
		private function pageViewHandler(event:Event):void
		{
			// 何もしていない
		}

		// 
		/**
		 * ユーザー情報取得.
		 * 
		 * <p>CGIを呼んでユーザーデータを取得する。</p>
		 * 
		 * <ul>
		 * <li>CustomURLLoaderを作成する。</li>
		 * <li>/user/userdata.cgiを呼ぶ</li>
		 * </ul>
		 * 
		 */
		public function getUserData():void
		{
			// キャスト初期情報取得
			_loader2 = new CustomURLLoader();
			if (!_loader2.customLoad(true, "http://" + DefineNetConnection.url_web + "/user/userdata.cgi",null,userDataHandler, "point2"))
			{
				view.errorMessageBox.errorMess.text = "接続エラーが発生しました。 ERR:1051";
				view.errorMessageBox.visible = true;
			}
		}
		
		// ユーザ初期情報取得ハンドラ
		private function userDataHandler(event:Event):void
		{
			var userData:String = _loader2.data;
			_loader2=null;
			
			if (userData == "RTN=0")
			{
				view.loginErrMenu.visible = true;
				return;
			}
			else if (userData == "LOGIN:Error")
			{
				view.loginErrMenu.visible = true;
			}
			else
			{
				var rtn:Array;
				rtn = userData.split("RTN=");
				var work:Array;
//				work = userData.split("<TAB>");
				if (rtn[1] != null)
				{
					work = rtn[1].split("<TAB>");
					_userId = work[2];
					_userName = work[1];
					_userPoint = work[0];
					_userAccessCode = work[3];
					
					if (loginType == "OTAMESI")
					{
						getLogin();
					}
					else if (_userPoint > keepDspPrice)
					{
						getLogin();	// チャット開始
					}
					else{
//						view.login_menu.new_login_menu_btn1.enabled = true;
//						view.login_menu.new_login_menu_btn2.enabled = true;
						view.point_err_menu2.visible = true;
					}
				}
			}
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
			view.logout_menu.visible = true;
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
/*		public function chat_send_btnOnClickHandler(event:Event):void
		{
			var _date:Date = new Date();
			var str:String = sendText.replace(/\n/g,"");
			str = str.replace(/\r/g,"");
			
			if (str.length > 0)
			{
				sendText = sendText.replace(/\n/g,"<br>");
				if (_isIconBClicked)
				{
					sendText = "<b>" + sendText + "</b>";
				}
				sendText = sendText + "<br/><br/>"
				_so.send("sendMsg", _userName, _userName+"<br>"+sendText, "USER"+_cast_login_id + ":" + _date.getTime(), _userId, _userName);

				view.chat_msg_box.text="";
				sendText = "";
//				view.chat_msg_box.callLater(clear_chat_msg_box);
			}
		}
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
//				_so.send("sendMsg", "*"+_castName, _castName+"\n"+sendText, "CAST:"+_date.getTime(), "CAST"+_castId, _castName);
				_so.send("sendMsg", _userName, _userName+"<br>"+sendText, "USER"+_cast_login_id + ":" + _date.getTime(), _userId, _userName);
				
				view.chat_msg_box.text="";
				sendText = "";
				//				view.chat_msg_box.callLater(clear_chat_msg_box);
			}
		}
		
		private function clear_chat_msg_box():void
		{
			view.chat_msg_box.text="";
		}
		
		// 
		/**
		 * チャット入力ボックス内でエンターキ.
		 * 
		 * <p>chat_send_btnOnClickHandler()を呼んでチャット書き込み処理を行う。</p>
		 * 
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
		 * 音量OFF.
		 * 
		 * <p>スピーカーボリュームをOFFにする</p>
		 * 
		 */
		public function soundOff():void
		{
			rcv_ns.soundTransform = new SoundTransform(0);
//			view.volume1_btn.enabled = true;
//			view.volume2_btn.enabled = false;
			view.volume_icon_btn.currentState = "off";
			
			view.mic_on_btn.enabled = false;
			view.mic_on_btn.visible = false;
			view.mic_off_btn.enabled = true;
			view.mic_off_btn.visible = true;
			
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
//			view.volume1_btn.enabled = false;
//			view.volume2_btn.enabled = true;
			view.volume_icon_btn.currentState = "on";
			
			view.mic_on_btn.enabled = true;
			view.mic_on_btn.visible = true;
			view.mic_off_btn.enabled = false;
			view.mic_off_btn.visible = false;
		}
		
		/**
		 * ボリュームＯＮボタンクリックハンドラ.
		 * 
		 * <p>soundOn()を呼んでボリュームをONにする</p>
		 * 
		 * @param event 未使用
		 */
		public function volume1_btnOnClickHandler(event:Event):void
		{
			soundOn();
		}
		
		public function mic_on_btnOnClickHandler(event:Event):void
		{
			soundOff();
		}
		
		/**
		 * ボリュームＯＦＦボタンクリックハンドラ.
		 * 
		 * <p>soundOff()を呼んでボリュームをOFFにする</p>
		 * 
		 * @param event 未使用
		 */
		public function volume2_btnOnClickHandler(event:Event):void
		{
			soundOff();
		}
		
		public function mic_off_btnOnClickHandler(event:Event):void
		{
			soundOn();
		}
		
		/**
		 * マイクボリュームドラッグ開始.
		 * 
		 * <p>ドラッグ開始処理を行う</p>
		 * 
		 * @param event 未使用
		 */
		public function volume_micOnMouseDownHandler(event:MouseEvent):void
		{
			_dragActive = true;
			view.volume_mic.startDrag(false,_volumeBounds);
		}
		
		/**
		 * マイクボリュームマウスアップハンドラ.
		 * 
		 * <p>ドラッグ終了処理を行う</p>
		 * 
		 * @param event 未使用
		 */
		public function volume_micOnMouseUpHandler(event:MouseEvent):void
		{
			_dragActive = false;
			view.volume_mic.stopDrag();
		}
		
		/**
		 * マイクボリュームマウスドラッグアウトハンドラ.
		 * 
		 * <p>ドラッグ終了処理を行う</p>
		 * 
		 * @param event 未使用
		 */
		public function volume_micOnMouseOutHandler(event:MouseEvent):void
		{
			_dragActive = false;
			view.volume_mic.stopDrag();
		}
		
		/**
		 * マイクボリュームドラッグ中ハンドラ.
		 * 
		 * <p>ドラッグ中ボリューム設定処理を行う</p>
		 * 
		 * @param event 未使用
		 */
		public function volume_micOnMouseMoveHandler(event:MouseEvent):void 
		{
			if (_dragActive)
			{
				//videoClip.audioVol(425,505,this._x);
//				_micCurrentGain = 80 + view.volume_mic.x - 505;
				soundVolume = (view.volume_mic.x - view.volume_bar.x-4) / 80;
				view.volume_bar.width = 80 * soundVolume;
				
				if (view.volume_icon_btn.currentState == "on")
				{
					rcv_ns.soundTransform = new SoundTransform(soundVolume);
				}
				
			}
		}
		
		/**
		 * プレゼント購入処理.
		 * 
		 * <ul>
		 * <li>/user/pay.cgiを呼んでギフト課金処理を行う。</li>
		 * <li>課金が成功したら、SharedObjectでSENDGIFTメッセージを送る。</li>
		 * </ul>
		 */
		public function giftPayPoint():void
		{
			
			// キャスト初期情報取得
			_loader5 = new CustomURLLoader();
			if (!_loader5.customLoad(true, "http://" + DefineNetConnection.url_web + "/user/pay.cgi",gift_no,giftPayPointHandler, null,null,null,_cast_login_id))
			{
				view.errorMessageBox.errorMess.text = "接続エラーが発生しました。 ERR:1055";
				view.errorMessageBox.visible = true;
			}
			
			// ユーザ初期情報取得ハンドラ
			function giftPayPointHandler(event:Event):void
			{
				var rtn:String = _loader5.data;
				_loader5=null;
				
				if (rtn == "RTN=ERR")
				{
					view.errorMessageBox.errorMess.text = "プレゼント購入時にエラーが発生しました。";
					view.errorMessageBox.visible = true;
					return;
				}
				else
				{
					trace("ギフト課金処理");
					var msg:String = _userName + "\n" + gift_name + "が送られました";
					var getdate:Date = new Date();
					_so.send("sendMsg", "SENDGIFT", msg, "USER" + _cast_login_id + ":" + getdate.getTime(), _userId);
					//				_root.Err_mes("プレゼントを送信しました。");
					
					send_present = true;	// 一度プレゼントを送ったフラグ
					
				}
			}
		}
		
		/**
		 * プレゼント購入処理.
		 * 
		 * <ul>
		 * <li>/user/payGift.cgiを呼んでギフト課金処理を行う。</li>
		 * <li>課金が成功したら、SharedObjectでSENDGIFTメッセージを送る。</li>
		 * </ul>
		 */
		public function giftPayPoint2():void
		{
			
			// キャスト初期情報取得
			_loader5 = new CustomURLLoader();
			if (!_loader5.customLoad(true, "http://" + DefineNetConnection.url_web + "/user/payGift.cgi",gift_no,giftPayPointHandler, null,null,null,_cast_login_id))
			{
				view.errorMessageBox.errorMess.text = "接続エラーが発生しました。 ERR:1056";
				view.errorMessageBox.visible = true;
			}
			
			// ユーザ初期情報取得ハンドラ
			function giftPayPointHandler(event:Event):void
			{
				var rtn:String = _loader5.data;
				_loader5=null;
				
				if (rtn == "RTN=LESSPOINTERROR")
				{
					view.point_err_menu2.visible = true;
					return;
				}
				
				if (rtn == "RTN=ERR")
				{
					view.errorMessageBox.errorMess.text = "プレゼント購入時にエラーが発生しました。";
					view.errorMessageBox.visible = true;
					return;
				}
				else
				{
					trace("ギフト課金処理");
					var msg:String = _userName + "\n" + gift_name + "が送られました";
					var getdate:Date = new Date();
					_so.send("sendMsg", "SENDGIFT", msg, "USER" + _cast_login_id + ":" + getdate.getTime(), _userId);
					//				_root.Err_mes("プレゼントを送信しました。");
					
					send_present = true;	// 一度プレゼントを送ったフラグ
					
				}
			}
			
		}
		
		/**
		 * チャットメッセージチェック処理.
		 * 
		 * <p>チャットメッセージのチェックボックスチェック状態を、
		 * acChatMsgのデータに保存する。</p>
		 * 
		 * @param event 未使用
		 * @param data チェックデータオブジェクト
		 */
/*		public function chatCheck(event:Event, data:Object):void
		{
			var index:int = acChatMsg.getItemIndex(data);
			if (index != -1)
			{
				acChatMsg.source[index].msgCheck = event.target.selected;
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
		public function getLogin():void
		{
			var rtmp:String = "rtmp://" + DefineNetConnection.url_fms + "/cast/" + _cast_login_id;
			var rtmpFme:String = "rtmp://" + DefineNetConnection.url_fms + "/castLive/" + _cast_login_id;
			
			// 配信終了時は繋げない
			if (view.logoutMenu2.visible == true)
			{
				return;
			}
			
			// コネクションを張る
			
			if (fmeFlg == "1")
			{
				// FME用
				_ncFme = new CustomNetConnection(rtmpFme, this.netConnectionStatusHandler_Fme, _cast_login_id, "USER", _userName);
			}
			
			if (loginType == "WAITUSER")
			{
				_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler, _cast_login_id, "WAITUSER", _userName);
			}
			else if (loginType == "WAITUSER_OTAMESI")
			{
				_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler, _cast_login_id, "WAITUSER", _userName, _userId);
				loginType = "OTAMESI";
			}
			else if (loginType == "OTAMESI")
			{
				_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler, _cast_login_id, "OTAMESI", _userName, _userId);
			}
			else
			{
//				_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler, _cast_login_id, "USER", _userName,null,micNum,_userId);
				_nc = new CustomNetConnection(rtmp, this.netConnectionStatusHandler, _cast_login_id, "USER", _userName, null, _userId);
			}
			
			// チャット用データプロバイダ設定
//			view.chat_msg.dataProvider = acChatMsg;
//			view.chat_msg.dataProvider = msgText;
			
			// 禁止ワード用データプロバイダ設定
//			view.ngword_msg.dataProvider = acNgword;
			
			view.chat_send_btn.visible = true;
			
		}
		
		/**
		 * ユーザ待機処理.
		 * 
		 * <p>満員時のユーザ待機処理</p>
		 * <ul>
		 * <li>現在のNetConnectionをcloseする。</li>
		 * <li>ログインタイプがOTAMESIお試し中なら、ユーザIDをWAIT_OTAMESIとして新しいNetConnectionを作成して接続。</li>
		 * <li>お試し中でないなら、ユーザIDをWAITとして新しいNetConnectionを作成して接続。</li>
		 * </ul>
		 */
		public function waitUser():void
		{
			var rtmp:String = "rtmp://" + DefineNetConnection.url_fms + "/cast/" + _cast_login_id;
			var rtmpFme:String = "rtmp://" + DefineNetConnection.url_fms + "/castLive/" + _cast_login_id;

			_nc.close();
			_nc = null;
			if (_ncFme != null)
			{
				_ncFme.close();
			}
			if(loginType == "OTAMESI")
			{
				_nc_wait = new CustomNetConnection(rtmp, this.netConnectionStatusHandler_wait, _cast_login_id, "WAIT_OTAMESI", _userName);
			}else{
				_nc_wait = new CustomNetConnection(rtmp, this.netConnectionStatusHandler_wait, _cast_login_id, "WAIT", _userName);
			}
		}

		/**
		 * 待機時ネットステータスハンドラ.
		 * 
		 * <p>接続できたら、待ち人数チェックタイマーをスタートする。</p>
		 * 
		 * @param e NetStatusEvent
		 */
		public function netConnectionStatusHandler_wait(e:NetStatusEvent):void
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					checkWaitInTimer.start();				// チェックタイマースタート
					break;
				case "NetConnection.Connect.Rejected":
					view.errorMessageBox.errorMess.text = "現在サーバーが混雑しています。少し時間を置いてから再度接続を試みて下さい。";
					view.errorMessageBox.visible = true;
					break;
			}
		}
		
		/**
		 * 待機人数設定.
		 * 
		 * <p>現在の待ち人数をアラート表示する。</p>
		 * 
		 * @param dat1 待ち人数
		 */
		public function rtnWaitUserCount(dat1:Number):void
		{
			
			if(loginType == "OTAMESI")
			{
				view.wait_menu_2.mess.text = "無料お試し視聴は現在" + dat1 + "人待ちです";
				view.wait_menu_2.send_no.visible = false;
				view.wait_menu_2.send_yes.visible = false;
				view.wait_menu_2.muryoEnterBtn.visible = true;
				view.wait_menu_2.wait2_no_btn.visible = true;
				view.wait_menu_2.mess.x = 4;
				view.wait_menu_2.mess.y = 14;
				view.wait_menu_2.send_yes.x = 35;
				view.wait_menu_2.send_yes.y = 65;
				view.wait_menu_2.wait2_no_btn.x = 112;
				view.wait_menu_2.wait2_no_btn.y = 65;
				view.wait_menu_2.x = 300;
				view.wait_menu_2.y = 200;
			}
			else
			{
				view.wait_menu_2.mess.text = "現在" + dat1 + "人待ちです";
				view.wait_menu_2.send_no.visible = false;
				view.wait_menu_2.send_yes.visible = false;
				view.wait_menu_2.muryoEnterBtn.visible = false;
				view.wait_menu_2.wait2_no_btn.visible = true;
				view.wait_menu_2.mess.x = 4;
				view.wait_menu_2.mess.y = 54;
				view.wait_menu_2.send_yes.x = 35;
				view.wait_menu_2.send_yes.y = 115;
				view.wait_menu_2.wait2_no_btn.x = 112;
				view.wait_menu_2.wait2_no_btn.y = 115;
				view.wait_menu_2.x = 300;
				view.wait_menu_2.y = 200;
			}
			view.wait_menu_2.visible = true;
		}
		
		/**
		 * 待機タイマーハンドラ.
		 * 
		 * <p>待機解除のポップアップなどで一定時間が過ぎたらトップページに強制的に飛ぶようにする。</p>
		 * 
		 * @param e 未使用
		 */
		public function waitInHandler(e:Event):void
		{
			_nc_wait.close();
			mx.core.FlexGlobals.topLevelApplication.currentState='ChatEnd';
			navigateToURL( new URLRequest( encodeURI("http://" + DefineNetConnection.url_web + "/index.cgi")), "_self");
			view.wait_menu_1.visible = false;
		}
		
		/**
		 * 再ログイン呼出し処理.
		 */
		public function callWaitReLogin():void
		{
			waitInTimer.reset();
			_nc_wait.call("WaitReLogin",null);
		}
		
		/**
		 * 再ログイン処理.
		 */
		public function waitReLogin():void
		{
			_nc_wait.close();
			if(loginType == "OTAMESI")
			{
				loginType = "WAITUSER_OTAMESI";
			}
			else
			{
				loginType = "WAITUSER";
			}
			getLogin();
		}
		
		/**
		 * 待ち人数チェックタイマーハンドラ.
		 * 
		 * <p>FMSのCheckWaitIn()を呼んで待ち人数のチェックを行う。</p>
		 * 
		 * @param e
		 */
		public function checkWaitInHandler(e:Event):void
		{
			_nc_wait.call("CheckWaitIn",null);		// オフライン
		}
		
		/**
		 * 高画質用ネットコネクションステータスハンドラ.
		 * 
		 * @param e NetStatusEvent
		 */
		public function netConnectionStatusHandler_Fme(e:NetStatusEvent):void 
		{
			trace(e.info.code);
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success":
					receiveVideo(_ncFme);		// 通常受信
					break;
				case "NetStream.Play.StreamNotFound":
					//					trace("Stream not found: " + videoURL);
					break;
			}
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
						view.wait_menu_1.visible = true;
					}
					else if (e.info.application.message == "MAXUSER_100")
					{
						if (loginType == "OTAMESI")
						{
							view.wait_menu_10.visible = true;
						}
						else
						{
							view.wait_menu_9.visible = true;
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
					_so4 = _nc.getSo("statsTxt"+_cast_login_id, so4SyncEventHandler);		// チャットSO
					// 動画スタート
					connectStream();
					// 課金処理開始
					keep_Otamesi_Count = 0;
//ql					payDspPoint(null);
//ql					payTimer.start();

					// 接続チェックタイマースタート
//ql					userAliveTimer.start();				//Timerを動かす
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
		
		/**
		 * 一分課金ハンドラ.
		 * 
		 * <p>課金後、FMEから呼ばれる。残りポイント数から警告アラートを表示する。</p>
		 * 
		 * @param data 残ポイント数
		 */
		public function checkPoint(data:String):void
		{
			_userPoint = int(data);
			
			if (data != "ERR")
			{
				// ポイント現象警告
				if(( int(data) > (keepDspPrice * 9))&&( int(data) <= (keepDspPrice * 10)))
				{
					view.errorMessageBox.errorMess.text = "残り10分でアメPが不足します。";
					view.errorMessageBox.visible = true;
				}
				else if(( int(data) > (keepDspPrice * 4))&&( int(data) <= (keepDspPrice * 5)))
				{
					view.errorMessageBox.errorMess.text = "残り5分でアメPが不足します。";
					view.errorMessageBox.visible = true;
				}
				else if(( int(data) > (keepDspPrice * 3))&&( int(data) <= (keepDspPrice * 4)))
				{
					view.errorMessageBox.errorMess.text = "残り4分でアメPが不足します。";
					view.errorMessageBox.visible = true;
				}
				else if(( int(data) > (keepDspPrice * 2))&&( int(data) <= (keepDspPrice * 3)))
				{
					view.errorMessageBox.errorMess.text = "残り3分でアメPが不足します。";
					view.errorMessageBox.visible = true;
				}
				else if(( int(data) > (keepDspPrice * 1))&&( int(data) <= (keepDspPrice * 2)))
				{
					view.errorMessageBox.errorMess.text = "残り2分でアメPが不足します。";
					view.errorMessageBox.visible = true;
				}
				else if(( int(data) > (keepDspPrice * 0))&&( int(data) <= (keepDspPrice * 1)))
				{
					view.errorMessageBox.errorMess.text = "残り1分でアメPが不足します。";
					view.errorMessageBox.visible = true;
				}
				
				// 生電話参加ポイントボタン
				if (int(data) < telPrice)
				{
//					view.telInfo.logic.selectPayBtnEnabled(false);
				}
				else
				{
//					view.telInfo.logic.selectPayBtnEnabled(true);
				}
				
			}
			else
			{
				view.point_err_menu2.visible = true;
				view.currentState = "ChatEnd";
			}
		}
		// コネクト
		private function connectStream():void
		{
			// テキスト用 SharedObject
			_so = _nc.getSo("ourText"+_cast_login_id, soSyncEventHandler);	// チャットSO
			_nc.setSendMsgHandler(sendMsgHanler);		// SO 送信ハンドラ
			
			if (fmeFlg == "1")
			{
//				receiveVideo(_ncFme);		// 通常受信
			}
			else
			{
				receiveVideo(_nc);		// FME受信
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
				if (loginType == "OTAMESI")
				{
					msg = _userName + "\nお試し中\n";
				}
				else
				{
					msg = _userName + "さんが\n入室されました。\n\n";
				}
				var _date:Date = new Date();
				_so.send("sendMsg", "USER_LOGIN", msg, "CAST" + _cast_login_id + ":" + _date.getTime(),"CAST" );
				
				
				if (_so.data.kickOuts != null)
				{
					acKickUsers = _so.data.kickOuts;
					for(var i:int = 0; i < acKickUsers.length; i++)
					{
						var obj:Object = acKickUsers.getItemAt(i);
						if ( obj.userId == _userId)
						{
							_kickOutCount = obj.count;
						}
					}
				}
			}
		}
		
		private function userAliveTimerHandler(e:Event):void
		{
			_nc.call("TimerResetCount",null);		// オフライン
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

		// ビデオ受信
		private function receiveVideo(nc:CustomNetConnection):void
		{
			rcv_ns = new NetStream(nc);
			rcv_ns.addEventListener(NetStatusEvent.NET_STATUS, receiveNetStreamStatusEventHandler);
			rcv_ns.client = this;
			rcv_ns.bufferTime = 1;
			rcv_ns.play("cast"+_cast_login_id);
			
			rcv_video = new Video();
			rcv_video.width = ConstValues.CAMERA_WIDTH;
			rcv_video.height = ConstValues.CAMERA_HEIGHT;
			rcv_video.attachNetStream(rcv_ns);
			
			
			view.receive_video.addChild(rcv_video as DisplayObject);

			rcv_ns.soundTransform = new SoundTransform(soundVolume);
			
			view.volume_mic.x = soundVolume * 80 + (view.volume_bar.x - 4);
			view.volume_bar.width = 80 * soundVolume;

			
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
		 * ６０秒後もまだ配信していない
		 **/
		private function connectionNgHandler(event:Event):void
		{
/*			if (theCamera.activityLevel == -1)
			{
				view.errorMessageBox.errorMess.text = "ビデオを取得できませんでした。";
				view.errorMessageBox.visible = true;
				
				_nc.call("CastOFF",null);		// オフライン
				
			}
*/		}
		
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

//			debugOut1(JobType + ":" + UserId + ":" + UserName + ":" + ExUserIds);		// デバッグ
			
			switch (JobType)
			{
				case "SEND_NGWORD":
					return;
				case "NGWORD":
					return;
				case "USER_LOGIN":
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
//				msg = replaceNgword(msg);
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
		
		//--------------------------------------
		// View-Logic Binding
		//--------------------------------------
		
		/** 画面 */
		public var _view:user_uni;
		
		/**
		 * 画面を取得します
		 */
		public function get view():user_uni
		{
			if (_view == null)
			{
				_view = super.document as user_uni;
			}
			return _view;
		}
		
		/**
		 * 画面をセットします。
		 *
		 * @param view セットする画面
		 */
		public function set view(view:user_uni):void
		{
			_view = view;
		}
		
	}
}