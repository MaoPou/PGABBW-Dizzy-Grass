package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import backend.Paths;

import flixel.effects.FlxFlicker;
import flixel.text.FlxText;

class StoryMenuState extends MusicBeatState
{
    var bgCamera:FlxCamera;
    var debugCamera:FlxCamera;
    var WeekBG:FlxSprite;
    var UpBlackRect:FlxSprite;
    var DownBlackRect:FlxSprite;
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;

    public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

    var nowChoose:Int;
    //WeekData就是week文件里的json
    var loadedWeeks:Array<Dynamic> = [
        {
	        "songs": [
	    	    ["Tutorial", "gf", [165, 0, 77]]
	        ],

	        "weekCharacters": [
	        	"",
	    	    "bf",
		        "gf"
	        ],
	       "weekBackground": "stage",

	        "storyName": "",
	        "weekBefore": "tutorial",
	        "weekName": "Tutorial",
	        "startUnlocked": true,

	        "hideStoryMode": false,
	        "hideFreeplay": false
        }
    ];
	override function create()
	{
	    PlayState.isStoryMode = true;
	    bgCamera = new FlxCamera();
	    debugCamera = new FlxCamera();
	    
	    FlxG.cameras.add(bgCamera,false);
	    FlxG.cameras.add(debugCamera,false);
	    
	    bgCamera.bgColor.alpha = 0;
	    debugCamera.bgColor.alpha = 0;
	    
	    var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.cameras = [bgCamera];
		bg.screenCenter();
		
		WeekBG = new FlxSprite().loadGraphic(Paths.image('StoryMenu/Week1BG'));
		add(WeekBG);
		//WeekBG.scale.x = WeekBG.scale.y = 0.9;
		WeekBG.cameras = [bgCamera];
		PlayState.instance.luaDebugGroup.cameras = [debugCamera];
		
		UpBlackRect = new FlxSprite(0, 0).makeGraphic(FlxG.width, 110, FlxColor.BLACK);
	    
	    add(UpBlackRect);
	    UpBlackRect.cameras = [bgCamera];
	    
	    
	    DownBlackRect = new FlxSprite(0, 0).makeGraphic(FlxG.width, 110, FlxColor.BLACK);
	    
	    add(DownBlackRect);
	    DownBlackRect.cameras = [bgCamera];
	    DownBlackRect.y = FlxG.height - 110;
	    
	    var title:FlxText = new FlxText(12, 0, 0, 'WEEK / ', 90);
	    title.setFormat(Paths.font("em.ttf"),90);
	    add(title);
	    title.cameras = [bgCamera];
	    
	    var title2:FlxText = new FlxText(title.x + title.width, 14, 0, '喜羊羊与灰太狼之迷糊草', 80);
	    title2.setFormat(Paths.font("em.ttf"),80);
	    add(title2);
	    title2.cameras = [bgCamera];
	    
	    var title3:FlxText = new FlxText(1000, 620, 0, '青青草原原本是个很和谐\n的地方，但是突然来的屠\n杀破坏的宁静，我们将以\nBOYFRIEND 视角来打败\n"喜羊羊"并拯救草原', 20);
	    title3.setFormat(Paths.font("em.ttf"),20);
	    add(title3);
	    title3.cameras = [bgCamera];
	    
	    var title4:FlxText = new FlxText(800, 630, 0, '简介：', 60);
	    title4.setFormat(Paths.font("em.ttf"),60);
	    add(title4);
	    title4.cameras = [bgCamera];
	    
	    leftArrow = new FlxSprite(0,FlxG.height / 2).loadGraphic(Paths.image('StoryMenu/Arrow'));
	    leftArrow.cameras = [bgCamera];
	    leftArrow.angle = 180;
	    add(leftArrow);
	    
	    rightArrow = new FlxSprite(FlxG.width - leftArrow.width,FlxG.height / 2).loadGraphic(Paths.image('StoryMenu/Arrow'));
	    rightArrow.cameras = [bgCamera];
	    add(rightArrow);
	    
	    addTouchPad("LEFT_RIGHT", "A_B");
	    super.create();
	}
	
	override function update(elapsed:Float)
	{
	    if (nowChoose < 0) nowChoose = loadedWeeks.length;
	    if (nowChoose > loadedWeeks.length) nowChoose = 0;
	    
	    if (controls.UI_LEFT_P){
	        nowChoose--;
	        FlxG.sound.play(Paths.sound('scrollMenu'));
	    }
	    if (controls.UI_RIGHT_P){
	        nowChoose++;
	        FlxG.sound.play(Paths.sound('scrollMenu'));
	    }
	    if (controls.ACCEPT){
	        FlxG.sound.play(Paths.sound('confirmMenu'));
	        bgCamera.zoom = 1.1;
	        FlxTween.tween(bgCamera, {zoom: 1}, 2, {ease: FlxEase.expoOut});
	        FlxFlicker.flicker(WeekBG, 1, 0.1, true, false, function(fxl:FlxFlicker){
	            selectWeek();
	        });
	        
	    }
	    if (controls.BACK)
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
	    super.update(elapsed);
	}
	
	function selectWeek()
	{
		if (loadedWeeks[nowChoose].startUnlocked)
		{
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[nowChoose].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;
				
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
		else FlxG.sound.play(Paths.sound('cancelMenu'));
	}
}
