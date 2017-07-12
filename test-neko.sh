haxe -neko bin/neko/test.n -cp src -cp test -main Test -dce full -D no-traces
neko ./bin/neko/test.n
