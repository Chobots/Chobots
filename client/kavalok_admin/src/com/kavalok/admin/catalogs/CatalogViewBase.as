package com.kavalok.admin.catalogs
{
	import com.kavalok.dto.shop.ShopAdminTO;
	import com.kavalok.services.ShopService;
	import com.kavalok.utils.Strings;
	import mx.controls.ComboBox;
	import mx.controls.TextInput;
	import mx.controls.Button;
	import mx.containers.Canvas;
	
	public class CatalogViewBase extends Canvas
	{
		[Bindable] public var nameField:TextInput;
		[Bindable] public var requiredPermissionCombo:ComboBox;
		[Bindable] public var saveButton:Button;
		
		[Bindable] public var item:ShopAdminTO;
		
		public function CatalogViewBase()
		{
			super();
		}
		
		public function save():void
		{
			item.name = Strings.trim(nameField.text);
			item.requiredPermission = requiredPermissionCombo.selectedItem ? String(requiredPermissionCombo.selectedItem) : "";
			
			saveButton.enabled = false;
			new ShopService(onSave).saveShop(item);
		}
		
		private function onSave(result:Object):void
		{
			saveButton.enabled = true;
		}
	}
} 