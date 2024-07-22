const rl = @import("raylib");
const game = @import("game.zig");

pub const SCREEN_WIDTH = 1280;
pub const SCREEN_HEIGHT = 720;

const foregroundY = (SCREEN_HEIGHT / 2 - 40) + 10;
const foregroundHeight = SCREEN_HEIGHT - foregroundY;

// player health
var mcHealthCurrentWidth: i32 = undefined;
var birjonHealthCurrentWidth: i32 = undefined;

pub const MainCharacter = struct {
    health: u32,
    position: rl.Vector2,
    size: f32,
    texture: rl.Texture2D,
    texture_knock: rl.Texture2D,
    mode: u8,

    pub fn init(health: u32, posX: f32, posY: f32, size: f32, texture: rl.Texture2D, texture_knock: rl.Texture2D) MainCharacter {
        return MainCharacter{
            .health = health,
            .position = rl.Vector2.init(posX, posY),
            .size = size,
            .texture = texture,
            .texture_knock = texture_knock,
            .mode = 1,
        };
    }

    pub fn draw(self: *MainCharacter) void {
        if (self.mode == 1) {
            // base
            rl.drawTextureEx(self.texture, self.position, 0, self.size, rl.Color.white);
        } else if (self.mode == 2) {
            // knock
            rl.drawTextureEx(self.texture_knock, self.position, 0, self.size, rl.Color.white);
        }
    }
};

pub const Villain = struct {
    health: u32,
    position: rl.Vector2,
    size: f32,
    texture: rl.Texture2D,
    texture_knock: rl.Texture2D,
    mode: u8,

    pub fn init(health: u32, posX: f32, posY: f32, size: f32, texture: rl.Texture2D, texture_knock: rl.Texture2D) Villain {
        return Villain{
            .health = health,
            .position = rl.Vector2.init(posX, posY),
            .size = size,
            .texture = texture,
            .texture_knock = texture_knock,
            .mode = 1,
        };
    }

    pub fn draw(self: *Villain) void {
        if (self.mode == 1) {
            // base
            rl.drawTextureEx(self.texture, self.position, 0, self.size, rl.Color.white);
        } else if (self.mode == 2) {
            // knock
            rl.drawTextureEx(self.texture_knock, self.position, 0, self.size, rl.Color.white);
        }
    }
};

pub const Ground = struct {
    background: rl.Texture2D,
    foreground: rl.Texture2D,

    pub fn init() Ground {
        const backgroundTexture = rl.loadTexture("resources/env/background.png");
        const foregroundTexture = rl.loadTexture("resources/env/foreground.png");

        return Ground{
            .background = backgroundTexture,
            .foreground = foregroundTexture,
        };
    }

    pub fn deinit(self: *Ground) void {
        rl.unloadTexture(self.background);
        rl.unloadTexture(self.foreground);
    }

    pub fn drawGround(self: *Ground) void {
        // background and environment base
        rl.clearBackground(rl.getColor(0x052c46ff));

        // draw background texture fullscreen
        const backgroundWidth: f32 = @floatFromInt(self.background.width);
        const backgroundHight: f32 = @floatFromInt(self.background.height);
        const srcRect = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = backgroundWidth,
            .height = backgroundHight,
        };

        const dstRect = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = SCREEN_WIDTH,
            .height = SCREEN_HEIGHT,
        };

        const origin = rl.Vector2{ .x = 0, .y = 0 };
        rl.drawTexturePro(self.background, srcRect, dstRect, origin, 0.0, rl.Color.white);

        // draw foreground texture
        const foregroundWidthTex: f32 = @floatFromInt(self.foreground.width);
        const foregroundHeightTex: f32 = @floatFromInt(self.foreground.height);
        const foregroundSrcRect = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = foregroundWidthTex,
            .height = foregroundHeightTex,
        };

        const foregroundDstRect = rl.Rectangle{
            .x = 0,
            .y = foregroundY,
            .width = SCREEN_WIDTH,
            .height = foregroundHeight,
        };
        rl.drawTexturePro(self.foreground, foregroundSrcRect, foregroundDstRect, origin, 0.0, rl.Color.white);
    }
};

pub const SuitObj = struct {
    id: u8,
    texture: rl.Texture2D,
    position: rl.Vector2,
    size: f32,
    isChoice: bool,

    pub fn init(id: u8, texture: rl.Texture2D, posX: f32, posY: f32, size: f32, isChoice: bool) SuitObj {
        return SuitObj{
            .id = id,
            .texture = texture,
            .position = rl.Vector2.init(posX, posY),
            .size = size,
            .isChoice = isChoice,
        };
    }

    pub fn deinit(self: *SuitObj) void {
        rl.unloadTexture(self.texture);
    }

    pub fn isMouseOver(self: *SuitObj) bool {
        const mousePos = rl.getMousePosition();
        const textureWidth: f32 = @floatFromInt(self.texture.width);
        const textureHeight: f32 = @floatFromInt(self.texture.height);

        return mousePos.x > self.position.x - (textureWidth * self.size) / 2 and mousePos.x < self.position.x + (textureWidth * self.size) / 2 and mousePos.y > self.position.y - (textureHeight * self.size) / 2 and mousePos.y < self.position.y + (textureHeight * self.size) / 2;
    }

    pub fn draw(self: *SuitObj) void {
        const textureWidht: f32 = @floatFromInt(self.texture.width);
        const textureHeight: f32 = @floatFromInt(self.texture.height);
        const position = rl.Vector2{
            .x = self.position.x - textureWidht,
            .y = self.position.y - textureHeight,
        };

        if (self.isMouseOver()) {
            rl.drawTextureEx(self.texture, position, 0.0, self.size + 0.3, rl.Color.white);
        } else {
            rl.drawTextureEx(self.texture, position, 0.0, self.size, rl.Color.white);
        }
    }
};

pub const Suit = struct {
    kertas: SuitObj,
    batu: SuitObj,
    gunting: SuitObj,
    choiceSuit: u8,
    isChoice: bool,

    pub fn init() Suit {
        const kertas = rl.loadTexture("resources/env/kertas.png");
        const batu = rl.loadTexture("resources/env/batu.png");
        const gunting = rl.loadTexture("resources/env/gunting.png");

        return Suit{
            .kertas = SuitObj.init(1, kertas, SCREEN_WIDTH / 2 - 150, SCREEN_HEIGHT / 2, 2.0, false),
            .batu = SuitObj.init(2, batu, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 2.0, false),
            .gunting = SuitObj.init(3, gunting, SCREEN_WIDTH / 2 + 150, SCREEN_HEIGHT / 2, 2.0, false),
            .choiceSuit = 0,
            .isChoice = false,
        };
    }

    pub fn deinit(self: *Suit) void {
        self.kertas.deinit();
        self.batu.deinit();
        self.gunting.deinit();
    }

    pub fn update(self: *Suit) void {
        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            if (self.kertas.isMouseOver()) {
                self.kertas.isChoice = true;
                self.batu.isChoice = false;
                self.gunting.isChoice = false;

                // set choiceSuit
                self.choiceSuit = self.kertas.id;

                self.isChoice = true;
            } else if (self.batu.isMouseOver()) {
                self.kertas.isChoice = false;
                self.batu.isChoice = true;
                self.gunting.isChoice = false;

                // set choiceSuit
                self.choiceSuit = self.batu.id;

                self.isChoice = true;
            } else if (self.gunting.isMouseOver()) {
                self.kertas.isChoice = false;
                self.batu.isChoice = false;
                self.gunting.isChoice = true;

                // set choiceSuit
                self.choiceSuit = self.gunting.id;

                self.isChoice = true;
            }
        }
    }

    pub fn draw(self: *Suit) void {
        if (!self.isChoice) {
            self.kertas.draw();
            self.batu.draw();
            self.gunting.draw();
        }
    }
};

pub fn drawHealth(mcHealth: u32, mcX: f32, birjonHealth: u32, birjonX: f32) void {
    // size dan position health bar
    const barWidth = 200;
    const barHeight = 30;
    const HealthBarY = 70;

    // health bar mc
    const mcHealthBarX: i32 = @intFromFloat(mcX);
    const mcHealthConv: i32 = @intCast(mcHealth);

    // mc current health
    if (mcHealth == 100) {
        mcHealthCurrentWidth = @intCast(@divTrunc(mcHealthConv, 100) * barWidth);
    } else {
        mcHealthCurrentWidth = @intCast(@divTrunc(mcHealthConv, 100 * barWidth) + (mcHealthConv * 2));
    }

    // draw health bar mc
    // base
    rl.drawRectangle(mcHealthBarX, HealthBarY, barWidth, barHeight, rl.Color.red);
    // current health
    rl.drawRectangle(mcHealthBarX, HealthBarY, mcHealthCurrentWidth, barHeight, rl.Color.green);
    // draw mc health text
    rl.drawText(rl.textFormat("%u HP", .{mcHealth}), mcHealthBarX + 50, HealthBarY - 40, 30, rl.Color.init(255, 230, 50, 255));

    // birjon health bar
    const birjonHealtBarX: i32 = @intFromFloat(birjonX);
    const birjonHealthConv: i32 = @intCast(birjonHealth);

    // birjon current health width
    if (birjonHealth == 100) {
        birjonHealthCurrentWidth = @intCast(@divTrunc(birjonHealthConv, 100) * barWidth);
    } else {
        birjonHealthCurrentWidth = @intCast(@divTrunc(birjonHealthConv, 100) * barWidth + (birjonHealthConv * 2));
    }

    // draw health bar birjon
    // base
    rl.drawRectangle(birjonHealtBarX, HealthBarY, barWidth, barHeight, rl.Color.red);
    // current health
    rl.drawRectangle(birjonHealtBarX, HealthBarY, birjonHealthCurrentWidth, barHeight, rl.Color.green);
    // draw mc health text
    rl.drawText(rl.textFormat("%u HP", .{birjonHealth}), birjonHealtBarX + 50, HealthBarY - 40, 30, rl.Color.init(255, 230, 50, 255));
}
