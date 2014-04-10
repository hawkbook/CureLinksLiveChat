package logic.entity
{
	import flash.media.Camera;
	import logic.config.ConstValues;
	
	public final class CustomCamera
	{
		public static function getCamera(name:String=null):Camera
		{
			var cam:Camera;
			cam = Camera.getCamera(name);
			if (cam != null)
			{
				cam.setMode(ConstValues.CAMERA_WIDTH, ConstValues.CAMERA_HEIGHT, ConstValues.CAMERA_FPS, false);
				cam.setQuality(ConstValues.CAMERA_BANDWIDTH, 0);
				cam.setKeyFrameInterval(48);
				cam.setMotionLevel(50);		// モーションレベル
			}
			return cam;
		}
	}
}