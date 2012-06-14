package com.kaltura.kmc.modules.content.commands.cat
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.kaltura.commands.MultiRequest;
	import com.kaltura.commands.category.CategoryGet;
	import com.kaltura.commands.categoryUser.CategoryUserAdd;
	import com.kaltura.events.KalturaEvent;
	import com.kaltura.kmc.modules.content.commands.KalturaCommand;
	import com.kaltura.kmc.modules.content.events.CategoryEvent;
	import com.kaltura.vo.KalturaCategory;
	import com.kaltura.vo.KalturaCategoryUser;
	import com.kaltura.vo.KalturaUser;
	
	import mx.collections.ArrayCollection;

	public class addCategoryUsersCommand extends KalturaCommand {
		
		override public function execute(event:CairngormEvent):void {
			_model.increaseLoadCounter();
			// event.data is [categoryid, permission level, update method, ([KalturaUsers])]
			var catid:int = event.data[0];
			var permLvl:int = event.data[1];
			var mthd:int = event.data[2];
			var usrs:ArrayCollection = event.data[3];
			
			var mr:MultiRequest = new MultiRequest();
			var cu:KalturaCategoryUser;
			
			for (var i:int = 0; i<usrs.length; i++) {
				cu = new KalturaCategoryUser();
				cu.categoryId = catid;
				cu.permissionLevel = permLvl;
				cu.updateMethod = mthd;
				cu.userId = (usrs[i] as KalturaUser).id;
				mr.addAction(new CategoryUserAdd(cu));
			} 	
			var getCat:CategoryGet = new CategoryGet(catid);
			mr.addAction(getCat);
			mr.addEventListener(KalturaEvent.COMPLETE, result);
			mr.addEventListener(KalturaEvent.FAILED, fault);
			_model.context.kc.post(mr);	   
		}
		
		override public function result(data:Object):void {
			super.result(data);
			if (!checkError(data)) {
				// get updated list of users
				var cg:CategoryEvent = new CategoryEvent(CategoryEvent.LIST_CATEGORY_USERS);
				cg.dispatch();
				// set new numbers of members to the category object
				var updatedCat:KalturaCategory = data.data[data.data.length-1] as KalturaCategory;
				_model.categoriesModel.selectedCategory.membersCount = updatedCat.membersCount;
				_model.categoriesModel.selectedCategory.pendingMembersCount = updatedCat.pendingMembersCount;
			}
			_model.decreaseLoadCounter();
		}
	}
}