package com.kavalok.dto.shop
{
	
	[RemoteClass(alias="com.kavalok.dto.shop.ShopAdminTO")]
	
	public class ShopAdminTO
	{
		[Bindable] public var id:int;
		[Bindable] public var name:String;
		[Bindable] public var requiredPermission:String;
	}
	
} 