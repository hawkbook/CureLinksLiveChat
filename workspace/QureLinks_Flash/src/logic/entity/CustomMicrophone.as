package logic.entity
{
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	
	import logic.config.ConstValues;
	
	public final class CustomMicrophone
	{
		public static function getMicrophone():Microphone
		{
			var mic:Microphone;
			mic = Microphone.getMicrophone();
			if (mic != null)
			{
				mic.codec=ConstValues.MIC_CODEC;					// コーデック
				mic.setSilenceLevel(ConstValues.MIC_SILENCELEVEL);	// サイレンスレベル
				mic.gain = ConstValues.MIC_GAIN * 0.8;				// デフォルトゲイン（定数の70%）
				mic.enableVAD = ConstValues.MIC_ENABLE_VAD;			// 音声アクティビティ機能
				mic.encodeQuality = ConstValues.MIC_QUALITY;		// クオリティ
				mic.framesPerPacket = ConstValues.MIC_FPP;			// フレーム/パケット
				mic.setUseEchoSuppression(ConstValues.MIC_USE_ECHO_SUPPRESSION);	// エコーを減らす
			}
			return mic;
		}
		
	}
}