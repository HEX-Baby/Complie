#ifndef __FRONTEND_PARSER_PARSER_H__
#define __FRONTEND_PARSER_PARSER_H__

#include <frontend/iparser.h>
#include <frontend/parser/scanner.h>
#include <frontend/parser/yacc.h>

// 这个文件定义了一个完整的、具体实现的编译器前端语法解析器类 —— FE::Parser。
// 它是前面的 iParser 模板接口的 具体实现类。
// 在整个编译器前端中，它起到的作用是：
// 负责调用词法分析器（Scanner）和语法分析器（YaccParser）将源代码转换为抽象语法树（AST）。

namespace FE
{
    class Parser : public iParser<Parser>
    {
        friend iParser<Parser>;

      private:
        Scanner    _scanner;
        YaccParser _parser;

      public:
        AST::Root* ast;

// | 成员名        | 类型           | 作用                        |
// | :--------- | :----------- | :------------------------ |
// | `_scanner` | `Scanner`    | 词法分析器，负责从输入流读取字符并生成 token |
// | `_parser`  | `YaccParser` | 语法分析器，基于 token 序列生成 AST   |
// | `ast`      | `AST::Root*` | 抽象语法树（语法分析的最终产物）          |

// 源代码 ──▶ Scanner ──▶ Token ──▶ YaccParser ──▶ AST::Root

      public:
        Parser(std::istream* inStream, std::ostream* outStream)
            : iParser<Parser>(inStream, outStream), _scanner(*this), _parser(_scanner, *this), ast(nullptr)
        {
            _scanner.switch_streams(inStream, outStream);
        }

// | 步骤  | 说明                                           |
// | :-- | :------------------------------------------- |
// | 1️⃣ | 调用基类 `iParser<Parser>` 构造函数，传入输入输出流          |
// | 2️⃣ | 初始化 `_scanner`，并将当前 `Parser` 对象传给它（以便回调）     |
// | 3️⃣ | 初始化 `_parser`，并将 `_scanner` 和当前 `Parser` 传给它 |
// | 4️⃣ | 将 `ast` 初始化为空                                |
// | 5️⃣ | 调用 `_scanner.switch_streams()` 绑定输入输出流       |

        ~Parser() {}

        void reportError(const location& loc, const std::string& message);

// reportError() 是一个错误报告接口；
// 参数：
// loc：错误出现的位置（行列信息）
// message：错误描述信息
// 通常由 Scanner 或 YaccParser 调用，用于语法错误或非法 token 报告。

      private:
        std::vector<Token> parseTokens_impl();
        AST::Root*         parseAST_impl();

// | 基类接口            | 派生类实现                | 功能     |
// | :-------------- | :------------------- | :----- |
// | `parseTokens()` | `parseTokens_impl()` | 执行词法分析 |
// | `parseAST()`    | `parseAST_impl()`    | 执行语法分析 |

    };
}  // namespace FE

#endif  // __FRONTEND_PARSER_PARSER_H__


  //       ┌──────────────────────────┐
  //       │        FE::Parser        │
  //       │  (iParser<Parser> 派生类)│
  //       └──────────┬───────────────┘
  //                  │
  //        ┌─────────┴─────────┐
  //        │                   │
  //  ┌─────────────┐     ┌──────────────┐
  //  │  Scanner    │     │  YaccParser  │
  //  │ (词法分析器)│     │ (语法分析器)│
  //  └──────┬──────┘     └──────┬──────┘
  //         │                   │
  //    源代码字符流         Token 序列
  //                             │
  //                             ▼
  //                     ┌───────────────┐
  //                     │   AST::Root   │
  //                     │ 抽象语法树根节点 │
  //                     └───────────────┘

