package logic.config
{
	/**
	 * デフォルト定数定義
	 * @author takamoto
	 */
	public class ConstValues
	{
		/**
		 * カメラのFPS.
		 * @default 10
		 */
		public static const CAMERA_FPS:Number = 10;			// カメラのFPS、デフォルトは15
		/**
		 * カメラ横幅.
		 * @default 336
		 */
		public static const CAMERA_WIDTH:int = 336;			// カメラ横幅
		/**
		 * カメラ縦幅
		 * @default 252
		 */
		public static const CAMERA_HEIGHT:int = 252;			// カメラ縦幅
		/**
		 * カメラ帯域幅
		 * @default 81920
		 */
		public static const CAMERA_BANDWIDTH:int = 81920;		// カメラ帯域幅
		/**
		 * マイクゲイン
		 * @default 80
		 */
		public static const MIC_GAIN:int = 80;				// ゲイン80%
		/**
		 * マイクVAD（Speexの音声アクティビティ検知機能を使用するか？
		 * @default true:使用する。
		 */
		public static const MIC_ENABLE_VAD:Boolean = true;	// VAD（Speexの音声アクティビティ検知機能を使用するか？（true=使用する）
		/**
		 * マイクコーデック
		 * @default Speex
		 */
		public static const MIC_CODEC:String = "speex";		// コーデック＝Speex
		/**
		 * マイクサイレンスレベル
		 * @default 0
		 */
		public static const MIC_SILENCELEVEL:int = 0;			// サイレンスレベル 0% Speexの場合は0
		/**
		 * マイククオリティ
		 * @default 10
		 */
		public static const MIC_QUALITY:int = 10;				// 最高クオリティ (0～10) Speexの場合のみ
		/**
		 * マイクエコーを減らす？
		 * @default true:減らす
		 */
		public static const MIC_USE_ECHO_SUPPRESSION:Boolean = true;		// エコーを減らす？（true=減らす）
		/**
		 * マイクFPP（フレーム/パケット）
		 * @default 2
		 */
		public static const MIC_FPP:int = 2;					// FPP（フレーム/パケット）(1～10) Speexの場合のみ 少ないほど遅れない
		/**
		 * マイクレベルを表示する間隔タイマー値
		 * @default 200
		 */
		public static const TIMER_MICLEVEL:int = 200;			// マイクレベルを表示する間隔タイマー値（ms）
		/**
		 * 放送時間用間隔タイマー値（ms）
		 * @default 1000
		 */
		public static const TIMER_CHAT:int = 1000;			// 放送時間用間隔タイマー値（ms）
		/**
		 * NetConnection NGタイマー値（ms）
		 * @default 1000*60
		 */
		public static const TIMER_CONNECTION:int = 1000*60;	// NetConnection NGタイマー値（ms）
		/**
		 * キャストがFMSに生存通知するタイマー値（ms）
		 * @default 3000
		 */
		public static const TIMER_ALIVE:int = 3000;			// キャストがFMSに生存通知するタイマー値（ms）
		/**
		 * ユーザがFMSに生存通知するタイマー値（ms）
		 * @default 5000
		 */
		public static const TIMER_USER_ALIVE:int = 5000;		// ユーザがFMSに生存通知するタイマー値（ms）
		/**
		 * 再ログインチェックタイマー値（ms）
		 * @default 3000
		 */
		public static const TIMER_CHECK_WAIT_IN:int = 3000;	// 再ログインチェックタイマー値（ms）
		/**
		 * 再ログインチェックタイマー値（ms）
		 * @default 45000
		 */
		public static const TIMER_WAIT_IN:int = 45000;		// 再ログインチェックタイマー値（ms）
		/**
		 * 一分課金タイマー値（ms）
		 * @default 60000
		 */
		public static const TIMER_PAY:int = 60000;			// 一分課金タイマー値（ms）
		/**
		 * LIKEタイマー値（ms）
		 * @default 10000
		 */
		public static const TIMER_LIKE:int = 10000;			// LIKEタイマー値（ms）
		/**
		 * 抽選待ちタイマー値（ms）
		 * @default 10000
		 */
		public static const TIMER_SELECT:int = 10000;			// 抽選待ちタイマー値（ms）
		/**
		 * 生電話カウントダウンタイマー値（ms）
		 * @default 1000
		 */
		public static const TIMER_TEL:int = 1000;				// 生電話カウントダウンタイマー値（ms）
		
		/**
		 * 生電話カウンター
		 * @default 90
		 */
		public static const COUNTER_TEL:int = 90;				// 生電話カウンター（sec）
		/**
		 * スロット待ちタイマー値（ms）
		 * @default 15000
		 */
		public static const TIMER_WAIT_SLOT:int = 15000;		// スロット待ちタイマー値（ms）
		/**
		 * 当選待ちタイマー値（ms）
		 * @default 5000
		 */
		public static const TIMER_WAIT_SELECTED:int = 5000;	// 当選待ちタイマー値（ms）
		/**
		 * 呼び出し待ちタイマー値（ms）
		 * @default 5000
		 */
		public static const TIMER_WAIT_CALLING:int = 5000;	// 呼び出し待ちタイマー値（ms）
		/**
		 * 会話開始待ちタイマー値（ms）
		 * @default 5000
		 */
		public static const TIMER_WAIT_SPEAKSTART:int = 5000;	// 会話開始待ちタイマー値（ms）
		/**
		 * ENTRY_START メッセージタイマー値（ms）
		 * @default 3000
		 */
		public static const TIMER_LOOP_ENTRY_START:int = 3000;	// ENTRY_START メッセージタイマー値（ms）
		
		/**
		 * マイクアクションレベル.
		 * 
		 * 生電話でのユーザーマイクをチェック時、このレベル以上だとマイクが繋がっているものとする。
		 * 
		 * @default 1
		 */
		public static const MIC_CHECK_ACTIVE_LEVEL:int = 10;
	}
}