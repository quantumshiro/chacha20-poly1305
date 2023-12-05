const std = @import("std");

pub const F2_32 = struct {
    val: u32,
    const Self = @This();
    pub fn init(val: u32) F2_32 {
        return F2_32{ .val = val };
    }

    pub fn add(self: Self, other: Self) F2_32 {
        // return F2_32{ .val = (self.val + other.val) & 0xffffffff };
        return F2_32{ .val = @addWithOverflow(self.val, other.val)[0] & 0xffffffff };
    }

    pub fn xor(self: Self, other: Self) F2_32 {
        return F2_32{ .val = self.val ^ other.val };
    }

    pub fn lshift(self: Self, nbit: u32) F2_32 {
        const left = (self.val << @as(u5, @intCast(nbit % 32))) & 0xffffffff;
        const right = (self.val >> @as(u5, @intCast(32 - nbit % 32))) & 0xffffffff;
        return F2_32{ .val = left | right };
    }

    pub fn toString(self: @This()) []const u8 {
        return std.fmt.allocPrint("{x}", .{self.val}) catch unreachable;
    }

    pub fn toInt(self: Self) u32 {
        return @as(u32, @intCast(self.val));
    }
};

pub fn quarter_round(a: F2_32, b: F2_32, c: F2_32, d: F2_32) ![4]F2_32 {
    var local_a = a;
    var local_b = b;
    var local_c = c;
    var local_d = d;

    local_a = local_a.add(local_b);
    local_d = local_d.xor(local_a);
    local_d = local_d.lshift(16);
    local_c = local_c.add(local_d);
    local_b = local_b.xor(local_c);
    local_b = local_b.lshift(12);
    local_a = local_a.add(local_b);
    local_d = local_d.xor(local_a);
    local_d = local_d.lshift(8);
    local_c = local_c.add(local_d);
    local_b = local_b.xor(local_c);
    local_b = local_b.lshift(7);

    return [4]F2_32{ local_a, local_b, local_c, local_d };
}

test "F2_32 add" {
    const a = F2_32.init(0x11111111);
    const b = F2_32.init(0x22222222);
    const result = a.add(b);
    try std.testing.expectEqual(result.val, 0x33333333);
}
