package com.kavalok.remoting {
	
	import com.kavalok.collections.ArrayList;
	import com.kavalok.utils.ReflectUtil;
	
	import flash.net.NetConnection;
	
	public class BaseRed5Delegate extends BaseDelegate {
		
		private static const METHOD_NAME : String = "call";
		
		public static var defaultConnectionUrl : String;
		
		private static var _netConnection : NetConnection;
		
		public static function get netConnection() : NetConnection {
			if (_netConnection == null) {
				_netConnection = new NetConnection();
			}
			return _netConnection;
		}
		
		public static function resetNetConnection() : void {
			if (_netConnection != null) {
				try { _netConnection.close(); } catch (e:Error) {}
			}
			_netConnection = new NetConnection();
		}
		
		public function BaseRed5Delegate(resultHandler : Function, faultHandler : Function) {
			super(resultHandler, faultHandler);
			connectionUrl = defaultConnectionUrl;
		}
		
		protected override function createConnection(): NetConnection {
			return netConnection;
		}
		
		protected override function getServiceName(methodName : String) : String {
			return METHOD_NAME;
		}
		
		protected override function processArguments(methodName : String, args : Array) : Array {
			var newArgs : ArrayList = new ArrayList();
			var className : String = ReflectUtil.getFullTypeName(this);
			className = ReflectUtil.normalizeTypeName(className);
			newArgs.addItem(className);
			newArgs.addItem(methodName);
			newArgs.addItem(args);
			return newArgs;
		}
		
	}
	
}