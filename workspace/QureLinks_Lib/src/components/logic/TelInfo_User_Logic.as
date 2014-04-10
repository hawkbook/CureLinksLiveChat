package components.logic
{
	import components.TelInfo_User;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import logic.Logic2;
	import logic.config.ConstValues;
	import logic.config.DefineNetConnection;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.filters.*;
	import logic.config.ConstValues;
	import logic.config.DefineNetConnection;
	
	/**
	 * ユーザー生電話コンポーネントロジッククラス.
	 * 
	 * @author bullet
	 */
	public class TelInfo_User_Logic extends Logic2
	{
		
		/**
		 * 有料・無料の選択モード保存用.
		 */
		public var selectMode:String;
		private var waitFreeTimer:Timer;
		private var waitPayTimer:Timer;
		private var waitCallTimer:Timer;
		private var waitSpeakTimer:Timer;
		private var telTimer:Timer;		// 生電話時間のカウンタタイマー
		
		/**
		 * 生電話時間カウンター値バインド変数.
		 * @default 60秒
		 */
		[Bindable]
		public var telTimeValue:int = ConstValues.COUNTER_TEL;
		
		/**
		 * 有料エントリーボタンイネーブル／ディセーブルバインド変数.
		 * @default true
		 */
		[Bindable]
		public var enabledBind:Boolean = true;
		
		/**
		 * 有料エントリーボタン文言バインド変数.
		 * @default ""
		 */
		[Bindable]
		public var btnLabelBind:String = "";
		/**
		 * 生電話メッセージ用バインド変数.
		 * @default なし
		 */
		[Bindable]
		public var messBind:String;			// メッセージ
		
		/**
		 * 画面が生成された後の初期化処理オーバーライド.
		 * 
		 * <p>Logic2スーパークラスの関数をオーバーライドし、以下の処理を行う。</p>
		 * <ul>
		 * <li>初期の画面ステートとして"default"を設定する。</li>
		 * <li>無料当選→呼出し開始のウェイトタイマー初期化</li>
		 * <li>有料当選→呼出し開始のウェイトタイマー初期化</li>
		 * <li>呼出し開始→呼出し中のウェイトタイマー初期化</li>
		 * <li>呼出し中→会話開始のウェイトタイマー初期化</li>
		 * <li>会話タイマー初期化</li>
		 * </ul>
		 * @param event FlexEvent
		 */
		override protected function onCreationCompleteHandler(event:FlexEvent):void
		{
			view.currentState = "default";
			waitFreeTimer = new Timer(1500,1);		// 
			waitFreeTimer.addEventListener(TimerEvent.TIMER, waitFreeTimerHandler);		// 無料当選→呼出し開始のウェイトタイマー
			waitPayTimer = new Timer(1500,1);		// 
			waitPayTimer.addEventListener(TimerEvent.TIMER, waitPayTimerHandler);		// 有料当選→呼出し開始のウェイトタイマー
			waitCallTimer = new Timer(3000,1);		// 
			waitCallTimer.addEventListener(TimerEvent.TIMER, waitCallTimerHandler);		// 呼出し開始→呼出し中のウェイトタイマー
			waitSpeakTimer = new Timer(1000,1);		// 
			waitSpeakTimer.addEventListener(TimerEvent.TIMER, waitSpeakTimerHandler);	// 呼出し中→会話開始のウェイトタイマー
			
			telTimer = new Timer(ConstValues.TIMER_TEL,0);					// 生電話タイマー
			telTimer.addEventListener(TimerEvent.TIMER, telTimerHandler);	// 生電話タイマーイベントを設定
			
		}
		
		// 生電話タイマーハンドラ
		private function telTimerHandler(e:Event):void
		{
			telTimeValue--;
			//				this.countMess.text = telTimeValue.toString();
			
			if (telTimeValue == 0)
			{
				telTimer.reset();
			}
		}
		
		/**
		 * ステートをデフォルトに設定.
		 * 
		 * <p>画面ステートを"default"に設定する。</p>
		 */
		public function defaultStart():void
		{
			view.currentState = "default";
		}
		
		/**
		 * デフォルトステート検証.
		 * 
		 * <p>現在の画面ステートが"default"であるかどうかを判断する。</p>
		 * 
		 * @return true=default, false=その他
		 */
		public function isDefaultState():Boolean
		{
			if(view.currentState == "default")
			{
				return true;
			}
			return false;
		}
		
		/**
		 * エントリー開始処理.
		 * 
		 * <p>エントリーを開始する</p>
		 * 
		 * @param price 有料時の単価
		 */
		public function entryStart(price:int):void
		{
			this.btnLabelBind = price.toString();
			selectMode = "";	// クリア
			view.currentState = "EntryStart";
		}
		
		/**
		 * 抽選中止処理.
		 * 
		 * <p>画面ステートを"SelectStop"に設定する。</p>
		 */
		public function selectStop():void
		{
			view.currentState = "SelectStop";
		}
		
		/**
		 * エントリーNG処理.
		 * 
		 * <p>画面ステートを"EntryNg"に設定する。</p>
		 */
		public function setEntryNg():void
		{
			view.currentState = "EntryNg";
		}
		
		/**
		 * はい（無料）ボタンクリックハンドラ.
		 * 
		 * <p>エントリー画面の「はい（無料）」ボタンをクリックしたときの処理</p>
		 * <ul>
		 * <li>selectStartYesFree()を呼んで無料エントリー処理を行う。</li>
		 * <li>ステータスを"EntryFree"にする</li>
		 * </ul>
		 * @param e イベントオブジェクト：使用していない
		 */
		public function selectYesFreeBtnOnClickHandler(e:Event=null):void
		{
			if (mx.core.FlexGlobals.topLevelApplication.logic.selectStartYesFree())
			{
				selectMode = "Free";
				view.currentState = "EntryFree";
			}
		}
		
		/**
		 * はい（有料）ボタンクリックハンドラ.
		 * 
		 * <p>エントリー画面の「はい（有料）」ボタンをクリックしたときの処理</p>
		 * <ul>
		 * <li>selectStartYesPay()を呼んで有料エントリー処理を行う。</li>
		 * <li>ステータスを"EntryPay"にする</li>
		 * </ul>
		 * @param e イベントオブジェクト：使用していない
		 */
		public function selectYesPayBtnOnClickHandler(e:Event=null):void
		{
			if (mx.core.FlexGlobals.topLevelApplication.logic.selectStartYesPay())
			{
				selectMode = "Pay";
				view.currentState = "EntryPay";
			}
		}
		
		/**
		 * いいえボタンクリックハンドラ.
		 * 
		 * <p>エントリー画面の「いいえ」ボタンをクリックしたときの処理</p>
		 * <ul>
		 * <li>selectStartNo()を呼んでエントリーしない処理を行う。</li>
		 * <li>ステータスを"EntryNo"にする</li>
		 * </ul>
		 * @param e イベントオブジェクト：使用していない
		 */
		public function selectNoBtnOnClickHandler(e:Event=null):void
		{
			selectMode = "No";
			mx.core.FlexGlobals.topLevelApplication.logic.selectStartNo();
			view.currentState = "EntryNo";
		}
		
		/**
		 * 当選スロットスタート処理.
		 * 
		 * <p>当選用スロットをスタートさせる。</p>
		 * <ul>
		 * <li>画面ステートを"Selecting"にする。</li>
		 * <li>当選スロットアニメーションをスタートする。</li>
		 * </ul>
		 */
		public function slotStart_Selected():void
		{
			view.currentState = "Selecting";
			view.slot_ok.end();
			view.slot_ok.play();
		}
		
		/**
		 * 落選スロットスタート処理.
		 * 
		 * <p>落選用スロットをスタートさせる。</p>
		 * <ul>
		 * <li>画面ステートを"Selecting"にする。</li>
		 * <li>落選スロットアニメーションをスタートする。</li>
		 * </ul>
		 */
		public function slotStart_Ng():void
		{
			view.currentState = "Selecting";
			view.slot_ng.end();
			view.slot_ng.play();
		}
		
		/**
		 * 当選スロット終了処理.
		 * 
		 * <p>有料の時</p>
		 * <ul>
		 * <li>画面ステータスを"Selected_Pay"にする</li>
		 * <li>selectedPay()を呼んで有料当選処理を行う</li>
		 * <li>当選→呼出し開始タイマーを起動する</li>
		 * </ul>
		 * <p>無料の時</p>
		 * <ul>
		 * <li>画面ステータスを"Selected_Free"にする</li>
		 * <li>selectedFree()を呼んで有料当選処理を行う</li>
		 * <li>当選→呼出し開始タイマーを起動する</li>
		 * </ul>
		 * 
		 */
		public function slotEnd_Selected():void
		{
			switch (selectMode)
			{
				case "Pay":
					view.currentState = "Selected_Pay";
					mx.core.FlexGlobals.topLevelApplication.logic.selectedPay();
					waitPayTimer.start();	// 当選→電話タイマー
					break;
				case "Free":
				default:
					view.currentState = "Selected_Free";
					mx.core.FlexGlobals.topLevelApplication.logic.selectedFree();
					waitFreeTimer.start();	// 当選→電話タイマー
					break;
			}
		}
		
		/**
		 * 落選表示.
		 * 
		 * <p>画面ステートを"Selected_Out"にする。</p>
		 */
		public function slotEnd_Ng():void
		{
			view.currentState = "Selected_Out";
		}
		
		// 当選→電話ボタン表示タイマータイムアウト（無料）
		private function waitFreeTimerHandler(e:Event):void
		{
			view.currentState = "CallStart_Free";
			waitCallTimer.start();
		}
		
		// 当選→電話ボタン表示タイマータイムアウト（有料）
		private function waitPayTimerHandler(e:Event):void
		{
			view.currentState = "CallStart_Pay";
			waitCallTimer.start();
		}
		
		// 電話ボタン表示→電話タイマータイムアウト（有料）
		private function waitCallTimerHandler(e:Event):void
		{
			if ((view.currentState == "CallStart_Free") ||
				(view.currentState == "CallStart_Pay"))
			{
				callStartBtnOnClickHandler();		// 通話開始
			}
		}
		
		/**
		 * 呼び出しボタンクリック処理.
		 * 
		 * <p>当選後、電話呼び出しアイコンをクリックしたときの処理。</p>
		 * <ul>
		 * <li>画面ステートを、有料ならば"Calling_Pay"、無料ならば"Calling_Free"にする。</li>
		 * <li>callingStart()を呼んで呼出しをスタートする。</li>
		 * </ul>
		 * @param e
		 */
		public function callStartBtnOnClickHandler(e:Event=null):void
		{
			if (selectMode == "Free")
			{
				view.currentState = "Calling_Free";
			}
			else
			{
				view.currentState = "Calling_Pay";
			}
			mx.core.FlexGlobals.topLevelApplication.logic.callingStart(selectMode);
			waitSpeakTimer.start();
			view.callFilter.end();
			view.callFilter.play();
		}
		
		// 呼び出し中タイマータイムアウト
		private function waitSpeakTimerHandler(e:Event):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.callStart(selectMode);
		}
		
		/**
		 * 無料会話スタート処理.
		 * 
		 * <p>生電話無料会話開始処理。</p>
		 * <ul>
		 * <li>タイマーを60秒に設定</li>
		 * <li>画面ステートを"Speaking_Free"に設定</li>
		 * <li>会話中グローフィルター開始</li>
		 * </ul>
		 */
		public function speakingFree():void
		{
			telTimeValue = ConstValues.COUNTER_TEL;
			telTimer.start();
			view.currentState = "Speaking_Free";
			view.speakFilter.end();
			view.speakFilter.play();
		}
		
		/**
		 * 有料会話スタート処理.
		 * 
		 * <p>生電話有料会話開始処理。</p>
		 * <ul>
		 * <li>タイマーを60秒に設定</li>
		 * <li>画面ステートを"Speaking_Pay"に設定</li>
		 * <li>会話中グローフィルター開始</li>
		 * </ul>
		 */
		public function speakingPay():void
		{
			telTimeValue = ConstValues.COUNTER_TEL;
			telTimer.start();
			view.currentState = "Speaking_Pay";
			view.speakFilter.end();
			view.speakFilter.play();
		}
		
		/**
		 * 生電話聴取（無料）開始処理.
		 * 
		 * <ul>
		 * <li>電話タイマーを60秒に設定してスタート</li>
		 * <li>～さんが生電話中です。とメッセージに表示</li>
		 * <li>画面ステートを"Hearing_Free"に設定</li>
		 * <li>生電話中グローフィルタを開始</li>
		 * </ul>
		 * 
		 * @param id 当選者ID
		 * @param name 当選者名
		 */
		public function hearingFree(id:String, name:String):void
		{
			telTimeValue = ConstValues.COUNTER_TEL;
			telTimer.start();		// タイマースタート
			var userName:String = name;
			if (userName.length > 8)
			{
				userName = userName.substr(0,7) + "…";
			}
			messBind = userName + "さんが生電話中です。";
			view.currentState = "Hearing_Free";
			view.speakFilter.end();
			view.speakFilter.play();
		}
		
		/**
		 * 生電話聴取（有料）開始処理.
		 * 
		 * <ul>
		 * <li>電話タイマーを60秒に設定してスタート</li>
		 * <li>～さんが生電話中です。とメッセージに表示</li>
		 * <li>画面ステートを"Hearing_Pay"に設定</li>
		 * <li>生電話中グローフィルタを開始</li>
		 * </ul>
		 * 
		 * @param id 当選者ID
		 * @param name 当選者名
		 */
		public function hearingPay(id:String, name:String):void
		{
			telTimeValue = ConstValues.COUNTER_TEL;
			telTimer.start();		// タイマースタート
			var userName:String = name;
			if (userName.length > 8)
			{
				userName = userName.substr(0,7) + "…";
			}
			messBind = userName + "さんが生電話中です。";
			view.currentState = "Hearing_Pay";
			view.speakFilter.end();
			view.speakFilter.play();
		}
		
		/**
		 * 画面ステートが"SelectStop"であるか.
		 * 
		 * <p>現在の画面ステートが"SelectStop"抽選中止であればtrue、
		 * そうでなければ、falseを返す。</p>
		 * 
		 * @return true=SelectStop、false=その他
		 */
		public function isSelectStop():Boolean
		{
			if (view.currentState == "SelectStop")
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 有料エントリーボタンイネーブル／ディセーブル.
		 * 
		 * <p>引数のBoolean値を有料エントリーボタンのenabledプロパティに設定する</p>
		 * 
		 * @param enabled 設定する値
		 */
		public function selectPayBtnEnabled(enabled:Boolean):void
		{
			enabledBind = enabled;
		}
		
		/**
		 * マイク接続説明ボタンクリックハンドラ.
		 * 
		 * <p>detailWindowOpen()を呼んで、別ウインドウでマイク接続ページを開く</p>
		 * 
		 * @param e
		 */
		public function detailBtnOnClickHandler(e:Event=null):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.detailWindowOpen();
		}

		//--------------------------------------
		// View-Logic Binding
		//--------------------------------------
		/** 画面 */
		public var _view:TelInfo_User;
		
		/**
		 * 画面を取得します
		 */
		public function get view():TelInfo_User
		{
			if (_view == null)
			{
				_view = super.document as TelInfo_User;
			}
			return _view;
		}
		
		/**
		 * 画面をセットします。
		 *
		 * @param view セットする画面
		 */
		public function set view(view:TelInfo_User):void
		{
			_view = view;
		}
		
	}
}