package components.logic
{
	import components.TelInfo_Qa;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import logic.Logic2;
	import logic.config.ConstValues;
	import logic.config.DefineNetConnection;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.filters.*;

	/**
	 * キャスト生電話コンポーネントロジッククラス.
	 * 
	 * @author bullet
	 */
	public class TelInfo_Qa_Logic extends Logic2
	{
		
		private var savedTelState:String;
		private var telTimer:Timer;		// 生電話時間のタイマー
		
		/**
		 * 生電話時間カウンター値バインド変数.
		 * @default 60秒
		 */
		[Bindable]
		public var telTimeValue:int = ConstValues.COUNTER_TEL;		// 90 
		
		/**
		 * 生電話メッセージ用バインド変数.
		 * @default 
		 */
		[Bindable]
		public var messBind:String;
		
		/**
		 * 生電話サブメッセージ用バインド変数.
		 * @default 
		 */
		[Bindable]
		public var messSubBind:String;
		
		/**
		 * 抽選開始時メッセージ用バインド変数.
		 * @default 
		 */
		[Bindable]
		public var messSelectStartBind:String;
		
		/**
		 * エントリー終了ボタンイネーブル／ディセーブルバインド変数
		 * @default 
		 */
		[Bindable]
		public var enabledSelectStartBind:Boolean=true;
		
		/**
		 * 画面が生成された後の初期化処理オーバーライド.
		 * 
		 * <p>Logic2スーパークラスの関数をオーバーライドし、以下の処理を行う。
		 * <li>SWF起動時パラメータのログインIDをキャストIDとしてを読み込む。</li>
		 * <li>SWF起動時パラメータのチャットタイトルを読み込んで表示する</li>
		 * <li>アンケートの質問開始ボタンを可視化する</li>
		 * </p>
		 * @param event FlexEvent
		 */
		override protected function onCreationCompleteHandler(event:FlexEvent):void
		{
			view.currentState = "EntryStart";
			savedTelState = "EntryStart";
//			view.selectStartBtn.enabled = false;
			
//			this.messSelectStartBind = "マイク利用ユーザがいません";
			this.messSelectStartBind = "エントリーユーザがいません";
			
			telTimer = new Timer(ConstValues.TIMER_TEL,0);					// 生電話タイマー
			telTimer.addEventListener(TimerEvent.TIMER, telTimerHandler);	// 生電話タイマーイベントを設定
		}
		
		/**
		 * マイク数設定.
		 * <p>引数で与えられるマイク数をメッセージに表示する。</p>
		 * @param c マイク数
		 */
		public function setMicCount(c:int):void
		{
			if (c == 0)
			{
//				this.messSelectStartBind = "マイク利用ユーザーがいません";
				this.messSelectStartBind = "エントリーユーザがいません";
//				view.selectStartBtn.enabled = false;
				
			}
			else
			{
				this.messSelectStartBind = c.toString() + "名のユーザーが生電話に参加できます";
//				view.selectStartBtn.enabled = true;
			}
		}
		
		/**
		 * 抽選開始画面設定.
		 * 
		 * <p>画面ステータスをSelectStartに設定する。</p>
		 */
		public function setSelectStart():void
		{
			view.currentState = "SelectStart";
		}
		
		/**
		 * エントリー開始画面設定.
		 * 
		 * <p>画面ステータスをEntryStartに設定する。</p>
		 */
		public function setEntryStart():void
		{
			view.currentState = "EntryStart";
		}
		
		// 生電話タイマーハンドラ
		private function telTimerHandler(e:Event):void
		{
			telTimeValue--;
			
			if (telTimeValue == 0)
			{
				this.speakEndBtnOnClickHandler();
			}
		}
		
		/**
		 * 生電話会話終了ボタンクリックハンドラ.
		 * 
		 * <ul>
		 * <li>生電話タイマーをリセット</li>
		 * <li>telEnd()を呼んで生電話終了処理を行う。</li>
		 * <li>生電話中グローフィルターを停止。</li>
		 * </ul>
		 * 
		 * @param event イベントオブジェクト 未使用。
		 */
		public function speakEndBtnOnClickHandler(event:Event=null):void
		{
			telTimer.reset();		// ６０秒タイマーリセット
			mx.core.FlexGlobals.topLevelApplication.logic.telEnd();
			//				this.currentState = "SelectStart";
			view.speakFilter.stop();
		}
		
		/**
		 * 追放ボタンクリックハンドラ.
		 * 
		 * <ul>
		 * <li>telKickOut()を呼んで追放処理を行う。</li>
		 * <li>画面ステータスを"EntryStart"に設定</li>
		 * <li>生電話中グローフィルターを停止。</li>
		 * </ul>
		 * 
		 * @param event イベントオブジェクト 未使用。
		 */
		public function kickOutBtnOnClickHandler(event:Event=null):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.telKickOut();
			view.currentState = "EntryStart";
			view.selectFilter.stop();
		}
		
		/**
		 * 抽選開始（エントリー終了）ボタンクリックハンドラ.
		 * 
		 * <ul>
		 * <li>slotStart()を呼んで抽選処理を開始する</li>
		 * <li>ただいま抽選中と表示する</li>
		 * <li>画面ステータスを"Selecting"に設定</li>
		 * <li>抽選中グローフィルター開始</li>
		 * </ul>
		 * 
		 * @param event イベントオブジェクト 未使用。
		 */
		public function selectStartBtnOnClickHandler(event:Event=null):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.slotStart();
			this.messBind = "ただいま抽選中";
			view.currentState = "Selecting";
			view.selectFilter.end();
			view.selectFilter.play();
		}
		
		/**
		 * エントリー中止ボタンクリックハンドラ.
		 * 
		 * <ul>
		 * <li>entryStop()を呼んで抽選中止処理を行う</li>
		 * <li>画面ステータスを"EntryStart"に設定</li>
		 * </ul>
		 * 
		 * @param event イベントオブジェクト 未使用。
		 */
		public function entryStopBtnOnClickHandler(event:Event=null):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.entryStop();
			view.currentState = "EntryStart";
		}
		
		/**
		 * 生電話エントリー開始ボタンクリックハンドラ.
		 * 
		 * <ul>
		 * <li>画面ステータスを"SelectStart"に設定</li>
		 * <li>entryStart()を呼んで抽選開始処理を行う</li>
		 * </ul>
		 * 
		 * @param event イベントオブジェクト 未使用。
		 */
		public function entryStartBtnOnClickHandler(event:Event=null):void
		{
			view.currentState = "SelectStart";
			mx.core.FlexGlobals.topLevelApplication.logic.entryStart();
		}
		
		/**
		 * 生電話タブボタンクリックハンドラ.
		 * 
		 * <p>画面ステートに保存しておいた生電話の画面ステートを設定する。</p>
		 * 
		 * @param e イベントオブジェクト 未使用。
		 */
		public function liveTelTabBtnOnClickHandler(e:Event):void
		{
			view.currentState = savedTelState;
		}
		
		/**
		 * アンケートタブボタンクリックハンドラ.
		 * 
		 * <p>現在の画面ステートが生電話のステートなら、
		 * 現在の画面ステートを保存して、画面ステートを
		 * "QAState"（アンケート）に設定する。</p>
		 * 
		 * @param e イベントオブジェクト 未使用。
		 */
		public function qaTabBtnOnClickHandler(e:Event):void
		{
			if (view.currentState != "QAState")
			{
				savedTelState = view.currentState;
				view.currentState = "QAState";
			}
		}
		
		/**
		 * アンケート開始ボタンクリックハンドラ.
		 * 
		 * <p>ロジッククラスのcastQaBtnOnClickHandler()を呼んでアンケート開始処理を行う。</p>
		 * 
		 * @param e イベントオブジェクト 未使用。
		 */
		public function castQaBtnOnClickHandler(e:Event):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.castQaBtnOnClickHandler();
		}
		
		/**
		 * アンケート結果表示ボタンクリックハンドラ.
		 * 
		 * <p>ロジッククラスのcastQaResultBtnOnClickHandler()を呼んで
		 * アンケート結果の表示処理を行う。</p>
		 * 
		 * @param e イベントオブジェクト 未使用。
		 */
		public function castQaResultBtnOnClickHandler(e:Event):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.castQaResultBtnOnClickHandler();
		}
		
		/**
		 * アンケート結果削除ボタンクリックハンドラ.
		 * 
		 * <p>ロジッククラスのcastQaResultDeleteBtnOnClickHandler()を呼んで
		 * アンケート結果の削除処理を行う。</p>
		 * 
		 * @param e イベントオブジェクト 未使用。
		 */
		public function castQaResultDeleteBtnOnClickHandler(e:Event):void
		{
			mx.core.FlexGlobals.topLevelApplication.logic.castQaResultDeleteBtnOnClickHandler();
		}
		
		/**
		 * 当選（無料）処理.
		 * 
		 * <ul>
		 * <li>画面ステートを"Selected_Free"にする</li>
		 * <li>～さんが当選！とメッセージに表示</li>
		 * <li>～さんの声は他のユーザーに聞こえていますと吹き出しに表示</li>
		 * </ul>
		 * 
		 * @param userId 当選ユーザID
		 * @param userName 当選ユーザ名
		 */
		public function selectedFree(userId:String, userName:String):void
		{
			var name1:String = userName;
			var name2:String = userName;
			view.currentState = "Selected_Free";
			
			if (name1.length > 5)
			{
				name1 = name1.substr(0,4) + "…";
			}
			this.messSubBind = name1 + "さんの声は他のユーザーに聞こえています";
			if (name2.length > 8)
			{
				name2 = name2.substr(0,7) + "…";
			}
			messBind = name2 + "さんが当選！";
		}
		
		/**
		 * 当選（有料）処理.
		 * 
		 * <ul>
		 * <li>画面ステートを"Selected_Pay"にする</li>
		 * <li>～さんが当選！とメッセージに表示</li>
		 * <li>～さんの声は他のユーザーには聞こえませんと吹き出しに表示</li>
		 * </ul>
		 * 
		 * @param userId 当選ユーザID
		 * @param userName 当選ユーザ名
		 */
		public function selectedPay(userId:String, userName:String):void
		{
			var name1:String = userName;
			var name2:String = userName;
			view.currentState = "Selected_Pay";
			if (name1.length > 5)
			{
				name1 = name1.substr(0,4) + "…";
			}
			if (name2.length > 8)
			{
				name2 = name2.substr(0,7) + "…";
			}
			this.messSubBind = name1 + "さんの声は他のユーザーには聞こえません";
			messBind = name2 + "さんが当選！";
		}
		
		/**
		 * 無料電話呼出し中設定処理.
		 * 
		 * <ul>
		 * <li>画面ステートを"Calling_Free"にする</li>
		 * <li>呼出し中グローフィルタを開始する</li>
		 * </ul>
		 * 
		 * @param userId 当選ユーザID
		 * @param userName 当選ユーザ名
		 */
		public function callingFree(userId:String, userName:String):void
		{
			view.currentState = "Calling_Free";
			view.callFilter.end();
			view.callFilter.play();
		}
		
		/**
		 * 有料電話呼出し中設定処理.
		 * 
		 * <ul>
		 * <li>画面ステートを"Calling_Pay"にする</li>
		 * <li>呼出し中グローフィルタを開始する</li>
		 * </ul>
		 * 
		 * @param userId 当選ユーザID
		 * @param userName 当選ユーザ名
		 */
		public function callingPay(userId:String, userName:String):void
		{
			view.currentState = "Calling_Pay";
			view.callFilter.end();
			view.callFilter.play();
		}
		
		/**
		 * 無料電話開始設定.
		 * 
		 * <ul>
		 * <li>電話タイマーを60秒に設定してスタートする</li>
		 * <li>画面ステートを"Speaking_Free"にする</li>
		 * <li>～さんと会話中！とメッセージに表示</li>
		 * <li>電話中グローフィルタを開始する</li>
		 * </ul>
		 * 
		 * @param userId 当選ユーザID
		 * @param userName 当選ユーザ名
		 */
		public function speakingFree(userId:String, userName:String):void
		{
			telTimeValue = ConstValues.COUNTER_TEL;
			telTimer.start();
			view.currentState = "Speaking_Free";
			var name:String = userName;
			if (name.length > 8)
			{
				name = name.substr(0,7) + "…";
			}
			messBind = name + "さんと会話中！";
			view.speakFilter.end();
			view.speakFilter.play();
		}
		
		/**
		 * 有料電話中開始設定.
		 * 
		 * <ul>
		 * <li>電話タイマーを60秒に設定してスタートする</li>
		 * <li>画面ステートを"Speaking_Pay"にする</li>
		 * <li>～さんと会話中！とメッセージに表示</li>
		 * <li>電話中グローフィルタを開始する</li>
		 * </ul>
		 * 
		 * @param userId 当選ユーザID
		 * @param userName 当選ユーザ名
		 */
		public function speakingPay(userId:String, userName:String):void
		{
			telTimeValue = ConstValues.COUNTER_TEL;
			telTimer.start();
			view.currentState = "Speaking_Pay";
			var name:String = userName;
			if (name.length > 8)
			{
				name = name.substr(0,7) + "…";
			}
			messBind = name + "さんと会話中！";
			view.speakFilter.end();
			view.speakFilter.play();
		}
		

		//--------------------------------------
		// View-Logic Binding
		//--------------------------------------
		/** 画面 */
		public var _view:TelInfo_Qa;
		
		/**
		 * 画面を取得します
		 */
		public function get view():TelInfo_Qa
		{
			if (_view == null)
			{
				_view = super.document as TelInfo_Qa;
			}
			return _view;
		}
		
		/**
		 * 画面をセットします。
		 *
		 * @param view セットする画面
		 */
		public function set view(view:TelInfo_Qa):void
		{
			_view = view;
		}
		
	}
}