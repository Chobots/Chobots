package com.kavalok.admin.graphity
{
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.services.ServerService;
	import mx.binding.utils.BindingUtils;
	import mx.controls.List;
	
	import mx.containers.Canvas;
	
	import org.goverla.collections.ArrayList;

	public class GraphityBase extends Canvas
	{
		private static const WALL_IDS : Array = ["locGraphity", "locGraphityA"];
		[Bindable]
		public var servers:ArrayList;

		[Bindable]
		protected var selectedServers:ArrayList = new ArrayList();

		[Bindable]
		protected var active:Boolean;

		[Bindable]
		public var walls : Object;
			
		[Bindable]
		public var wallsList : List;
		
		private var resourceBundle : ResourceBundle;
		
		public function GraphityBase()
		{
			super();
			
			resourceBundle = Localiztion.getBundle(ResourceBundles.SERVER_SELECT);
			
			new ServerService(onGetServers).getServers();
		}
		
		protected function doCheckAll():void
		{
			for each (var item:WallItem in servers)
			{
				item.selected = true;
			}
		}
		
		protected function doUncheckAll():void
		{
			for each (var item:WallItem in servers)
			{
				item.selected = false;
			}
		}
		
		private function onGetServers(result:Array):void
		{
			var list : ArrayList = new ArrayList();
			for each(var server : Object in result)
			{
				for each(var wallId : String in WALL_IDS)
				{
					var item:WallItem = new WallItem(server, wallId);
					BindingUtils.bindSetter(onServerSelect, item, "selected");
					list.addItem(item);
				}
			}
					
			servers = list;
		}
		
		internal function onServerSelect(value:Boolean):void
		{
			refreshWallList();
		}
		
		private function refreshWallList():void
		{
			for each (var item:WallItem in servers)
			{
				if (item.selected && !selectedServers.contains(item))
					selectedServers.addItem(item);
					
				if (!item.selected && selectedServers.contains(item))
				{
					var index : int = selectedServers.getItemIndex(item);
					var wall : Wall = walls[index];
					wall.active = false;
					wall.server = null;
					selectedServers.removeItem(item);
				}
			}
		}
		
		protected function localizeName(item : WallItem) : String
		{
			return resourceBundle.getMessage(item.server.name) + " : " + item.wallId;
		}
		
		
	}
}