package com.kavalok.admin.users.data
{
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.services.ServerService;
	
	import org.goverla.collections.ArrayList;
	import org.goverla.utils.Arrays;
	import org.goverla.utils.comparing.PropertyCompareRequirement;
	
	public class ServersDataProvider
	{
		[Bindable]
		public var list : ArrayList;
		
		private var bundle : ResourceBundle;

		public function ServersDataProvider()
		{
			bundle = Localiztion.getBundle(ResourceBundles.SERVER_SELECT);
			
			new ServerService(onResult).getServers();
		}
		
		private function onResult(result : Array) : void
		{
			result.unshift({name : "ALL", id:-1});
			result.unshift({name : "", id:-2});
			list = new ArrayList(result);
		}
		
		public function getIndexById(id:int):int
		{
			return Arrays.indexByRequirement(list, new PropertyCompareRequirement('id', id));
		}

	}
}