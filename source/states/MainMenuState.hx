package states;

import backend.MusicBeatState;
import backend.ClientPrefs;

import flixel.text.FlxText;
import flixel.FlxGame;
import flixel.addons.display.FlxRuntimeShader;
import flixel.effects.FlxFlicker;
import flixel.system.frontEnds.SoundFrontEnd;
import flixel.tweens.misc.ShakeTween;

import states.PlayState;

import openfl.filters.ShaderFilter;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';
	var camSp:FlxCamera;
        var camOpt:FlxCamera;
	
	var camHit:FlxCamera;
	
	var lol:FlxText;
	var AllOption:Array<String> = [
		'Stroyimage',
		'Freeplayimage',
		'Creditsimage',
		'Optionimage'
	];
	var nowChoose:Int = 0;
	
	var MainMenu:FlxSprite;
	var MainGroup:FlxTypedGroup<FlxSprite>;
	
	var filter:ShaderFilter;
	var bpm:Int = 25;
	var logo:FlxSprite;
	var freakyMenu:FlxSound;
	
	var idleTween:Array<FlxTween> = [];
	var sleepTween:Array<FlxTween> = [];
	
	var moveTween:FlxTween;
	var byebyeTween:FlxTween;
	var finished = false;
	
	var nowtime:Float = 0;
	var canChoose:Bool = true;
	
	var LogoAngles:Float = 3;
	var shakermax:Int = 25;
	
	
	override function create()
	{
	    var officeTime = FlxTimer().start(0.145, function(tmr:FlxTimer){FlxTimer().start(60 / bpm, function(tmr:FlxTimer){CamZoom();});});
	    var officeTimeLogo = FlxTimer().start(0.36, function(tmr:FlxTimer){FlxTimer().start(30 / bpm,function(tmr:FlxTimer) {LogoAngle();});});
	
	    freakyMenu = FlxG.sound.play(Paths.music('freakyMenu','shared'));
	    
	    camSp = new FlxCamera();
	    camOpt = new FlxCamera();
	    
	    camHit = new FlxCamera();
	    
	    camOpt.bgColor = 0x00000000;
	    camHit.bgColor = 0x00000000;
	    camOpt.height = 900;
	    
	    FlxG.cameras.add(camSp,false);
	    FlxG.cameras.add(camOpt,false);
	    FlxG.cameras.add(camHit,false);
	    
	    lol = new FlxText(0, 0, FlxG.width, "", 20);
	    
	    add(lol);
	    
	    /////
	    var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('images/MainMenu/menuBG', null, false));
		bg.scrollFactor.set(0, 0);
		bg.scale.x = FlxG.width / bg.width;
		bg.scale.y = FlxG.height / bg.height;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.cameras = [camSp];
		add(bg);
		
		logo = new FlxSprite(470, 50);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.scale.x = 0.8;
		logo.scale.y = 0.8;
		logo.cameras = [camSp];
		add(logo);
		
		MainGroup = new FlxTypedGroup<FlxSprite>();
		add(MainGroup);
		
		for (i in 0...AllOption.length) {
		    MainMenu = new FlxSprite(0, 0);
		    MainMenu.frames = Paths.getSparrowAtlas('MainMenu/MenuImage');
		    
		    MainMenu.scale.x = 0.5;
		    MainMenu.scale.y = 0.5;
		    MainMenu.x = 10;
		    MainMenu.y = i * 200 - 20;
		    MainMenu.updateHitbox();
		    //MainMenu.antialiasing = ClientPrefs.data.antialiasing;
		    MainMenu.cameras = [camOpt];
		    MainMenu.ID = i;
		    MainGroup.add(MainMenu);
		    MainMenu.animation.addByPrefix('idle', AllOption[i], 24);
		    MainMenu.animation.addByPrefix('sleep', 'sleep', 24);
		    MainMenu.animation.play('sleep');
		    
		}
		UpdateOptions();
		addTouchPad("UP_DOWN", "A_B");
		
		super.create();
		var LogoShake = FlxTimer().start(0.001, function(tmr:FlxTimer){LogoShake();});
	}
	
	override function update(elapsed:Float)
	{
	    lol.cameras = [camOpt];
	    nowtime = nowtime + 0.1;
	    createShaders('damn' ,nowtime);
	    if (freakyMenu != null){
	        freakyMenu.onComplete = function() {
	            freakyMenu = null;
	        };
	    }
	
	    camOpt.zoom = camSp.zoom;
	    
	    if (canChoose){
	        if (controls.UI_UP_P) {
	            if (moveTween != null) {
	                moveTween.cancel();
	            }
	            nowChoose--;
	            if (nowChoose < 0) nowChoose = 3;
	            UpdateOptions();
	        }else if (controls.UI_DOWN_P) {
	            if (moveTween != null) {
	                moveTween.cancel();
	            }
	            nowChoose++;
	            if (nowChoose > 3) nowChoose = 0;
	        
	            UpdateOptions();
	        }
	        if (controls.ACCEPT) {
	            FlxFlicker.flicker(MainGroup.members[nowChoose], 1.1, 0.1, false,false, function(flick:FlxFlicker)
			    {
				    switch (AllOption[nowChoose])
				    {
					    case 'Stroyimage':
						    MusicBeatState.switchState(new StoryMenuState());
					    case 'Freeplayimage':
						    MusicBeatState.switchState(new FreeplayState());
					    case 'Creditsimage':
						    MusicBeatState.switchState(new CreditsState());
					    case 'Optionimage':
						    MusicBeatState.switchState(new OptionsState());
						    OptionsState.onPlayState = false;
					    if (PlayState.SONG != null)
					    {
						    PlayState.SONG.arrowSkin = null;
						    PlayState.SONG.splashSkin = null;
						    PlayState.stageUI = 'normal';
					    }
				    }
			    });
	            FlxG.sound.play(Paths.sound('confirmMenu'));
	            canChoose = false;
	            if (moveTween != null) {
	                moveTween.cancel();
	            }
	            for (i in 0...AllOption.length){
	            var fuck = MainGroup.members[i];
	                if (i != nowChoose) {
	                    byebyeTween = FlxTween.tween(fuck, {x: -500, y: fuck.y}, 2, {ease: FlxEase.expoOut});
	                }
	            }
	        }
	    
	        if (controls.BACK)
		    {
			    canChoose = false;
			    FlxG.sound.play(Paths.sound('cancelMenu'));
			    MusicBeatState.switchState(new TitleState());
		    }
	    }
	    super.update(elapsed);
	}
	
	function createShaders(name:String ,itime:Float){
	    var frag = File.getContent(Paths.getSharedPath('shaders/' + name +'.frag'));
	    var shader = new FlxRuntimeShader(frag, null);
	    
	    filter = new ShaderFilter(shader);
	    FlxG.game.setFilters([filter]);
	    //camSp.set__filters([filter]);
	    shader.setFloat('iTime' ,itime);
	}
	
	function CamZoom(){
	    var zoomTime = FlxTimer().start(60 / bpm, function(tmr:FlxTimer){CamZoom();});
	    camSp.zoom = 1.05;	
		var cameraTween = FlxTween.tween(camSp, {zoom: 1}, 1, {ease: FlxEase.cubeOut});
	}
	
	function LogoShake(){
	    shakermax = shakermax * -1;
	         var tweenY = FlxTween.tween(logo, {y: logo.y + shakermax}, 2, {ease: FlxEase.quadInOut});
	    var LogoShake = FlxTimer().start(2, function(tmr:FlxTimer){LogoShake();});
	}
	
	function LogoAngle(){
	    
	    var angleTime = FlxTimer().start(30 / bpm, function(tmr:FlxTimer){LogoAngle();});
	     LogoAngles = LogoAngles * -1;
	     if (LogoAngles > 0) {
	         var LogoTween = FlxTween.tween(logo, {angle: LogoAngles}, 30 / bpm, {ease: FlxEase.cubeInOut});
	     }else{
	         var LogoTween = FlxTween.tween(logo, {angle: LogoAngles}, 30 / bpm, {ease: FlxEase.cubeInOut});
	     }
	}
	
	function UpdateOptions(?mods:Int){
	    FlxG.sound.play(Paths.sound('scrollMenu'));
	    for (i in 0...AllOption.length){
	        var fuck = MainGroup.members[i];
	        fuck.alpha = 1;
	        fuck.visible = true;
	        var move:FlxTween;
	        if (i == nowChoose) {
	            fuck.animation.play('idle');
	            var move = FlxTween.tween(MainGroup.members[i], {x: 0, y: MainGroup.members[i].y}, 0.1, {ease: FlxEase.expoOut});
	        }else{
	            fuck.animation.play('sleep');
	            var move = FlxTween.tween(MainGroup.members[i], {x: -50, y: MainGroup.members[i].y}, 0.1, {ease: FlxEase.expoOut});
	        }
	    }
	    
	    if (nowChoose != 3) {
		    moveTween = FlxTween.tween(camOpt, {y: 0}, 1, {ease: FlxEase.quadOut});
	    }else{
		    moveTween = FlxTween.tween(camOpt, {y: -180}, 1, {ease: FlxEase.quadOut});
		}
	}
}
