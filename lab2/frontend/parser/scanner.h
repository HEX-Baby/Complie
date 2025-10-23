#ifndef __FRONTEND_PARSER_SCANNER_H__
#define __FRONTEND_PARSER_SCANNER_H__

#ifndef yyFlexLexerOnce
#undef yyFlexLexer
#define yyFlexLexer Yacc_FlexLexer
#include <FlexLexer.h>
#endif

// FlexLexer.h 是 Flex 自动生成的 C++ 词法分析类的头文件。
// 它定义了一个基类 yyFlexLexer，包含 yylex() 方法。

// 避免多个 Flex 扫描器（例如一个项目中有多个）之间的符号冲突。
// 每个扫描器可以通过宏定义自定义自己的类名。

#undef YY_DECL
#define YY_DECL FE::YaccParser::symbol_type FE::Scanner::nextToken()


// 函数名：nextToken()
// 返回类型：YaccParser::symbol_type（由 bison/yacc 定义的符号类型）
// 所在类：FE::Scanner
// 这让 Flex 生成的扫描代码可以正确与 Bison/Yacc 对接。

#include <frontend/parser/yacc.h>
// 这行很关键，它引入了语法分析器（YaccParser）的定义。


// 定义的是一个编译器前端中的 词法分析器（Scanner）类，它是整个编译过程的第一个阶段，
// 主要负责从源代码字符流中识别出单词符号（Token），供后续语法分析器使用。
// 这里定义的词法分析类继承的是：Yacc_FlexLexer。而不是默认的 yyFlexLexer。
namespace FE
{
    class Parser;

    class Scanner : public yyFlexLexer
    {
// Scanner 继承自 yyFlexLexer（其实在这里宏替换后是 Yacc_FlexLexer）。
// 这个基类由 FlexLexer.h 定义，提供基本的输入流读取与状态机匹配机制。

      private:
        Parser& _parser;
// 保存对 FE::Parser 的引用；
// 让词法分析器在识别 token 时，能调用主解析器的接口（例如错误报告）。

      public:
        Scanner(Parser& parser) : _parser(parser) {}
        virtual ~Scanner() {}

        virtual YaccParser::symbol_type nextToken();
// 这是词法分析器的核心函数；
// 它会被语法分析器（YaccParser） repeatedly 调用；
// 每次调用从输入流中读取下一个 token 并返回。
    };
}  // namespace FE

#endif  // __FRONTEND_PARSER_SCANNER_H__



    //  +--------------------+
    //  |     FE::Parser     |  ←─── 调用 parseTokens()
    //  +--------------------+
    //              │
    //              ▼
    //      +---------------+
    //      |   Scanner     |  ←─── 本文件定义的类
    //      | (继承自 Flex) |
    //      +---------------+
    //              │
    //              ▼
    //      +---------------------+
    //      |  YaccParser (Bison) |
    //      | 调用 nextToken() 获取token |
    //      +---------------------+



// 数据流过程：

// 1.Parser 调用 _parser.parseTokens_impl()；

// 2.YaccParser 调用 _scanner.nextToken()；

// 3.Scanner 使用 Flex 的状态机读取输入流；

// 4.识别到 token 后返回一个 YaccParser::symbol_type；

// 5.最终 YaccParser 生成语法树 AST::Root。

