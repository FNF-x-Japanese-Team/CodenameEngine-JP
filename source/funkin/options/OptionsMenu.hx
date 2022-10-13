package funkin.options;

import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.Alphabet;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
import funkin.menus.MainMenuState;

class OptionsMenu extends MusicBeatState {
    public static var fromPlayState:Bool = false;
    public var options = [
        {
            name: 'Controls',
            desc: 'Change Controls for Player 1 and Player 2!',
            state: funkin.options.KeybindsOptions
        },
        {
            name: 'Visuals',
            desc: 'Change Gameplay options such as Downscroll, Scroll Speed...',
            state: null
        }
    ];

    public var curSelected:Int = -1;
    public var canSelect:Bool = true;
    public var alphabets:FlxTypedGroup<Alphabet>;

    public function new(?fromPlayState:Bool) {
        super();
        if (fromPlayState != null) OptionsMenu.fromPlayState = fromPlayState;
    }
    public override function create() {
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBGBlue'));
        bg.scrollFactor.set();
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        super.create();
        alphabets = new FlxTypedGroup<Alphabet>();
        for(k=>e in options) {
            var alphabet = new Alphabet(0, (k+1) * 100, e.name, true, false);
            alphabet.screenCenter(X);
            alphabets.add(alphabet);
        }
        add(alphabets);
        changeSelection(1);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (!canSelect) return;
        changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0));
        if (controls.ACCEPT && alphabets.members[curSelected] != null) {
            CoolUtil.playMenuSFX(1);
            FlxFlicker.flicker(alphabets.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
            {
                FlxTransitionableState.skipNextTransIn = true;
                FlxTransitionableState.skipNextTransOut = true;
                FlxG.switchState(Type.createInstance(options[curSelected].state, []));
            });
        } else if (controls.BACK) {
            if (fromPlayState)
                FlxG.switchState(new PlayState());
            else
                FlxG.switchState(new MainMenuState());
        }
    }
    
    public function changeSelection(change:Int) {
        if (change == 0) return;
        CoolUtil.playMenuSFX(0, 0.4);
        curSelected = FlxMath.wrap(curSelected + change, 0, options.length-1);
        alphabets.forEach(function(e) {
            e.alpha = 0.6;
        });
        if (alphabets.members[curSelected] != null) alphabets.members[curSelected].alpha = 1;
    }
}