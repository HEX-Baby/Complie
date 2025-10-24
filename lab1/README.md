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
这个也是执行2遍
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
mkdir -p lexer_results

文件夹已经建立了，可以忽略这一条


### 运行词法分析并保存输出结果

```
./bin/compiler -lexer -o lexer_results/simple.out testcase/lexer/simple.sy
./bin/compiler -lexer -o lexer_results/withfloat.out testcase/lexer/withfloat.sy
./bin/compiler -lexer -o lexer_results/witharray.out testcase/lexer/witharray.sy
```


### 对比输出结果与标准答案，保存 diff 结果

```
diff lexer_results/simple.out testcase/lexer/simple.lexer > lexer_results/simple.diff
diff lexer_results/withfloat.out testcase/lexer/withfloat.lexer > lexer_results/withfloat.diff
diff lexer_results/witharray.out testcase/lexer/witharray.lexer > lexer_results/witharray.diff
```

# 有个更简单的
```
chmod +x run_lexer_diff.sh

./run_lexer_diff.sh
```