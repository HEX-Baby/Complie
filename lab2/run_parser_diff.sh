#!/bin/bash

# 保证脚本遇到错误就停止
set -e

# 1. 执行 parser 编译器
./bin/compiler -parser -o parser_results/simple.out testcase/parser/simple.sy
./bin/compiler -parser -o parser_results/withfloat.out testcase/parser/withfloat.sy
./bin/compiler -parser -o parser_results/witharray.out testcase/parser/witharray.sy

# 2. 生成 diff 文件
diff parser_results/simple.out testcase/parser/simple.parser > parser_results/simple.diff
diff parser_results/withfloat.out testcase/parser/withfloat.parser > parser_results/withfloat.diff
diff parser_results/witharray.out testcase/parser/witharray.parser > parser_results/witharray.diff

echo "All tasks finished successfully."
