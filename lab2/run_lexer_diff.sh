#!/bin/bash

# 保证脚本遇到错误就停止
set -e

# 1. 执行 lexer 编译器
./bin/compiler -lexer -o lexer_results/simple.out testcase/lexer/simple.sy
./bin/compiler -lexer -o lexer_results/withfloat.out testcase/lexer/withfloat.sy
./bin/compiler -lexer -o lexer_results/witharray.out testcase/lexer/witharray.sy

# 2. 生成 diff 文件
diff lexer_results/simple.out testcase/lexer/simple.lexer > lexer_results/simple.diff
diff lexer_results/withfloat.out testcase/lexer/withfloat.lexer > lexer_results/withfloat.diff
diff lexer_results/witharray.out testcase/lexer/witharray.lexer > lexer_results/witharray.diff

echo "All tasks finished successfully."
