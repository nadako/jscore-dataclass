import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

/**
    Информация об анонимной структуре - пакет и имя typedef'а, который на неё ссылается
**/
typedef AnonCtx = {
    pack:Array<String>,
    name:String
}

class DataClassMacro {
    /**
        Префикс пакета, с которым генерируются клиентские типы
    **/
    static var prefixPack = ["data"];

    /**
        Список сгенерированных из typedef'ов классов, дабы не пытаться генерировать их снова,
        если они встречаются несколько раз
    **/
    static var generatedAnonClasses = new Map<String,Bool>();

    /**
        Сгенерировать клиентские типы для всех типов из указанного модуля
    **/
    static function genModule(name:String) {
        for (type in Context.getModule(name))
            genType(type, null, Context.currentPos());
    }

    /**
        Сгенерировать клиентский тип для указанного типа
    **/
    static function genType(type:Type, anonCtx:AnonCtx, pos:Position):ComplexType {
        // сначала проверяем по простому - если это простые типы - возвращаем их как есть
        switch (type.follow().toString()) {
            case "String" | "Int" | "Float" | "Bool":
                return type.toComplexType();
            default:
        }

        // далее смотрим структуру типа
        switch (type) {
            // если это typedef - генерируем тип, на который он указывает, используя его пакет и имя
            case TType(_.get() => dt, params):
                return genType(dt.type.applyTypeParameters(dt.params, params), {pack: dt.pack, name: dt.name}, dt.pos);

            // если это анонимная структура и у нас есть пакет/имя для неё - генерим клиентский класс
            case TAnonymous(_.get() => anon) if (anonCtx != null):
                return genAnonClass(anon, anonCtx, pos);

            // если это массив и у нас есть пакет/имя для его элементов - генерим массив клиентских типов
            case TInst(_.get() => {pack: [], name: "Array"}, [elemType]) if (anonCtx != null):
                var elemCT = genType(elemType, {pack: anonCtx.pack, name: anonCtx.name + "_elem"}, pos);
                return macro : cs.NativeArray<$elemCT>;

            // иначе выдаем ошибку
            default:
                throw new Error("Unsupported type for generation data class: " + type.toString(), pos);
        }
    }

    /**
        Сгенерировать клиентский дата-класс для анонимной структуры, получающий в конструктор указатель на
        JavaScript-объект и конвертящий/распихивающий значения из него по своим полям.
    **/
    static function genAnonClass(anon:AnonType, anonCtx:AnonCtx, pos:Position):ComplexType {
        // целевой путь до класса - такой же как у исходного типа, но с нашим префиксом
        var targetPath = {pack: prefixPack.concat(anonCtx.pack), name: anonCtx.name};

        // результат - ComplexType, указывающий на целевой путь класса
        var result = TPath(targetPath);

        // если данный класс уже был сгенерен - возвращаем результат сразу,
        // в противном случае генерим класс и потом возвращаем результат
        var key = anonCtx.pack.join(".") + "." + anonCtx.name;
        if (generatedAnonClasses.exists(key))
            return result;

        // помечаем класс как сгенеренный сразу, чтобы при генерации типов полей он уже считался
        // сгенеренным
        generatedAnonClasses[key] = true;

        // массив полей в сгенеренном классе
        var targetFields:Array<Field> = [];

        // массив выражений конструтора
        var ctorExprs:Array<Expr> = [
            (macro var exc = cs.system.IntPtr.Zero), // переменная для сохранения эксепшенов из JavaScript
            (macro var jsObj = JSCore.JSValueToObject(jsCtx, jsValue, exc)), // конвертим значение в объект
        ];

        // выражение для toString
        var toStringExpr = macro $v{targetPath.name + "{"};

        // итерируем по всем полям структуры
        var first = true;
        for (field in anon.fields) {
            var fieldName = field.name;

            // генерируем тип для поля
            var fieldCT = genType(field.type, {pack: anonCtx.pack, name: anonCtx.name + "_" + fieldName}, field.pos);

            // добавляем поле к классу
            targetFields.push({
                access: [APublic],
                pos: field.pos,
                name: fieldName,
                kind: FVar(fieldCT)
            });

            // выражение получения указателя на javascript-значение поля
            var fieldExpr = macro JSCore.JSObjectGetProperty(jsCtx, jsObj, JSCore.JSCoreMakeString($v{fieldName}), exc);

            // генерируем выражение, конвертящее js-значение в клиентское значение
            var fieldInitExpr = genInitExpr(field.type, fieldCT, fieldExpr, field.pos);

            // добавляем инициализацию поля в конструктор
            ctorExprs.push(macro this.$fieldName = $fieldInitExpr);

            // добавляем вывод поля для toString
            if (first)
                first = false
            else
                toStringExpr = macro $toStringExpr + ", ";
            toStringExpr = macro $toStringExpr + $v{fieldName} + "=" + this.$fieldName;
        }

        // финализируем выражение toString
        toStringExpr = macro $toStringExpr + "}";

        // добавляем конструктор, получающий на вход указатели на js-контекст и js-значение объекта
        targetFields.push({
            pos: pos,
            name: "new",
            access: [APublic],
            kind: FFun({
                ret: null,
                args: [{name: "jsCtx", type: macro : cs.system.IntPtr}, {name: "jsValue", type: macro : cs.system.IntPtr}],
                expr: macro $b{ctorExprs}
            })
        });

        // добавляем метод toString
        targetFields.push({
            pos: pos,
            name: "toString",
            access: [APublic],
            kind: FFun({
                ret: null,
                args: [],
                expr: macro return $toStringExpr
            })
        });

        // создаем сам класс
        Context.defineType({
            pos: pos,
            pack: targetPath.pack,
            name: targetPath.name,
            kind: TDClass(),
            fields: targetFields,
            meta: [
                {name: ":nativeGen", pos: pos} // @:nativeGen чтобы класс сгенерился без хелперов для хаксового рефлекшена
            ]
        });

        // возвращаем ComplexType, указывающий на наш клиентский класс
        return result;
    }

    /**
        Сгенерировать выражение получения клиентского значения из указателя на JavaScript-значение
    **/
    static function genInitExpr(sourceType:Type, targetCT:ComplexType, sourceExpr:Expr, pos:Position):Expr {
        // сначала обрабатываем простые типы, тут всё просто
        switch (sourceType.follow().toString()) {
            case "Int":
                return macro Std.int(JSCore.JSValueToNumber(jsCtx, $sourceExpr, exc));
            case "Float":
                return macro JSCore.JSValueToNumber(jsCtx, $sourceExpr, exc);
            case "String":
                return macro JSCore.JSCoreValueToString(jsCtx, $sourceExpr);
            case "Bool":
                return macro JSCore.JSValueToBoolean(jsCtx, $sourceExpr);
            default:
        }

        // далее обрабатываем более сложные
        switch (targetCT) {
            // массив
            case TPath(tp = {pack: ["cs"], name: "NativeArray", params: [TPType(elemCT)]}):
                // получаем тип элементов в исходном массиве
                var elemType = switch (sourceType) {
                    case TInst(_, [t]): t;
                    default: throw false;
                }

                // выражение получения имени свойства i-ого элемента
                var propNameExpr = macro JSCore.JSPropertyNameArrayGetNameAtIndex(props, new cs.system.UIntPtr(i));

                // генерируем выражение инициализации значения для элемента
                var elemInitExpr = genInitExpr(elemType, elemCT, macro JSCore.JSObjectGetProperty(jsCtx, src, $propNameExpr, exc), pos);

                // вовзращаем выражение инициализации массива
                return macro {
                    // конвертим значение в js-объект
                    var src = JSCore.JSValueToObject(jsCtx, $sourceExpr, exc);

                    // получаем массив имен свойств элементов
                    var props = JSCore.JSObjectCopyPropertyNames(jsCtx, src);

                    // получаем их кол-во (юзаем __cs__, чтобы тупо скастить к инту без хаксовой магии)
                    var len = untyped __cs__("(int){0}", JSCore.JSPropertyNameArrayGetCount(props));

                    // создаем клиентский массив нужной длины (tp - путь до типа массива с параметром, вроде cs.NativeArray<String>)
                    var arr = new $tp(len);

                    // заполняем созданный массив значениями
                    for (i in 0...len)
                        arr[i] = $elemInitExpr;

                    // освобождаем массив имен свойств элементов
                    JSCore.JSPropertyNameArrayRelease(props);

                    // возвращаем созданный массив как значение блока кода
                    arr;
                };

            // сгенерированный нами класс (пакет начинается с нашего префикса)
            case TPath(tp) if (tp.pack.join(".").indexOf(prefixPack.join(".")) == 0):
                // создаем экземпляр, передавая в него js-контекст и js-значение
                return macro new $tp(jsCtx, $sourceExpr);

            default:
        }

        // если мы дошли до сюда - значит тип неизвестен этой функции
        throw new Error("Unsupported type for generation init expression: " + sourceType.toString(), pos);
    }
}
