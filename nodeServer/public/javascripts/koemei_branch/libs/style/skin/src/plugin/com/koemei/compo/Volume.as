package com.koemei.compo
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import com.longtailvideo.jwplayer.player.IPlayer;
	
	import com.koemei.Plugin;
	import com.koemei.utils.util;
	
	public class Volume extends MovieClip
	{
		private var player:IPlayer;
		private var vSlider:VolumeSlider;
		
		private var vBtn:MovieClip;
		private var vol:Number = 0;
		
		/** Out time of Volume button **/
		//private var timeOutVolume:Number;
		
		/** Time to update volume when dragging **/
		private var volumeInterval:Number;
		
		private const volumeIconHeight:Number = 5;
		
		public function Volume(_player:IPlayer, _vSlider:VolumeSlider):void
		{
			player = _player;
			vSlider = _vSlider;
			
			vSlider.hitVolume.buttonMode = true;
			vSlider.icon.addEventListener(MouseEvent.MOUSE_OVER, onIconOver);
			vSlider.icon.addEventListener(MouseEvent.MOUSE_OUT, onIconOut);
			vSlider.icon.addEventListener(MouseEvent.MOUSE_DOWN, onVolumeIconDown);
			vSlider.hitVolume.addEventListener(MouseEvent.MOUSE_UP, volumeClickHandler);
			vSlider.icon.y = vSlider.rail.y + volumeIconHeight + (vSlider.rail.height-volumeIconHeight*2)*(100-player.config.volume)/100;
			
			vBtn = player.controls.controlbar.addButton(this, "VolumeBtn", onVolumeBtnClick);
			//vBtn.y = util.barHeightMin2;
			vBtn.addEventListener(MouseEvent.MOUSE_OVER, onVolumeBtnOver);
			vBtn.addEventListener(MouseEvent.MOUSE_OUT, onVolumeBtnOut);
			volumeUpdate();
			
			resize();
		}
		
		private function onIconOver(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.HAND;
		}
		
		private function onIconOut(event:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private function onVolumeBtnClick(evt:MouseEvent):void
		{
			if(this.currentFrame != 4)
			{
				vol = player.config.volume;
				vSlider.icon.y = vSlider.rail.y + volumeIconHeight + (vSlider.rail.height-volumeIconHeight*2);
			}else
			{
				if(player.config.volume == 0 && vol == 0)
					vol = 80;
				vSlider.icon.y = vSlider.rail.y + volumeIconHeight + (vSlider.rail.height-volumeIconHeight*2)*(100-vol)/100;
			}
			volumeUpdate();
		}
		
		private function onVolumeBtnOver(evt:MouseEvent):void
		{
			vSlider.visible = true;
		}
		
		private function onVolumeBtnOut(evt:MouseEvent=null):void
		{
			if(!vSlider.hitTestPoint(stage.mouseX, stage.mouseY))
				TimeOutVolume();
			else
				vSlider.addEventListener(MouseEvent.MOUSE_OUT, onVolumeBoardOut);
		}
		
		private function onVolumeBoardOut(evt:MouseEvent):void
		{
			//trace("a", vSlider.hitTestPoint(stage.mouseX, stage.mouseY), this.hitTestPoint(stage.mouseX, stage.mouseY));
			if(!vSlider.hitTestPoint(stage.mouseX, stage.mouseY) && !this.hitTestPoint(stage.mouseX, stage.mouseY))
			{
				vSlider.removeEventListener(MouseEvent.MOUSE_OUT, onVolumeBoardOut);
				TimeOutVolume();
			}
		}
		
		private function TimeOutVolume():void
		{
			vSlider.visible = false;
		}
		
		/** Handle mouse presses on volumeSlider icon. **/
		private function onVolumeIconDown(evt:MouseEvent):void
		{
			var rct:Rectangle = new Rectangle(10.5, 9, 0, 63);
			vSlider.icon.startDrag(true,rct);
			volumeInterval = setInterval(volumeUpdate, 10);
			stage.addEventListener(MouseEvent.MOUSE_UP, volumeStopUpdate);
		}
		
		/** Handle click on volume slider **/
		private function volumeClickHandler(evt:MouseEvent):void {		
			var mpl:Number = 100;
			var yv:Number = vSlider.hitVolume.y + vSlider.hitVolume.mouseY;
			if (yv>74) yv = 74;
			if (yv<15) yv = 15;
			vSlider.icon.y = yv;
			volumeUpdate();
		}
		
		private function volumeUpdate():void
		{
			//var pct:Number = (vSlider.rail.height-(vSlider.icon.y-vSlider.rail.y)) / (vSlider.rail.height) * 100;
			var pct:Number = (vSlider.rail.height-volumeIconHeight*2-(vSlider.icon.y-vSlider.rail.y-volumeIconHeight)) / (vSlider.rail.height-volumeIconHeight*2) * 100;
			player.volume(pct);
			if(pct == 0)
				this.gotoAndStop(4);
			else if(pct < 34)
				this.gotoAndStop(3);
			else if(pct < 67)
				this.gotoAndStop(2);
			else
				this.gotoAndStop(1);
			vSlider.shade.scaleY = pct/100;
		}
		
		private function volumeStopUpdate(evt:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, volumeStopUpdate);
			clearInterval(volumeInterval);
			vSlider.icon.stopDrag();
		}
		
		public function resize():void
		{
			//vSlider.x = player.controls.controlbar.x + vBtn.x + vSlider.width/2 - 1;
			vSlider.x = player.controls.controlbar.x + vBtn.x + 5;
			
			//vSlider.y = stage.stageHeight - util.controlbarHeight - vSlider.height + util.barHeightMin2;
			vSlider.y = player.controls.controlbar.y - vSlider.height + util.barHeightMin2;
		}
		
	}
	
}
