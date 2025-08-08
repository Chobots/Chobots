package com.kavalok.pets
{
	import com.kavalok.Global;
	import com.kavalok.char.Directions;
	import com.kavalok.dialogs.Dialogs;
	import com.kavalok.dto.pet.PetTO;
	import com.kavalok.gameplay.KavalokConstants;
	import com.kavalok.gameplay.commands.MoneyAnimCommand;
	import com.kavalok.gameplay.commands.RegisterGuestCommand;
	import com.kavalok.gameplay.controls.ColorPicker;
	import com.kavalok.gameplay.controls.InputText;
	import com.kavalok.utils.GraphUtils;
	import com.kavalok.utils.ResourceScanner;
	
	import flash.events.MouseEvent;
	
	public class PetConstructor
	{
		private var _content:McPetsConstructor = new McPetsConstructor();
		private var _pageSelector:PageSelector = new PageSelector(_content);
		private var _colorPicker:ColorPicker = new ColorPicker(_content.colorPicker);
		private var _itemsView:ItemsView = new ItemsView();
		private var _nameField:InputText = new InputText(_content.nameField);
		private var _pet:PetTO;
		private var _petModel:PetModel;
		
		public function PetConstructor()
		{
			_content.closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
			_content.acceptButton.addEventListener(MouseEvent.CLICK, onAcceptClick);
			_content.rotateLeftButton.addEventListener(MouseEvent.CLICK, rotateLeft);
			_content.rotateRightButton.addEventListener(MouseEvent.CLICK, rotateRight);
			
			_pageSelector.pageChange.addListener(onPageChange);
			
			GraphUtils.removeChildren(_content.itemsClip);
			_content.itemsClip.addChild(_itemsView.content);
			_itemsView.selectionChange.addListener(onItemSelect);
			
			
			_colorPicker.clickEvent.addListener(refresh);
			_nameField.field.restrict = KavalokConstants.PET_CHARS;
			_nameField.field.maxChars = 10;
			_nameField.emptyText = module.bundle.messages.inputName;
			
			new ResourceScanner().apply(_content);
			
			initPet();
			onPageChange();
			refresh();
		}
		
		private function initPet():void
		{
			_pet = new PetTO();
			_pet.atHome = true;
			_petModel = new PetModel(_pet);
			_petModel.scale = 3;
			
			
			_content.addChild(_petModel);
			_petModel.x = _content.petPosition.x;
			_petModel.y = _content.petPosition.y;
			_content.petPosition.visible = false;
			
			_petModel.setModel(PetModels.STAY, Directions.DOWN);
			_petModel.pet = _pet;
		}
		
		private function rotateLeft(e:MouseEvent):void
		{
			_petModel.rotateLeft();
		}
		
		private function rotateRight(e:MouseEvent):void
		{
			_petModel.rotateRight();
		}
		
		private function onItemSelect():void
		{
			refresh();
		}
		
		private function refresh(sender:Object = null):void
		{
			var item:PetItem = _itemsView.selectedItem;
			_pet[item.placement] = item.name;
			_pet[item.placement + 'Color'] = _colorPicker.color;
			
			_petModel.pet = _pet;
			
			_content.priceField.text = getPetPrice().toString();
		}
		
		private function getPetPrice():int
		{
			var itemNames:Array = _pet.items;
			var price:int = 0;
			
			for each (var itemName:String in itemNames)
			{
				if (itemName)
				{
					var petItem:PetItem = module.getItemByName(itemName);
					if (petItem)
						price += petItem.price;
				}
			}
			
			return price;
		}
		
		private function onPageChange():void
		{
			var items:Array = module.getItems(_pageSelector.placement);
			var currentItemName:String = _pet[_pageSelector.placement];
			
			_itemsView.setItems(items);
			var selected:PetItem = module.getItemByName(currentItemName);
			if (!selected && items && items.length > 0)
			{
				selected = items[0];
			}
			if (selected)
			{
				_itemsView.selectedItem = selected;
			}
			
			_petModel.setModel(PetModels.STAY, Directions.DOWN);
			
			module.bundle.registerTextField(_content.tipField, _pageSelector.selectedItem.name);
		}
		
		private function onCloseClick(e:MouseEvent):void
		{
			module.closeModule();
		}
		
		private function onAcceptClick(e:MouseEvent):void
		{
			if (Global.charManager.isGuest || Global.charManager.isNotActivated){
				module.closeModule();
				new RegisterGuestCommand().execute();
				return;
			}
			var price:int = getPetPrice();
			
			if (Global.charManager.money < price)
			{
				Dialogs.showOkDialog(Global.messages.noMoney);
			}
			else if (_nameField.isEmpty)
			{
				_nameField.blink();
			}
			else
			{
				_pet.name = _nameField.value;
				new SavePetCommand(_pet, onSave).execute();
			}
		}
		
		private function onSave():void
		{
			new MoneyAnimCommand(-getPetPrice()).execute();
			Global.charManager.refreshMoney();
			module.closeModule();
		}
		
		protected function get module():Pets
		{
			return Pets.instance;
		}
		
		public function get content():McPetsConstructor { return _content; }
	}
	
}