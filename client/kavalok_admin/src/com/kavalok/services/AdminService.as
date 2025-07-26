package com.kavalok.services
{
	import com.kavalok.dto.UserTO;
	import com.kavalok.remoting.RemoteCommand;
	
	public class AdminService extends Red5ServiceBase
	{
		public function AdminService(resultHandler:Function=null, faultHandler:Function=null)
		{
			super(resultHandler, faultHandler);
		}
		
//		public function sendMail(subject : String , text : String , locales : Array) : void
//		{
//			doCall("sendMail", arguments);
//		}

		public function getStuffGroupNum():void
		{
			doCall("getStuffGroupNum", arguments);
		}
		public function saveStuffGroupNum(groupNum:int):void
		{
			doCall("saveStuffGroupNum", arguments);
		}
	
		public function getServerLimit():void
		{
			doCall("getServerLimit", arguments);
		}
		public function setServerLimit():void
		{
			doCall("setServerLimit", arguments);
		}
		public function getPermissionLevel(login : String):void
		{
			doCall("getPermissionLevel", arguments);
		}
		public function moveUsers(fromId:int, toId:int):void
		{
			doCall("moveUsers", arguments);
		}
		public function setBanDate(userId : int, date:Date):void
		{
			doCall("setBanDate", arguments);
		}

		public function setDisableChatPeriod(userId : int, periodNumber:int):void
		{
			doCall("setDisableChatPeriod", arguments);
		}

		public function getGraphity(server:String, wallId:String):void
		{
			doCall("getGraphity", arguments);
		}

		public function clearGraphity(server:String, wallId:String):void
		{
			doCall("clearGraphity", arguments);
		}
		
		public function getSharedObjects() : void
		{
			doCall("getSharedObjects", arguments);
		}
		
		public function sendState(serverId:int, remoteId:String, clientId:String, method:String, stateName:String, state:Object):void
		{
			doCall("sendState", arguments);
		}

		public function removeState(serverId:int, remoteId:String, clientId:String, method:String, stateName:String):void
		{
			doCall("removeState", arguments);
		}
		
		public function sendLocationCommand(serverId:int, remoteId:String, command:RemoteCommand):void
		{
			doCall("sendLocationCommand", [serverId, remoteId, command.getProperties()]);
		}
		
		public function getRainableStuffs():void
		{
			doCall("getRainableStuffs", arguments);
		}
		
		public function clearSharedObject(serverId : int, sharedObjectId : String) : void
		{
			doCall("clearSharedObject", arguments);
		}
		
		public function setReportsProcessed(userId : int) : void
		{
			doCall("setReportsProcessed", arguments);
		}
		
		public function setReportProcessed(reportId : int) : void
		{
			doCall("setReportProcessed", arguments);
		}
		
		public function getReports(firstResult : int, maxResults : int) : void
		{
			doCall("getReports", arguments);
		}

		public function sendGlobalMessage(text : String, locales : Array) : void
		{
			doCall("sendGlobalMessage", arguments);
		}

		public function getAdminMessages(firstResult : uint, maxResults : uint) : void
		{
			doCall("getAdminMessages", arguments);
		}

		public function addMoney(userId : int , money : int, reason : String) : void {
			doCall("addMoney", arguments);
		}

		public function setMessageProcessed(id : int) : void {
			doCall("setMessageProcessed", arguments);
		}
		
		public function getConfig() : void {
			doCall("getConfig", arguments);
		}

		public function saveConfig(registrationEnabled : Boolean, guestEnabled:Boolean, spamMessagesLimit : int, serverLimit : int) : void {
			doCall("saveConfig", arguments);
		}
	
		public function getWorldConfig() : void {
			doCall("getWorldConfig", arguments);
		}

		public function saveWorldConfig(safeModeEnabled : Boolean) : void {
			doCall("saveWorldConfig", arguments);
		}

		public function reboot(serverName : String) : void
		{
			doCall("reboot", arguments);
		}
		
		public function saveUserData(userId : int, activated : Boolean, chatEnabled : Boolean,
			chatEnabledByParent : Boolean, agent:Boolean, baned:Boolean, moderator:Boolean, drawEnabled:Boolean) : void
		{
			doCall("saveUserData", arguments);
		}

		public function saveUserBan(userId : int, baned:Boolean, banReason:String) : void
		{
			doCall("saveUserBan", arguments);
		}
		
		public function saveIPBan(ip: String, baned : Boolean, banReason : String) : void
		{
			doCall("saveIPBan", arguments);
		}
		
		
		public function getLastChatMessages(userId : int) : void
		{
			doCall("getLastChatMessages", arguments);
		}
		
		public function getUser(userId : int) : void
		{
			doCall("getUser", arguments);
		}
		
		public function getUsers(serverId : int, filters : Array, firstResult : int, maxResults : int) : void
		{
			doCall("getUsers", arguments);
		}
		
		public function sendRules(userId : int) : void
		{
			doCall("sendRules", arguments);
		}
		
		public function kickOut(userId : int, baned : Boolean) : void
		{
			doCall("kickOut", arguments);
		}
		
		public function setMailServerAvailable(id : int, available : Boolean) : void
		{
			doCall("setMailServerAvailable", arguments);
		}
		
		public function getMailServers() : void
		{
			doCall("getMailServers", arguments);
		}
		
		public function setServerAvailable(id : int, available : Boolean) : void
		{
			doCall("setServerAvailable", arguments);
		}

		public function addCitizenship(userId : int, months : int, days : int, reason : String) : void
		{
			doCall("addCitizenship", arguments);
		}
		public function addStuff(userId : int, stuffTypeId : int, color : int, reason : String) : void
		{
			doCall("addStuff", arguments);
		}

		public function deleteUser(userId : int) : void
		{
			doCall("deleteUser", arguments);
		}

		public function restoreUser(userId : int) : void
		{
			doCall("restoreUser", arguments);
		}
		
		public function adminLogin(login:String, password:String):void
		{
			doCall("adminLogin", arguments);
		}
		
	}
}