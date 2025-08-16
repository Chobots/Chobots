package com.kavalok.admin.users
{
	import com.kavalok.Global;
	import com.kavalok.admin.log.data.UserChatDataProvider;
	import com.kavalok.admin.users.data.FilterConfig;
	import com.kavalok.admin.users.data.LocalizationConverter;
	import com.kavalok.admin.users.data.ServersDataProvider;
	import com.kavalok.admin.users.data.UsersDataProvider;
	import com.kavalok.admin.users.filters.BooleanFilter;
	import com.kavalok.admin.users.filters.FiltersList;
	import com.kavalok.admin.users.filters.NumberFilter;
	import com.kavalok.admin.users.filters.StringFilter;
	import com.kavalok.constants.ResourceBundles;
	import com.kavalok.dto.UserTO;
	import com.kavalok.dto.admin.FilterTO;
	import com.kavalok.localization.Localiztion;
	import com.kavalok.localization.ResourceBundle;
	
	import flash.events.MouseEvent;
	
	import mx.containers.VBox;
	import mx.controls.ComboBox;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.ListEvent;
	
	import org.goverla.collections.ArrayList;
	import org.goverla.utils.Arrays;
	import org.goverla.utils.Strings;

	public class UsersBase extends VBox
	{
		public var filtersList : FiltersList;
		public var serverComboBox : ComboBox;
		public var usersDataGrid : DataGrid;
		
		[Bindable]
		public var permissionLevel : int;
		
		
		private var resourceBundle : ResourceBundle;

		[Bindable]
		protected var serversDataProvider : ServersDataProvider = new ServersDataProvider();

		[Bindable]
		protected var filtersConfig : ArrayList = new ArrayList();

		[Bindable]
		protected var filtersData : ArrayList = new ArrayList();
		
		[Bindable]
		protected var selectedUser : UserTO;
		[Bindable]
		protected var users : UsersDataProvider = new UsersDataProvider();
		[Bindable]
		protected var userChatDataProvider : UserChatDataProvider = new UserChatDataProvider();
		
		public function UsersBase()
		{
			super();
			
			resourceBundle = Localiztion.getBundle(ResourceBundles.SERVER_SELECT);
			
			filtersConfig.addItem(new FilterConfig("login", StringFilter, ""));
			filtersConfig.addItem(new FilterConfig("email", StringFilter, ""));
			filtersConfig.addItem(new FilterConfig("citizen", BooleanFilter, false));
			filtersConfig.addItem(new FilterConfig("age", NumberFilter));
			filtersConfig.addItem(new FilterConfig("enabled", BooleanFilter, false));
			filtersConfig.addItem(new FilterConfig("baned", BooleanFilter, false));
			filtersConfig.addItem(new FilterConfig("helpEnabled", BooleanFilter, false));
			filtersConfig.addItem(new FilterConfig("parent", BooleanFilter, false));
			filtersConfig.addItem(new FilterConfig("agent", BooleanFilter, false));
			filtersConfig.addItem(new FilterConfig("moderator", BooleanFilter, false));
			filtersConfig.addItem(new FilterConfig("locale", StringFilter, false));
		}
		
		protected function getLocations(data : Object, column : DataGridColumn) : String
		{
			if(data.locations == null)
				return "";
			var locationsString : String = Strings.removeSymbols(data.locations, "[]");
			var locations : Array = locationsString.split(",");
			var localized : ArrayList = Arrays.getConverted(new ArrayList(locations), new LocalizationConverter(Global.resourceBundles.kavalok));
			return localized.toArray().join(", ");
		}
		protected function getServerName(data : Object, column : DataGridColumn) : String
		{
			return resourceBundle.messages[data.server] || "";
		}
		protected function localizeName(server : Object) : String
		{
			if(Strings.isBlank(server.name))
				return "Any";
			return resourceBundle.messages[server.name] || server.name;
		}
		
		public function showFamily(email : String) : void
		{
			var filter : FilterTO = new FilterTO("email", StringFilter, email);
			filtersData = new ArrayList();
			filtersData.addItem(filter);
			users.filters = filtersData;
			users.reload();
		}
		protected function onItemClick(event : ListEvent) : void
		{
			selectedUser = UserTO(event.itemRenderer.data);
			userChatDataProvider.reload(selectedUser.userId);
		}
		
		protected function onServerChange(event : ListEvent) : void
		{
			users.server = serverComboBox.selectedItem.id;
		}
		
		protected function onRefreshClick(event : MouseEvent) : void
		{
			users.filters = filtersList.dataProvider;
			users.changePage(0);
		}
	}
}