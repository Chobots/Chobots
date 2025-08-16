package com.kavalok.admin.usersman
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

	public class UsersManagementBase extends VBox
	{
		public var filtersList : FiltersList;
		public var usersDataGrid : DataGrid;
		
		[Bindable]
		public var permissionLevel : int;
		
		
		private var resourceBundle : ResourceBundle;

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
		
		public function UsersManagementBase()
		{
			super();
			
			resourceBundle = Localiztion.getBundle(ResourceBundles.SERVER_SELECT);
			
			filtersConfig.addItem(new FilterConfig("login", StringFilter, ""));
			filtersConfig.addItem(new FilterConfig("email", StringFilter, ""));
		}
		
		protected function onItemClick(event : ListEvent) : void
		{
			selectedUser = UserTO(event.itemRenderer.data);
			userChatDataProvider.reload(selectedUser.userId);
		}
		
		protected function onRefreshClick(event : MouseEvent) : void
		{
			users.filters = filtersList.dataProvider;
			users.changePage(0);
		}
	}
}