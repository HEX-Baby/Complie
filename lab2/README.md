# 使用方法

先执行
```
make lexer
```
如果有问题，在执行一遍

然后执行
```
make
```
这个也是执行2遍，2遍不行就3遍
```
root@LAPTOP-6I4GL9SI:/mnt/e/pythonProject/编译/Lab2# make
/bin/sh: 1: clang-format: not found
make: *** [Makefile:72: frontend/parser/lexer.cpp] Error 127


root@LAPTOP-6I4GL9SI:/mnt/e/pythonProject/编译/Lab2# make
Compiling frontend/parser/parser.cpp -> obj/frontend/parser/parser.o
Compiling frontend/symbol/symbol_table.cpp -> obj/frontend/symbol/symbol_table.o
然后就是编译成功了

```


# 创建结果文件夹
```
mkdir -p parser_results
```
文件夹已经建立了，可以忽略这一条


# 执行下面的脚本来运行测试并比较结果
```
chmod +x run_parser_diff.sh

./run_parser_diff.sh
```