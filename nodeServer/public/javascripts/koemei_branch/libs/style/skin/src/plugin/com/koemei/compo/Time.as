package com.koemei.compo
{
	import flash.display.Sprite;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	
	import com.koemei.utils.util;
	
	public class Time extends Sprite
	{
		private var _font:Font;
		private var _format:TextFormat;
		private var _label:TextField;
		
		public function Time():void
		{
			_font = new ProximaNova();
			
			_format = new TextFormat();
			_format.font = _font.fontName;
			_format.color = 0xFFFEFE;
			_format.size = 17;
			
			_label = new TextField();
			_label.autoSize = TextFieldAutoSize.RIGHT;		//"left"
			_label.embedFonts = true;
			_label.antiAliasType = AntiAliasType.ADVANCED;
			_label.cacheAsBitmap = true;
			_label.selectable = false;
			_label.defaultTextFormat= _format;
			
			this.addChild(_label);
		}
		
		//public function update(_elapsed:Number, _duration:Number):void
		//_label.text = _elapsed + " / " + _duration;
		public function update(_time:String):void
		{
			trace(_label.x, _label.width, _label.y, _label.height);
			_label.text = _time;
		}
		
		public function show():void
		{
			this.visible = true;
		}
		
		public function hidden():void
		{
			this.visible = false;
		}
		
		public function resize(_barX:Number, _barY:Number):void
		{
			_label.x = _barX - _label.width - util.timerMarginLeft;
			_label.y = _barY - util.timerMarginBottom;
			//_label.y = _barY - _label.height- util.timerMarginBottom;
		}
		
	}
	
}
