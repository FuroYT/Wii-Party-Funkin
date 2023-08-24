enum abstract PlayStateHUDS(Int) {
    var DEFAULT;
    var MARIO_KART;
    var MARIO_BROS;
}

class Huds {
    public static function applyHUD(instance:PlayState, hud:PlayStateHUDS) {
        switch (hud)
        {
            case MARIO_KART:
                instance.healthBar.alpha = 0;
                @:privateAccess
                instance.healthBarBG.alpha = 0;

            case MARIO_BROS:

            case DEFAULT:
                return;
        }
    }
}