package com.kavalok.admin.magic
{
	import com.kavalok.dto.stuff.StuffTypeTO;
	import com.kavalok.location.commands.StuffRainCommand;
	import com.kavalok.services.AdminService;
	import mx.controls.List;
	import org.goverla.collections.ArrayList;
	
	/**
	 * ...
	 * @author Canab
	 */
	
	public class RainBase extends MagicViewBase
	{
		
		[Bindable]
		public var stuffList:ArrayList = new ArrayList();
		
		[Bindable]
		public var stuffCombo:List;
		
		public function RainBase()
		{
			super();
			StuffTypeTO.initialize();
			refreshList();
		}
		
		protected function refreshList():void 
		{
			new AdminService(onResult).getRainableStuffs();
		}
		
		private function onResult(result:Array):void
		{
			stuffList = new ArrayList(result);
		}
		
		public function onSendClick():void
		{
			new AdminService().triggerRainEventWithLocation(stuffType.fileName, 1, serverId, remoteId);
		}
		
		public function get stuffType():StuffTypeTO
		{
			return StuffTypeTO(stuffCombo.selectedItem);
		}
		
	}
	
}