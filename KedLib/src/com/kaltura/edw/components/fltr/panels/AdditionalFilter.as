package com.kaltura.edw.components.fltr.panels {
	import com.kaltura.edw.components.fltr.IFilterComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.CheckBox;

	/**
	 * dispatched when the value of the component have changed
	 */
	[Event(name = "changed", type = "flash.events.Event")]

	public class AdditionalFilter extends VBox implements IFilterComponent {


		/**
		 * the name of the field on the objects in the list to use as button label
		 */
		public var labelField:String;
		
		public var labelFunction:Function;


		protected var _mainButtonTitle:String;


		/**
		 * main button label
		 */
		public function get mainButtonTitle():String {
			return _mainButtonTitle;
		}


		/**
		 * @private
		 */
		public function set mainButtonTitle(value:String):void {
			_mainButtonTitle = value;
			if (_dataProvider) {
				createButtons();
			}
		}




		protected var _dataProvider:ArrayCollection;


		/**
		 * list of objects from which the rest of the buttons will be derived
		 */
		public function get dataProvider():ArrayCollection {
			return _dataProvider;
		}


		/**
		 * @private
		 */
		public function set dataProvider(value:ArrayCollection):void {
			_dataProvider = value;
			if (_mainButtonTitle) {
				createButtons();
			}
		}

		/**
		 * create checkboxes and a title checkbox (select all) according to dataProvider. <br/>
		 * 
		 * click on any non-title button will deselect the title.
		 * Clicking on the title will deselect all other buttons. clicking on the last button
		 * in the group will deselect it and highlight the title button. 
		 */
		protected function createButtons():void {
			while (this.numChildren > 0) {
				this.removeChildAt(0);
			}
			_buttons = new Array();
			var btn:CheckBox = new CheckBox();
			btn.percentWidth = 100;
			btn.label = _mainButtonTitle;
			btn.selected = true;
			btn.styleName = "mainFilterGroupButton";
			btn.addEventListener(MouseEvent.CLICK, onDynamicTitleClicked, false, 0, true);
			addChild(btn);
			_buttons.push(btn);
			// rest of buttons
			for (var i:int = 0; i < _dataProvider.length; i++) {
				btn = new CheckBox();
				btn.percentWidth = 100;
				btn.data = _dataProvider.getItemAt(i);
				if (labelFunction != null) {
					btn.label = labelFunction.apply(null,[_dataProvider.getItemAt(i)]);
				}
				else if (labelField) {
					btn.label = _dataProvider.getItemAt(i)[labelField];
				}
				else {
					btn.label = _dataProvider.getItemAt(i).toString();
				}
				btn.selected = false;
				btn.styleName = "innerFilterGroupButton";
				btn.addEventListener(MouseEvent.CLICK, onDynamicMemberClicked, false, 0, true);
				addChild(btn);
				_buttons.push(btn);
			}
		}

		/**
		 * remove selection indication from the button
		 * which corresponds to the given data.
		 * this is required for removing filters via indicators.
		 * @param data
		 *
		 */
		public function deselect(data:Object):void {
			//TODO implement
		}


		protected function dispatchChange():void {
			dispatchEvent(new Event("changed"));
		}



		// --------------------
		// IFilterComponent
		// --------------------


		protected var _attribute:String;


		/**
		 * Name of the <code>KalturaFilter</code> attribute this component handles
		 */
		public function set attribute(value:String):void {
			_attribute = value;
		}


		public function get attribute():String {
			return _attribute;
		}


		/**
		 * Value for the relevant attribute on <code>KalturaFilter</code>.
		 */
		public function set filter(value:Object):void {
			throw new Error("Method set filter() must be implemented");
		}


		public function get filter():Object {
			throw new Error("Method get filter() must be implemented");
			return null;
		}

		// --------------------
		// buttons
		// --------------------

		/**
		 * a list of buttons, the first one is the "all". <br>
		 * make sure to assign value in concrete panel (sub-class)
		 */
		protected var _buttons:Array;


		/**
		 * Handler for clicking on the button group title.
		 * */
		protected function onDynamicTitleClicked(event:MouseEvent):void {
			var titleBtn:Button = event.target as Button;

			//if the title is selected unselect all the 
			if (titleBtn.selected) {
				for (var i:int = 1; i < _buttons.length; i++) {
					_buttons[i].selected = false;
				}

//				updateImageButton(btnArr);
				dispatchChange();
			}
			else {
				//the title can't be unselected if it was selected before
				titleBtn.selected = true;
			}
		}


		/**
		 * Handler for clicking an individual member of a button group.
		 * */
		protected function onDynamicMemberClicked(event:MouseEvent):void {
			var i:int;
			var selectTheTitle:Boolean = true;
			//if we unselected a member we should go over and see if we need to select the title 
			if (!(event.target as Button).selected) {
				for (i = 1; i < _buttons.length; i++) {
					if (_buttons[i].selected)
						selectTheTitle = false;
				}

				if (selectTheTitle)
					_buttons[0].selected = true;
			}
			else {
				// if any of the members has been selected shut down the title
				_buttons[0].selected = false;
			}

//			updateImageButton(btnArr);
			dispatchChange();
		}
	}
}