const rl = @import("raylib");
const env = @import("environment.zig");
const game = @import("game.zig");

pub fn main() anyerror!void {
    rl.initWindow(env.SCREEN_WIDTH, env.SCREEN_HEIGHT, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    // init audio
    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    // load music
    const bgm = rl.loadMusicStream("resources/env/bgm.mp3");

    rl.setTargetFPS(30);

    // init game
    var g = game.Game.init();
    defer g.deinit();

    // init env
    var e = env.Ground.init();
    defer e.deinit();

    // play bgm
    rl.playMusicStream(bgm);
    var pause: bool = false;

    while (!rl.windowShouldClose()) {
        // update music
        rl.updateMusicStream(bgm);

        // pause bgm
        if (rl.isKeyPressed(rl.KeyboardKey.key_p)) {
            pause = !pause;

            if (pause) rl.pauseMusicStream(bgm) else rl.resumeMusicStream(bgm);
        }

        // volume bgm
        if (rl.isKeyPressed(rl.KeyboardKey.key_up)) {
            // set up volume bgm 20%
            rl.setMusicVolume(bgm, 1.0);
        } else if (rl.isKeyPressed(rl.KeyboardKey.key_down)) {
            // set down volume bgm 20%
            rl.setMusicVolume(bgm, 0.2);
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        // background and environment base
        e.drawGround();

        // game
        g.start();
    }

    // undload music
    rl.unloadMusicStream(bgm);
}
