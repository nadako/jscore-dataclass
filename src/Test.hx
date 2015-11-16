import cs.system.IntPtr;
import cs.system.UIntPtr;
import JSCore.*;

class Test {
    static function main() {
        var src = '{
            "name": "Dan",
            "level": "aza",
            "ids": [{"a":10, "b":1.5}, {"a":3, "b":2.8}],
            "tutorialComplete": false,
            "registerTime": 15,
            "resources": {
                "gold": 1,
                "real": 2
            }
        }';

        var exc = IntPtr.Zero;
        var ctx = JSGlobalContextCreate(IntPtr.Zero);
        var global = JSContextGetGlobalObject(ctx);
        var json = JSValueToObject(ctx, JSObjectGetProperty(ctx, global, JSCoreMakeString("JSON"), exc), exc);
        var parse = JSValueToObject(ctx, JSObjectGetProperty(ctx, json, JSCoreMakeString("parse"), exc), exc);
        var stringify = JSValueToObject(ctx, JSObjectGetProperty(ctx, json, JSCoreMakeString("stringify"), exc), exc);
        var parsed = JSObjectCallAsFunction(ctx, parse, json, new UIntPtr(1), cs.NativeArray.make(JSValueMakeString(ctx, JSCoreMakeString(src))), exc);

        var p = new data.dragons.PlayerData(ctx, parsed);
        trace(p);
        for (el in p.ids)
            trace(el);
    }
}
