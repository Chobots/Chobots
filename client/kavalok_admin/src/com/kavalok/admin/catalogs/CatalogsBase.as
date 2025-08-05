package com.kavalok.admin.catalogs
{
	import com.kavalok.dto.shop.ShopAdminTO;
	import com.kavalok.services.ShopService;
	import mx.controls.DataGrid;
	import mx.events.ListEvent;
	import mx.containers.Canvas;
	import org.goverla.collections.ArrayList;
	
	public class CatalogsBase extends Canvas
	{
		[Bindable] public var catalogsGrid:DataGrid;
		[Bindable] public var catalogView:CatalogView;
		[Bindable] public var selectedItem:ShopAdminTO;
		[Bindable] public var catalogList:ArrayList;
		
		public function CatalogsBase()
		{
			super();
			refresh();
		}
		
		public function refresh():void
		{
			new ShopService(onGetShops).getShops();
		}
		
		private function onGetShops(result:Object):void
		{
			catalogList = new ArrayList(result as Array);
		}
		
		public function onItemChange(event:ListEvent):void
		{
			selectedItem = ShopAdminTO(event.itemRenderer.data);
		}
		
		public function onAddClick():void
		{
			selectedItem = new ShopAdminTO();
			selectedItem.requiredPermission = "PUBLIC";
		}
	}
} 