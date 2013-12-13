package com.koemei
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.player.IPlayer;
	//import com.longtailvideo.jwplayer.player.PlayerState;
	//import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.ComponentEvent;
	import com.longtailvideo.jwplayer.utils.Strings;
	
	import com.koemei.compo.Volume;
	import com.koemei.compo.Time;
	//import com.koemei.utils.util;
	
	public class Plugin extends Sprite implements IPlugin
	{
		private var player:IPlayer;
		//private var config:PluginConfig;
		
		private var volume:Volume;
		private var vSlider:VolumeSlider;
		private var time:Time;
		
		public function get id():String
		{
			return "plugin";
		}
		
		public function Plugin():void
		{
		}
		
		public function initPlugin(_player:IPlayer, _config:PluginConfig):void
		{
			player = _player;
			//config = _config;
			
			vSlider =  new VolumeSlider();
			vSlider.visible = false;
			this.addChild(vSlider);
			
			volume = new Volume(_player, vSlider);
			
			time = new Time();
			this.addChild(time);
			
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, timeHandler);
			
			player.controls.controlbar.addEventListener(ComponentEvent.JWPLAYER_COMPONENT_SHOW, barShowHandler);
			player.controls.controlbar.addEventListener(ComponentEvent.JWPLAYER_COMPONENT_HIDE, barHideHandler);
		}
		
		private function barShowHandler(evt:Event):void
		{
			if(time != null)
				time.show();
		}
		
		private function barHideHandler(evt:Event):void
		{
			if(time != null)
				time.hidden();
		}
		
		/*private function stateHandler(evt:PlayerStateEvent):void
		{
			switch (evt.newstate)
			{
				case PlayerState.PAUSED :
					shoPostRoll();
					break;
				case PlayerState.PLAYING :
					hiddenPostRoll();
					break;
			}
		}*/
		
		private function timeHandler(evt:MediaEvent):void
		{
			time.update(Strings.digits(evt.position) + " / " + Strings.digits(evt.duration));
		}

		public function resize(wid:Number, hei:Number):void
		{
			if(volume != null)
				volume.resize();
			
			if(time != null)
				time.resize(player.controls.controlbar.x + player.controls.controlbar.width, player.controls.controlbar.y);
				//time.resize(player.controls.controlbar.x, player.controls.controlbar.y);
		}
		
	}
	
}