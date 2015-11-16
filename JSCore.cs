using System;
using System.Runtime.InteropServices;

public sealed class JSCore
{
    #region settings
    private const string JSCoreLib = "JavaScriptCore";
    private const CallingConvention JSCoreCallingConvention = CallingConvention.Cdecl;
    #endregion

    #region base
    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSGlobalContextCreate(IntPtr globalObjectClass);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSGlobalContextRetain(IntPtr ctx);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern void JSGlobalContextRelease(IntPtr ctx);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern void JSValueProtect(IntPtr ctx, IntPtr value);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern void JSValueUnprotect(IntPtr ctx, IntPtr value);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSEvaluateScript(IntPtr ctx, IntPtr script, IntPtr thisObject, IntPtr sourceURL, int startingLineNumber, ref IntPtr exception);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSContextGetGlobalObject(IntPtr ctx);
    #endregion

    #region string
    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention, CharSet = CharSet.Unicode)]
    public static extern IntPtr JSStringCreateWithCharacters(string chars, UIntPtr numChars);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern UIntPtr JSStringGetLength(IntPtr str);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSStringGetCharactersPtr(IntPtr str);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSStringRetain(IntPtr str);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSStringRelease(IntPtr str);
    #endregion

    #region value
    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSValueMakeBoolean(IntPtr ctx, bool boolean);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSValueMakeNumber(IntPtr ctx, double number);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSValueMakeString(IntPtr ctx, IntPtr str);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSValueMakeNull(IntPtr ctx);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSValueMakeUndefined(IntPtr ctx);


    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSValueIsBoolean(IntPtr ctx, IntPtr value);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSValueIsNumber(IntPtr ctx, IntPtr value);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSValueIsString(IntPtr ctx, IntPtr value);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSValueIsNull(IntPtr ctx, IntPtr value);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSValueIsUndefined(IntPtr ctx, IntPtr value);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSValueIsObject(IntPtr ctx, IntPtr value);


    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSValueToBoolean(IntPtr ctx, IntPtr value);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern double JSValueToNumber(IntPtr ctx, IntPtr value, ref IntPtr exception);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSValueToStringCopy(IntPtr ctx, IntPtr value, ref IntPtr exception);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSValueToObject(IntPtr ctx, IntPtr value, ref IntPtr exception);
    #endregion

    #region object
    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSObjectHasProperty(IntPtr ctx, IntPtr obj, IntPtr propertyName);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSObjectGetProperty(IntPtr ctx, IntPtr obj, IntPtr propertyName, ref IntPtr exception);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSObjectGetPropertyAtIndex(IntPtr ctx, IntPtr obj, UIntPtr propertyIndex, ref IntPtr exception);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern void JSObjectSetProperty(IntPtr ctx, IntPtr obj, IntPtr propertyName, IntPtr value, JSPropertyAttributes attributes, ref IntPtr exception);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSObjectCopyPropertyNames(IntPtr ctx, IntPtr obj);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSPropertyNameArrayRelease(IntPtr array);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern UIntPtr JSPropertyNameArrayGetCount(IntPtr array);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSPropertyNameArrayGetNameAtIndex(IntPtr array, UIntPtr index);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern bool JSObjectIsFunction(IntPtr ctx, IntPtr obj);

    [DllImport(JSCoreLib, CallingConvention = JSCoreCallingConvention)]
    public static extern IntPtr JSObjectCallAsFunction(IntPtr ctx, IntPtr obj, IntPtr thisObject, UIntPtr argumentCount, [MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 3)]IntPtr[] arguments, ref IntPtr exception);

    public enum JSPropertyAttributes
    {
        None = 0,
        ReadOnly = 1 << 1,
        DontEnum = 1 << 2,
        DontDelete = 1 << 3
    };
    #endregion

    public static IntPtr JSCoreMakeString(string _string)
    {
        return JSStringCreateWithCharacters(_string, (UIntPtr)_string.Length);
    }

    public static string JSCoreExtractString(IntPtr _string)
    {
        return Marshal.PtrToStringUni(JSStringGetCharactersPtr(_string), (int)JSStringGetLength(_string));
    }

    public static string JSCoreValueToString(IntPtr ctx, IntPtr _value)
    {
        IntPtr exc = IntPtr.Zero;
        var str = JSValueToStringCopy(ctx, _value, ref exc);
        var result =  JSCoreExtractString(str);
        JSStringRelease(str);
        return result;
    }
}
