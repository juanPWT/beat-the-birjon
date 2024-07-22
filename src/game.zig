const std = @import("std");
const rl = @import("raylib");
const env = @import("environment.zig");
const villain_algo = @import("villain_algo.zig");

pub const forgroundSize = 200;
const charScale = 3.3;

const PlayerChoiceSuit = struct {
    id: u8,
    texture: rl.Texture2D,
};

// mc choice suit
var mcChoiceSuit: PlayerChoiceSuit = PlayerChoiceSuit{ .id = 0, .texture = undefined };

// birjon choice suit
var birjonChoiceSuit: PlayerChoiceSuit = PlayerChoiceSuit{ .id = 0, .texture = undefined };

// birjon random suit
var birjonRandSuit: villain_algo.SuitProp = undefined;

// timer for delay
var reseyDelayStart: ?i64 = null;

pub const Game = struct {
    mc: env.MainCharacter,
    birjon: env.Villain,
    suit: env.Suit,

    pub fn init() Game {
        // player
        // birjon
        const birjonTexture = rl.Texture2D.init("resources/birjon/birjon-base.png");
        const birjonKnockTexture = rl.Texture2D.init("resources/birjon/birjon-knock.png");
        // bang al
        const bangalTexture = rl.Texture2D.init("resources/bang-al/bang-al.png");
        const bangalKnockTexture = rl.Texture2D.init("resources/bang-al/bang-al-knock.png");

        return Game{
            .mc = env.MainCharacter.init(100, 150, env.SCREEN_HEIGHT / 2 + 55, charScale, bangalTexture, bangalKnockTexture),
            .birjon = env.Villain.init(100, env.SCREEN_WIDTH - (150 + forgroundSize), env.SCREEN_HEIGHT / 2 + 50, charScale, birjonTexture, birjonKnockTexture),
            .suit = env.Suit.init(),
        };
    }

    pub fn deinit(self: *Game) void {
        rl.unloadTexture(self.birjon.texture);
        rl.unloadTexture(self.mc.texture);
        rl.unloadTexture(self.birjon.texture_knock);
        rl.unloadTexture(self.mc.texture_knock);
        self.suit.deinit();
    }

    pub fn start(self: *Game) void {
        // health player
        env.drawHealth(self.mc.health, self.mc.position.x, self.birjon.health, self.birjon.position.x);

        // texture player
        self.mc.draw();
        self.birjon.draw();

        if (self.mc.health == 0 or self.birjon.health == 0) {
            // change final result screen
            if (self.mc.health == 0) {
                drawCenterText("birjon menang", env.SCREEN_HEIGHT / 2 - 300, 50, rl.Color.red);
            } else if (self.birjon.health == 0) {
                drawCenterText("bang al menang", env.SCREEN_HEIGHT / 2 - 300, 50, rl.Color.green);
            }
            return;
        }

        // texture suit
        self.suit.update();
        self.suit.draw();

        if (self.suit.isChoice and mcChoiceSuit.id == 0) {
            // mc choices
            if (self.suit.choiceSuit == 1) {
                mcChoiceSuit = PlayerChoiceSuit{ .id = self.suit.choiceSuit, .texture = self.suit.kertas.texture };
            } else if (self.suit.choiceSuit == 2) {
                mcChoiceSuit = PlayerChoiceSuit{ .id = self.suit.choiceSuit, .texture = self.suit.batu.texture };
            } else if (self.suit.choiceSuit == 3) {
                mcChoiceSuit = PlayerChoiceSuit{ .id = self.suit.choiceSuit, .texture = self.suit.gunting.texture };
            }

            // birjon(ai) choices
            if (birjonChoiceSuit.id == 0) {
                birjonRandSuit = villain_algo.randomSuit();
                if (birjonRandSuit.id == 1) {
                    birjonChoiceSuit = PlayerChoiceSuit{ .id = birjonRandSuit.id, .texture = self.suit.kertas.texture };
                } else if (birjonRandSuit.id == 2) {
                    birjonChoiceSuit = PlayerChoiceSuit{ .id = birjonRandSuit.id, .texture = self.suit.batu.texture };
                } else if (birjonRandSuit.id == 3) {
                    birjonChoiceSuit = PlayerChoiceSuit{ .id = birjonRandSuit.id, .texture = self.suit.gunting.texture };
                }
            }
        }

        if (mcChoiceSuit.id != 0 and birjonChoiceSuit.id != 0) {
            // draw mc choice suit
            const mcPosX: i32 = @intFromFloat(self.mc.position.x);
            const mcPosY: i32 = @intFromFloat(self.mc.position.y);
            rl.drawTexture(mcChoiceSuit.texture, mcPosX + 70, mcPosY - 100, rl.Color.white);

            // draw birjon choice suit
            const birjonPosX: i32 = @intFromFloat(self.birjon.position.x);
            const birjonPosY: i32 = @intFromFloat(self.birjon.position.y);
            rl.drawTexture(birjonChoiceSuit.texture, birjonPosX + 70, birjonPosY - 100, rl.Color.white);

            // draw text result
            var textResult: [:0]const u8 = undefined;
            // mc text
            if (mcChoiceSuit.id == 1 and birjonChoiceSuit.id == 2) {
                textResult = "bang al menang dengan kertas";
            } else if (mcChoiceSuit.id == 2 and birjonChoiceSuit.id == 3) {
                textResult = "bang al menang dengan batu";
            } else if (mcChoiceSuit.id == 3 and birjonChoiceSuit.id == 1) {
                textResult = "bang al menang dengan gunting";
            }

            // birjon text
            if (birjonChoiceSuit.id == 1 and mcChoiceSuit.id == 2) {
                textResult = "birjon menang dengan kertas";
            } else if (birjonChoiceSuit.id == 2 and mcChoiceSuit.id == 3) {
                textResult = "birjon menang dengan batu";
            } else if (birjonChoiceSuit.id == 3 and mcChoiceSuit.id == 1) {
                textResult = "birjon menang dengan gunting";
            }

            // if draw
            if (mcChoiceSuit.id == birjonChoiceSuit.id) {
                textResult = "draw!";
            }

            drawCenterText(textResult, env.SCREEN_HEIGHT / 2 - 300, 30, rl.Color.init(255, 230, 50, 255));

            // action
            if (reseyDelayStart == null) {

                // mc action
                if (mcChoiceSuit.id == 1 and birjonChoiceSuit.id == 2) {
                    self.birjon.health -= 20;
                    self.birjon.mode = 2;
                } else if (mcChoiceSuit.id == 2 and birjonChoiceSuit.id == 3) {
                    self.birjon.health -= 20;
                    self.birjon.mode = 2;
                } else if (mcChoiceSuit.id == 3 and birjonChoiceSuit.id == 1) {
                    self.birjon.health -= 20;
                    self.birjon.mode = 2;
                }

                // birjon action
                if (birjonChoiceSuit.id == 1 and mcChoiceSuit.id == 2) {
                    self.mc.health -= 20;
                    self.mc.mode = 2;
                } else if (birjonChoiceSuit.id == 2 and mcChoiceSuit.id == 3) {
                    self.mc.health -= 20;
                    self.mc.mode = 2;
                } else if (birjonChoiceSuit.id == 3 and mcChoiceSuit.id == 1) {
                    self.mc.health -= 20;
                    self.mc.mode = 2;
                }

                // start delay timer
                reseyDelayStart = std.time.milliTimestamp();
            } else {
                const currentTime = std.time.milliTimestamp();
                const elapsedTime = currentTime - reseyDelayStart.?;
                // delay 10 miliseconds
                if (elapsedTime >= 5000) {
                    // reset after delay
                    mcChoiceSuit = PlayerChoiceSuit{ .id = 0, .texture = undefined };
                    birjonChoiceSuit = PlayerChoiceSuit{ .id = 0, .texture = undefined };
                    self.suit.isChoice = false;
                    reseyDelayStart = null;

                    // reset texture
                    self.mc.mode = 1;
                    self.birjon.mode = 1;
                }
            }
        }
    }
};

fn drawCenterText(text: [:0]const u8, posY: i32, fontSize: i32, color: rl.Color) void {
    const textWidth = rl.measureText(text, fontSize);
    const ceterX = @divTrunc(env.SCREEN_WIDTH - textWidth, 2);
    rl.drawText(text, ceterX, posY, fontSize, color);
}
