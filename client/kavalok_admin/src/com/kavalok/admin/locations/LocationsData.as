package com.kavalok.admin.locations
{
	import com.kavalok.constants.Locations;
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	
	import org.goverla.collections.ArrayList;
	
	/**
	 * ...
	 * @author Canab
	 */
	public class LocationsData
	{
		[Bindable]
		public var locations:ArrayList = new ArrayList();
		
		private var _bundle:ResourceBundle;
		
		public function LocationsData()
		{
			_bundle = Localiztion.getBundle(ResourceBundles.KAVALOK);
			
			refresh();
		}
		
		public function refresh():void
		{
			locations = new ArrayList();
			
			for each (var locId:String in com.kavalok.constants.Locations.list)
			{
				addLocation(locId);
			}
		}
		
		private function addLocation(locId:String):void
		{
			var locInfo:Object =
			{
				locationId: locId,
				remoteId: locId,
				label: getLabel(locId)
			}
			
			locations.addItem(locInfo);
		}
		
		private function getLabel(locId:String):String
		{
			return locId + ' (' + _bundle.messages[locId] + ')';
		}
		
	}
	
}