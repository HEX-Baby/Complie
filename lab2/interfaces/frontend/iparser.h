#ifndef __INTERFACES_FRONTEND_PARSER_IPARSER_H__
#define __INTERFACES_FRONTEND_PARSER_IPARSER_H__

#include <frontend/token.h>
#include <iostream>
#include <vector>

// 定义了一个 编译器前端（Frontend）中的“抽象语法分析器接口”模板类，名字叫 iParser。
// 它是一个 模板基类（template base class）

namespace FE
{
    namespace AST
    {
        class Root;
    }

    template <typename Derived>
    class iParser
    {
      protected:
        std::istream* inStream;
        std::ostream* outStream;

      public:
        iParser(std::istream* inStream, std::ostream* outStream) : inStream(inStream), outStream(outStream) {}
        ~iParser() = default;

      public:
        void setInStream(std::istream* inStream) { this->inStream = inStream; }
        void setOutStream(std::ostream* outStream) { this->outStream = outStream; }

      public:
      //执行词法分析（Lexer），输出 token 序列
        std::vector<Token> parseTokens() { return static_cast<Derived*>(this)->parseTokens_impl(); }

      //执行语法分析（Parser），输出 AST 树
        AST::Root*         parseAST() { return static_cast<Derived*>(this)->parseAST_impl(); }
    };
}  // namespace FE

#endif  // __INTERFACES_FRONTEND_PARSER_IPARSER_H__
