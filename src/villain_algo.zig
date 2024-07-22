const std = @import("std");

pub const SuitProp = struct {
    id: u8,
    name: []const u8,
};

const suits = [3]SuitProp{
    SuitProp{ .id = 1, .name = "kertas" },
    SuitProp{ .id = 2, .name = "batu" },
    SuitProp{ .id = 3, .name = "gunting" },
};

pub fn randomSuit() SuitProp {
    var rng = std.crypto.random;
    const i = rng.intRangeAtMost(u8, 0, suits.len - 1);
    return suits[i];
}

test "generate random suits" {
    const suit = randomSuit();
    var found = false;

    for (suits) |s| {
        if (suit.id == s.id) {
            found = true;
            break;
        }
    }

    try std.testing.expect(found);
}

test "generate different suit" {
    const suit1 = randomSuit();
    const suit2 = randomSuit();

    try std.testing.expect(suit1.id != suit2.id);
}
