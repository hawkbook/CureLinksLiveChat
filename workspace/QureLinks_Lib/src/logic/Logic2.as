package logic
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.describeType;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	import mx.collections.ArrayCollection;
	import mx.core.IMXMLObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.states.State;
	
	/**
	 * logic基本クラス２.
	 * <p>
	 * logicパッケージの基本クラス。
	 * Logicクラスに、MXMLステートと画面部品のイベントハンドラの自動作成を追加している。
	 * 基本的にLogicではなく、こちらのLogic2を使用する。
	 * </p>
	 * @author bullet.Corp.
	 */
	public class Logic2 implements IMXMLObject {
		
		private static var HANDLER:String = "Handler";
		private static var ON:String = "On";
		
		/** MXMLファイルを参照するクラス */
		private var _document:UIComponent;
		
		/** MXMLファイル上で指定されたLogicクラスのid */
		private var _id:String;
		
		/** MXML(view)の構成情報 */
		private var describeTypeView:XML;
		
		/** Logic(viewの対になるASファイル)の構成情報 */
		private var describeTypeLogic:XML;
		
		/** MXML(view)から取得したdocument上に配置されているコンポーネントリスト */
		private var componentList:XMLList;
		
		/** コンポーネント名を保持する */
		private var registComponent:ArrayCollection = new ArrayCollection();
		
		/**
		 * Flex初期化イベント処理.
		 * 
		 * <p>実装オブジェクトが作成され、MXML タグに指定されたすべてのコンポーネントプロパティが初期化された後に呼び出されます。</p>
		 * @param document ： このオブジェクトを作成した MXML ドキュメントです。
		 * @param id ： document がこのオブジェクトを参照するために使用する識別子です。オブジェクトが document の deep プロパティである場合、id は null になります。 
		 */
		public function initialized(document:Object, id:String):void 
		{
			_document = document as UIComponent;
			_id = id;
			
			/*-----------------------------------
			View、Logic情報を取得
			-----------------------------------*/
			// MXMLファイルのオブジェクト情報をXMLで取得
			describeTypeView = describeType( _document );
			// Logic(取得したMXMLファイルと対のAS)の
			describeTypeLogic = describeType( this );
			// MXMLファイルのコンポーネント一覧を取得
			componentList = describeTypeView.accessor.( @declaredBy == describeTypeView.@name ).@name;
			
			/*-----------------------------------
			各種初期化イベントの登録
			-----------------------------------*/
			// 初期化イベントの登録
			_document.addEventListener( FlexEvent.PREINITIALIZE, preinitialize );
			_document.addEventListener( FlexEvent.INITIALIZE, initialize );
			// 画面生成後初期化イベントの登録
			_document.addEventListener( FlexEvent.CREATION_COMPLETE, onCreationCompleteHandler, false, 0, true );
			
			_document.addEventListener( FlexEvent.APPLICATION_COMPLETE, onApplicationCompleteHandler, false, 0, true );
			
			_document.addEventListener( FlexEvent.UPDATE_COMPLETE, onUpdateCompleteHandler, false, 0, true );
		}
		
		/**
		 *  初期化前イベント処理.
		 * 
		 * <p>イベントの順番</p>
		 * <ol>
		 *  <li><b>FlexEvent.PREINITIALIZE</b></li>
		 *  <li>FlexEvent.INITIALIZE</li>
		 *  <li>(addChild)</li>
		 *  <li>FlexEvent.CREATION_COMPLETE</li>
		 *  <li>FlexEvent.APPLICATION_COMPLETE</li>
		 *  <li>FlexEvent.UPDATE_COMPLETE</li>
		 *  <li>InvokeEvent.INVOKE</li>
		 * </ol>
		 */
		protected function preinitialize( event:FlexEvent):void
		{
		}
		
		/**
		 *  初期化イベント処理.
		 * 
		 * <p>イベントの順番</p>
		 * <ol>
		 *  <li>FlexEvent.PREINITIALIZE</li>
		 *  <li><b>FlexEvent.INITIALIZE</b></li>
		 *  <li>(addChild)</li>
		 *  <li>FlexEvent.CREATION_COMPLETE</li>
		 *  <li>FlexEvent.APPLICATION_COMPLETE</li>
		 *  <li>FlexEvent.UPDATE_COMPLETE</li>
		 *  <li>InvokeEvent.INVOKE</li>
		 * </ol>
		 */
		protected function initialize( event:FlexEvent ):void 
		{
			bindingAll();
			this._document.addEventListener( Event.ADDED, added );
		}
		
		/**
		 *  画面生成後初期化処理.
		 * 
		 * <p>イベントの順番</p>
		 * <ol>
		 *  <li>FlexEvent.PREINITIALIZE</li>
		 *  <li>FlexEvent.INITIALIZE</li>
		 *  <li>(addChild)</li>
		 *  <li><b>FlexEvent.CREATION_COMPLETE</b></li>
		 *  <li>FlexEvent.APPLICATION_COMPLETE</li>
		 *  <li>FlexEvent.UPDATE_COMPLETE</li>
		 *  <li>InvokeEvent.INVOKE</li>
		 * </ol>
		 */
		protected function onCreationCompleteHandler(event:FlexEvent):void 
		{
			
		}
		
		/**
		 *  アプリケーション生成後初期化処理.
		 * 
		 * <p>イベントの順番</p>
		 * <ol>
		 *  <li>FlexEvent.PREINITIALIZE</li>
		 *  <li>FlexEvent.INITIALIZE</li>
		 *  <li>(addChild)</li>
		 *  <li>FlexEvent.CREATION_COMPLETE</li>
		 *  <li><b>FlexEvent.APPLICATION_COMPLETE</b></li>
		 *  <li>FlexEvent.UPDATE_COMPLETE</li>
		 *  <li>InvokeEvent.INVOKE</li>
		 * </ol>
		 */
		protected function onApplicationCompleteHandler(event:FlexEvent):void 
		{
			
		}
		
		/**
		 *  アップデート終了後初期化処理.
		 * 
		 * <p>イベントの順番</p>
		 * <ol>
		 *  <li>FlexEvent.PREINITIALIZE</li>
		 *  <li>FlexEvent.INITIALIZE</li>
		 *  <li>(addChild)</li>
		 *  <li>FlexEvent.CREATION_COMPLETE</li>
		 *  <li>FlexEvent.APPLICATION_COMPLETE</li>
		 *  <li><b>FlexEvent.UPDATE_COMPLETE</b></li>
		 *  <li>InvokeEvent.INVOKE</li>
		 * </ol>
		 */
		protected function onUpdateCompleteHandler(event:FlexEvent):void 
		{
			
		}
		
		/**
		 * document.addedイベント.
		 * 
		 * State(等)を使用する場合、遅延読込を行う事があるため、
		 * addedイベントが発生したタイミングで追加コントロールの自動登録を行う。
		 * 
		 */
		public function added(e:Event):void
		{
			// Viewに属するコンポーネントのイベントハンドラを関連付け
			bindingChildren(this.document);
		}
		
		/**
		 * 関連付けの再実行.
		 * 
		 * 利用者側が明示的に関連付けをやり直したい場合に実行するメソッド
		 * 
		 */		
		public function rebinding():void
		{
			bindingAll();
		}
		
		
		/**
		 * イベントの関連付け一括実行.
		 * <ul>
		 *  <li>View自身のイベントハンドラ関連付け</li>
		 *  <li>State(使用している場合)のイベントハンドラ関連付け</li>
		 *  <li>コンポーネントのイベントハンドラ関連付け</li>
		 * </ul>
		 */
		private function bindingAll():void
		{
			// キャッシュのクリア
			registComponent.removeAll();
			
			// View自身のイベントハンドラを関連付け
			bindingViewSelf(this.document);
			
			// Statesのイベントハンドラを関連付け
			bindingStates(this.document);
			
			// Viewに属するコンポーネントのイベントハンドラを関連付け
			bindingChildren(this.document);
		}
		
		/**
		 * View自身のイベントハンドラ登録.
		 * 
		 * @param document Viewオブジェクト(MXML)
		 */
		private function bindingViewSelf( document:UIComponent ):void 
		{
			var componentName:String = "";
			
			/*-----------------------------------
			Logicのイベントハンドラーリストを
			取得する
			On + <イベント名> + Handler
			-----------------------------------*/
			var methodNameList:XMLList = describeTypeLogic.method.(
				String(@name).substr(0, String(componentName+ON).length) == String(componentName+ON)).@name;
			
			/*-----------------------------------
			取得したメソッド分だけ関連付け
			-----------------------------------*/
			for each( var methodName:String in methodNameList ) {
				var eventName:String = createEventName( methodName );
				
				if( eventName != "" ) {
					document.removeEventListener( eventName, this[methodName] );
					document.addEventListener( eventName, this[methodName] );
				}
			}
		}
		
		/**
		 * Statesのイベントハンドラ登録.
		 * 
		 * @param document Viewオブジェクト(MXML)
		 */
		private function bindingStates( document:UIComponent ):void 
		{
			for each( var state:Object in document.states ) {
				var componentName:String = State( state ).name;
				
				//　すでにキャッシュされている場合は処理をしない
				if( registComponent.getItemIndex(componentName) >= 0 ) {
					continue;
				}
				
				// コンポーネントをキャッシュする
				registComponent.addItem( componentName );
				
				/*-----------------------------------
				Logicからコンポーネントに対応した
				イベントハンドラのリストを取得
				<State名> + ON + <イベント名> + Handler
				-----------------------------------*/
				var methodNameList:XMLList = describeTypeLogic.method.(
					String(@name).substr(0, String(componentName+ON).length) == String(componentName+ON)).@name;
				// 取得したイベントハンドラ分の関連付け
				for each( var methodName:String in methodNameList ) {
					var eventName:String = createEventName( methodName );
					
					if( eventName != "" ) {
						State(state).removeEventListener( eventName, this[methodName] );
						State(state).addEventListener( eventName, this[methodName] );
					}
				}
			}
		}
		
		/**
		 * コンポーネントのイベントハンドラ登録.
		 * 
		 * @param document Viewオブジェクト(MXML)
		 */
		private function bindingChildren( document:UIComponent ):void 
		{
			for each( var componentName:String in componentList ) {
				//　すでにキャッシュされている場合は処理をしない
				if( registComponent.getItemIndex(componentName) >= 0 ) {
					continue;
				}
				
				// コンポーネントをキャッシュする
				// State使用でのインスタンス化遅延を考慮して、nullはキャッシュしない
				if( document.hasOwnProperty(componentName) && document[componentName] != null ) {
					registComponent.addItem( componentName );
				} else {
					continue;
				}
				
				/*-----------------------------------
				Logicからコンポーネントに対応した
				イベントハンドラのリストを取得
				<コンポーネント名> + ON + <イベント名> + Handler
				-----------------------------------*/
				var methodNameList:XMLList = describeTypeLogic.method.(
					String(@name).substr(0, String(componentName+ON).length) == String(componentName+ON)).@name;
				// 取得したイベントハンドラ分の関連付け
				for each( var methodName:String in methodNameList ) {
					var eventName:String = createEventName( methodName );
					
					if( eventName != "" ) {
						IEventDispatcher(document[componentName]).removeEventListener( eventName, this[methodName] );
						IEventDispatcher(document[componentName]).addEventListener( eventName, this[methodName] );
					}
				}
			}
		}
		
		/**
		 * イベントハンドラからイベント名を抽出する.
		 * 
		 * @param methodName イベントハンドラ名
		 */
		private function createEventName(methodName:String):String 
		{
			var idx:int;
			var eventName:String = "";
			
			eventName = methodName.toString();
			
			idx = eventName.indexOf(HANDLER);
			eventName = eventName.substring(0,idx);
			idx = eventName.indexOf(ON);
			eventName = eventName.substring(idx+ON.length,eventName.length);
			eventName = String(eventName.charAt(0)).toLowerCase() + eventName.substring(1,eventName.length);
			
			return eventName;   // キャッシュに登録済みのイベントハンドラの場合、イベント名を空白で戻し、その後のaddListenerEventを迂回する
		}
		
		/**
		 * document を取得する.
		 * 
		 */
		public final function get document():UIComponent {
			return _document;
		}
		
		
		/**
		 * id を取得する.
		 * 
		 */
		public final function get id():String {
			return _id;
		}
	}
}