package com.kavalok.services
{

	public class SOService extends Red5ServiceBase
	{
		public function SOService(resultHandler:Function=null, faultHandler:Function=null)
		{
			super(resultHandler, faultHandler);
		}
		
		public function getState(sharedObjectId : String) : void {
			doCall("getState", arguments);
		}
		
		public function getNumConnectedChars(sharedObjectId:String, server:String) : void {
			doCall("getNumConnectedChars", arguments);
		}
		
		public function releaseSharedObject(sharedObjectId : String) : void {
			doCall("releaseSharedObject", arguments);
		}
		
		
	}
}