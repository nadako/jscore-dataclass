package dragons;

/**
    Тестовая структурка
**/
typedef PlayerData = {
    var name:String;
    var level:Int;
    var tutorialComplete:Bool;
    var registerTime:Float;
    var ids:Array<{a:Int, b:Float}>;
    var resources:{
        gold:Int,
        real:Int,
    };
}
