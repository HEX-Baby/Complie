#ifndef __INTERFACES_FRONTEND_TOKEN_H__
#define __INTERFACES_FRONTEND_TOKEN_H__

// 定义了前端编译器（Frontend）中用来表示“词法单元（Token）”的结构体。

#include <string>

namespace FE
{
    struct Token
    {
        std::string token_name;     ///< 词法分析中使用的 token 名称
        std::string lexeme;         ///< 该 token 的原始文本内容
        int         line_number;    ///< 该 token 所在的行号
        int         column_number;  ///< 该 token 所在的列号


        // 用来标识 token 的 值类型（Value Type），主要用于数值或字符串字面量。
        enum class TokenType
        {
            T_INT,
            T_LL,
            T_FLOAT,
            T_DOUBLE,
            T_STRING,
            T_NONE
        } type;
        union
        {
            int       ival;
            long long lval;
            float     fval;
            double    dval;
        };
        std::string sval;
    };
}  // namespace FE

#endif  // __INTERFACES_FRONTEND_TOKEN_H__
