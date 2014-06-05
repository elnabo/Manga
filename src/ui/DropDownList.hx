package ui;

import db.Manga;
import haxe.ui.toolkit.controls.selection.ListSelector;

class DropDownList extends ListSelector
{
	public function new()
	{
		super();
		method = "default";
		styleName = "dropdown";
		text = "Select a manga from this list";
		for (manga in Manga.manager.all())
		{
			dataSource.add({text:manga.name});
		}
	}
	
	override public function showList():Void
	{
		dataSource.removeAll();
		for (manga in Manga.manager.all())
		{
			dataSource.add({text:manga.name});
		}
		super.showList();
	}
}
