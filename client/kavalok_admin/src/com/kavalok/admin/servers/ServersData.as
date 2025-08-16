package com.kavalok.admin.servers
{
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	import com.kavalok.services.ServerService;
	
	import mx.utils.StringUtil;
	
	import org.goverla.collections.ArrayList;
	
	public class ServersData
	{
		private var bundle : ResourceBundle;

		[Bindable]
		public var servers : ArrayList = new ArrayList();
		
		public function ServersData()
		{
			bundle = Localiztion.getBundle(ResourceBundles.SERVER_SELECT);
			
			refresh();
		}

		public function refresh() : void
		{
			servers = new ArrayList();
			new ServerService(onGetServers).getAllServers();
		}
		
		private function onGetServers(result : Array) : void
		{
			for each(var server : Object in result)
			{
				server.label = getLabel(server);
			}
			servers.addItems(result);
		}

		private function getLabel(server : Object) : String
		{
			var name : String = bundle.messages[server.name] || server.name;
			return StringUtil.substitute("url: {0} \nname: {1}\nload: {2}", server.url, name, server.load);
		}
		
	}
}