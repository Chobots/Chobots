package com.kavalok.dto
{
	[RemoteClass(alias="com.kavalok.dto.ServerTO")]
	public class ServerTO
	{
		public var id : int;
		
		public var url : String;
		
		public var name : String ;
		
		public var label : String ;
		
		public var load : int;
		
		public var available : Boolean;

		public var running : Boolean;

		public var rtmpPort : int;

		public var tls : Boolean;

	}
}