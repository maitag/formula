haxe -neko bin/neko/test.n -cp src -cp test -main Test -lib hx3compat -dce full -D no-traces
neko ./bin/neko/test.n
