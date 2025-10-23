#include <frontend/parser/parser.h>
#include <debug.h>

namespace FE
{
    using type = YaccParser::symbol_type;
    using kind = YaccParser::symbol_kind;

    void Parser::reportError(const location& loc, const std::string& message) { _parser.error(loc, message); }


    // 这一函数完成 词法分析阶段，逐个从 Flex 扫描器中取出 token：
    std::vector<Token> Parser::parseTokens_impl()
    {
        std::vector<Token> tokens;
        while (true)
        {
            type token = _scanner.nextToken();
            if (token.kind() == kind::S_END) break;

            Token result;
            result.token_name    = token.name();
            result.line_number   = token.location.begin.line;
            result.column_number = token.location.begin.column - 1;
            result.lexeme        = _scanner.YYText();

            switch (token.kind())
            {
                case kind::S_INT_CONST:
                    result.ival = token.value.as<int>();
                    result.type = Token::TokenType::T_INT;
                    break;
                case kind::S_IDENT:
                case kind::S_SLASH_COMMENT:
                case kind::S_ERR_TOKEN:
                case kind::S_STR_CONST:
                    result.sval = token.value.as<std::string>();
                    result.type = Token::TokenType::T_STRING;
                    break;
                default: result.type = Token::TokenType::T_NONE; break;
            }

            tokens.push_back(result);
        }

        return tokens;
    }

    AST::Root* Parser::parseAST_impl()
    {
        _parser.parse();
        return ast;
    }
}  // namespace FE



// | 文件                          | 作用                                                             |
// | --------------------------- | -------------------------------------------------------------- |
// | `iparser.h`                 | 泛型接口模板，定义 `parseTokens()` / `parseAST()` 两个统一入口                |
// | `parser.h`                  | 继承自 `iParser` 的具体实现类，整合 `Scanner`（词法分析）与 `YaccParser`（语法分析）    |
// | `scanner.h`                 | 封装 `FlexLexer`，定义 `nextToken()`，用于生成 `YaccParser::symbol_type` |
// | `parser.cpp`                | 实现了 `Parser` 的具体逻辑，包括 token 流提取与 AST 生成                        |


// +------------------+
// |  iParser<Parser> |
// |  (抽象接口模板)  |
// +--------^---------+
//          |
//          |
// +--------+--------+           +------------------+
// |      Parser     |<----------|    Scanner       |
// |-----------------|           |------------------|
// | _parser (Bison) |           | yyFlexLexer 基类 |
// | _scanner (Flex) |---------->| nextToken()      |
// | ast (AST::Root) |           +------------------+
// +--------+--------+
//          |
//          v
//    +-------------+
//    |   AST::Root |
//    | (语法树结构) |
//    +-------------+
