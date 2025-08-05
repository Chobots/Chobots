package com.kavalok.remoting
{
	import com.kavalok.Global;
	import com.kavalok.collections.ArrayList;
	import com.kavalok.dto.StateInfoTO;
	import com.kavalok.errors.IllegalArgumentError;
	import com.kavalok.errors.IllegalStateError;
	import com.kavalok.interfaces.IRequirement;
	import com.kavalok.remoting.constants.SOCodes;
	import com.kavalok.remoting.interfaces.IClient;
	import com.kavalok.security.SimpleEncryptor;
	import com.kavalok.services.SOService;
	import com.kavalok.utils.Arrays;
	import com.kavalok.utils.ReflectUtil;
	import com.kavalok.utils.Strings;
	import com.kavalok.utils.Timers;
	import com.kavalok.utils.comparing.PropertyCompareRequirement;
	
	import flash.events.SyncEvent;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	public class RemoteObject
	{
		private static const PREVENT : String = "PREVENT";
		private static const ON_SEND : String = "oS";
		private static const ON_SEND_STATE : String = "oSS";
		private static const TIMEOUT : int = 15000;
		
		private var _connectedChars : Array = new Array();
		
		private var _clients : ArrayList = new ArrayList();
		private var _sharedObject : SharedObject;
		
		private var _states : Object = new Object();
		private var _stateLoaded : Boolean;
		private var _synced : Boolean;
		private var _id : String;
		private var _ownerId : String;
		private var _timer : Timer;
		
		public function RemoteObject(id : String)
		{
			_id = id;
			_sharedObject = SharedObject.getRemote(id, RemoteConnection.instance.netConnection.uri);
			_sharedObject.client = this;
			_sharedObject.addEventListener(SyncEvent.SYNC, onSync);
			connectToSO();
		}
		
		public function get id() : String
		{
			return _id;
		}
		public function get states() : Object
		{
			return _states;
		}
		public function get clients() : uint
		{
			return _clients.length;
		}
		
		public function get connectedChars() : Array
		{
			return _connectedChars;
		}
		public function addClient(client : IClient) : void
		{
			_clients.addItem(client);
			client.remote = this;
			if(_ownerId != null)
			{
				setClientProperty(client, "owner", _ownerId);
			}
			for(var property : String in _sharedObject.data)
			{
				setClientProperty(client, property);
			}
			if(_stateLoaded && _synced)
			{
				forceClientState(client.id);
				client.restoreState(_states[client.id]);
			}
		}
		
		private function connectToSO() : void
		{
			// Check if user is still connected before attempting connection
			if (!RemoteConnection.instance.connected) {
				trace(_id + " user disconnected, skipping shared object connection");
				return;
			}
			
			try {
				_sharedObject.connect(RemoteConnection.instance.netConnection);
				if(!_stateLoaded)
					new SOService(onGetState).getState(id);
				_timer = new Timer(TIMEOUT, 1);
				_timer.addEventListener(TimerEvent.TIMER, onTimer);
				_timer.start();
			} catch (error:Error) {
				trace(_id + " shared object connection failed: " + error.message);
				// Don't retry if user is disconnected
				if (RemoteConnection.instance.connected) {
					_timer = new Timer(TIMEOUT, 1);
					_timer.addEventListener(TimerEvent.TIMER, onTimer);
					_timer.start();
				}
			}
		}
		private function onTimer(event : TimerEvent) : void
		{
			// Check if user is still connected before attempting reconnection
			if (!RemoteConnection.instance.connected) {
				trace(_id + " user disconnected, stopping reconnection attempts");
				return;
			}
			
			if(!_stateLoaded || !_synced)
			{
				trace(_id + " connection fault retrying");
				connectToSO();
			}
		}
		private function onGetState(stateInfo : StateInfoTO) : void
		{
			if(_stateLoaded)
				return;
			_stateLoaded = true;
			if(stateInfo != null)
			{
				_states = stateInfo.state;
				_connectedChars = stateInfo.connectedChars;
			}
			else
			{
				_states = {};
				_connectedChars = new Array();
			}
			tryRestoreState();
			
		}
		
		private function tryRestoreState() : void
		{
			if(_stateLoaded && _synced)
			{
				for each(var client : IClient in _clients)
				{
					forceClientState(client.id);
					client.restoreState(_states[client.id]);
				}
			}
			
		}
		
		public function removeClient(client : IClient) : void
		{
			_clients.removeItem(client);
		}
		
		public function removeState(client : IClient, method : String, stateName : String) : void
		{
			sendAny(ON_SEND_STATE, client, method, [stateName, null, false]);
		}
		
		public function sendState(client : IClient, method : String, stateName : String, state : Object, lockState : Boolean = false) : void
		{
			if (stateName == null)
				throw new IllegalArgumentError('stateName cannot be null.');
			
			sendAny(ON_SEND_STATE, client, method, [stateName, state, lockState]);
		}
		
		public function send(client : IClient, method : String, args : Array) : void
		{
			sendAny(ON_SEND, client, method, args);
		}
		
		private function sendAny(sendMethod : String, client : IClient, method : String, args : Object) : void
		{
			_sharedObject.send(sendMethod, client.id, method, args);
		}
		
		public function clear() : void
		{
			Global.locationManager.returnToPrevLoc();
		}

		//onSendState: shorten for traffic optimization
		public function oSS(clientId : String, method : String, args : Array) : void
		{
			if(!_stateLoaded)
			{
				return;
			}
			if(args.length == 1 && args[0] == PREVENT) //mutex executed
				return;
			processSendState(clientId, method, args);
		}
		private function processSendState(clientId : String, method : String, args : Array) : void
		{
			var state : Object = args[1];
			var stateName : Object = args[0];
			forceClientState(clientId);
			if(state != null)
			{
//				deserializeState(state);
				forceClientState(clientId);
				if(_states[clientId][stateName] == null)
				{
					_states[clientId][stateName] = new Object();
				}
				ReflectUtil.copyFieldsAndProperties(state, _states[clientId][stateName]);
			}
			else
			{
				delete _states[clientId][stateName];
				args=[stateName];
			}

			if (method != null)
				callClient(clientId, method, args);
		}
		
		//onSend: shorten for traffic optimization
		public function oS(clientId : String, method : String, args : Array) : void
		{
			if(!_stateLoaded)
			{
				return;
			}
			if(args.length == 1 && args[0] == PREVENT) //prevent
				return;
			if(args == null)
				args = [];
//			var args : Array = (serializedArgs)
//				? Objects.castToArray(fromAmfBase64(serializedArgs))
//				: [];			
			callClient(clientId, method, args);
		}
		
		//onChat: shorten for traffic optimization
		public function oC(from : Array, fromUserId : Number, message : Array) : void
		{
			var encryptor : SimpleEncryptor = new SimpleEncryptor(Global.chatSecurityKey);
			var fromValue : String = encryptor.decrypt(from);
			var messageValue : Object = (message[0] is Number) ? encryptor.decrypt(message) : message;
			Global.notifications.receiveChat(fromValue, fromUserId, messageValue);
		}
		
		//onCharDisconnect: shorten for traffic optimization
		public function oCD(charId : String) : void
		{
			processCharDisonnect(charId);
		}
		
		private function processCharDisonnect(charId : String) : void
		{
			if(!_stateLoaded)
				return;
			
			Arrays.removeItem(charId, _connectedChars);
			for each(var client : IClient in _clients)
			{
				client.charDisconnect(charId);
			}
			
		}
		
		//oCC: shorten for traffic optimization
		public function oCC(charId : String) : void
		{
			processCharConnect(charId);
		}
		
		private function processCharConnect(charId : String) : void
		{
			if(!_stateLoaded)
				return;
			if(Global.charManager.charId != charId)
			{
				if(_connectedChars.indexOf(charId) == -1)
				{
//					throw new IllegalStateError("Char is allready in connected list");
					_connectedChars.push(charId);
				}
				
				for each(var client : IClient in _clients)
				{
					client.charConnect(charId);
				}
			}
			
		}
	
		public function dispose() : void
		{
			for each(var client : IClient in _clients)
			{
				client.disconnect();
			}
			_sharedObject.close();
		}
		
		private function forceClientState(clientId : String) : void
		{
			if(_states[clientId] == null)
			{
				_states[clientId] = new Object();
			}
		}
		private function onSync(event : SyncEvent) : void
		{
			if(!_synced)
			{
				_synced = true;
				tryRestoreState();
			}
			var req : IRequirement = new PropertyCompareRequirement("code", SOCodes.CHANGE);
			var items : ArrayList = Arrays.getByRequirement(event.changeList, req);
			for each(var item : Object in items)
			{
				setClientsProperty(item.name);
			}
			
		}
		
		private function setClientProperty(client : IClient, name : String, value : Object = null) : void
		{
			try
			{
				client[name] = value == null ? _sharedObject.data[name] : value;
			}
			catch(e:Error)
			{
				//OK
			}
		}
		private function setClientsProperty(name : String, value : Object = null) : void
		{
			for each(var client : IClient in _clients)
			{
				setClientProperty(client, name, value);
			}
		}
		
	
		private function callClient(clientId : String, method : String, args : Array) : void
		{
			for each(var client : IClient in _clients) 
			{
				if(client.id == clientId)
				{
					var func : Function;
					try
					{
						func = client[method];
					}
					catch(e:Error)
					{
						var format : String = "{0} in {1} : {2}.{3}"
						throw new IllegalStateError(
							Strings.substitute(format, e.message, _id, ReflectUtil.getTypeName(client), method));
					}
					
					if (func != null)
					{
						Timers.callAfter(func,1, client, args);
//						func.apply(client, args);
					}
				}
			}
		}

	}
}