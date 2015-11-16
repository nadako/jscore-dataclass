GMCS="C:/Program Files (x86)/Unity/Editor/Data/Mono/bin/gmcs.bat" -debug

all: compile
	bin/Test.exe

compile: bin/JSCore.dll
	haxe build.hxml
	$(GMCS) -out:bin/Test.exe -reference:bin/JSCore.dll -platform:x86 -recurse:bin/cs_out/src/*.cs

bin/JSCore.dll: JSCore.cs
	$(GMCS) -target:library -out:bin/JSCore.dll JSCore.cs
