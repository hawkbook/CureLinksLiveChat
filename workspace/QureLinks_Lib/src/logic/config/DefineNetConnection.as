package logic.config
{
	/**
	 * FMSのアドレスとAmeba Studioのアドレスの変更用コンフィグ.
	 * 
	 * 本番用アドレス,開発用アドレス,テストサーバ用アドレスを定義する。
	 * 
	 **/
	public class DefineNetConnection
	{
		// 本番用
//		public static var url_fms:String = "202.239.226.67";
//		public static var url_amebastudio:String = "www.amebastudio.jp";
//		public static var url_web:String = "qurelinks.jp";
		
		// テストサーバ
//		public static var url_fms:String = "202.239.226.67";
//		public static var url_amebastudio:String = "202.239.226.67";
//		public static var url_web:String = "202.239.226.67";
		
		// ローカルサーバ
		public static var url_fms:String = "localhost";
		public static var url_amebastudio:String = "localhost";
		public static var url_web:String = "localhost";
	}
}