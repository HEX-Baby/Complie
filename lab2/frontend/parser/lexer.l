%{
    #include <frontend/parser/yacc.h>
    #include <frontend/parser/scanner.h>
    #include <frontend/parser/location.hh>
    #include <frontend/parser/parser.h>
    #include <stdexcept>
    #include <string>
    #include <limits>
    #include <cmath>

    using namespace FE;

    static location loc;

    #define YY_USER_ACTION  \
        loc.step();          \
        loc.columns(yyleng);

    #define RETT(x, y) return YaccParser::make_##x(y);
    #define TAB_WIDTH 4

    int handleTab();
    long long convertToInt(const char* str, const char end, bool& isLongLong);
    float convertToFloatDec(const char* str);
    float convertToFloatHex(const char* str);
%}

%option c++
%option noyywrap
%option debug
%option yyclass="Scanner"
%option prefix="Yacc_"

%%

\n                  { loc.lines(yyleng); loc.step(); }
[ \f\r\v]+          { /* skip */ }
[\t]                { loc.columns(handleTab()); }

%{
// ---------- 关键字 ----------     
%}

"if"                { RETT(IF, loc) }
"else"              { RETT(ELSE, loc) }
"for"               { RETT(FOR, loc) }
"while"             { RETT(WHILE, loc) }
"continue"          { RETT(CONTINUE, loc) }
"break"             { RETT(BREAK, loc) }
"switch"            { RETT(SWITCH, loc) }
"case"              { RETT(CASE, loc) }
"goto"              { RETT(GOTO, loc) }
"do"                { RETT(DO, loc) }
"return"            { RETT(RETURN, loc) }
"const"             { RETT(CONST, loc) }

"int"               { RETT(INT, loc)}
"float"             { RETT(FLOAT, loc)}
"void"              { RETT(VOID, loc)}
"double"            { RETT(DOUBLE, loc)}

%{
// ---------- 符号 ---------- 
%}

";"                 { RETT(SEMICOLON, loc) }
","                 { RETT(COMMA, loc) }
"("                 { RETT(LPAREN, loc) }
")"                 { RETT(RPAREN, loc) }
"["                 { RETT(LBRACKET, loc) }
"]"                 { RETT(RBRACKET, loc) }
"{"                 { RETT(LBRACE, loc) }
"}"                 { RETT(RBRACE, loc) }

%{
// ====================== 算术运算符 ======================
%}
"+"                 { RETT(PLUS, loc) }
"-"                 { RETT(MINUS, loc) }
"*"                 { RETT(STAR, loc) }
"/"                 { RETT(SLASH, loc) }
"%"                 { RETT(MOD, loc) }  


%{
// ====================== 关系运算符 ======================
%}
"!="                { RETT(NEQ, loc) }
"=="                { RETT(EQ, loc) }
"<="                { RETT(LE, loc) }
"<"                 { RETT(LT, loc) }
">="                { RETT(GE, loc) }
">"                 { RETT(GT, loc) }

"="                 { RETT(ASSIGN, loc) }

%{
// ====================== 逻辑运算符 ======================
%}
"&&"      { RETT(LAND, loc) }        // 逻辑与
"||"      { RETT(LOR, loc) }         // 逻辑或
"!"       { RETT(LNOT, loc) }        // 逻辑非

%{
// ====================== 位运算符 ======================
%}
"&"       { RETT(BITAND, loc) }      // 按位与
"|"       { RETT(BITOR, loc) }       // 按位或
"^"       { RETT(BITXOR, loc) }      // 按位异或
"~"       { RETT(BITNOT, loc) }      // 按位取反



%{
// ---------- 单行注释 ---------- 
%}

"//".*              { 
    auto str = std::string(yytext);
    // return YaccParser::make_SLASH_COMMENT(str, loc);  //思考为什么要把这一行注释掉
}


%{
// ---------- 多行注释 ---------- 
%}

"/*"([^*]|\*+[^*/])*\*+"/"   {
                                for (int i = 0; i < yyleng; ++i)
                                    if (yytext[i] == '\n') { loc.lines(1); loc.step(); }
                             }

%{
// ---------- 浮点数 ---------- 
%}

%{
// 1. 十六进制浮点数 (0x1.Ap2)
%}
0[xX][0-9A-Fa-f]+(\.[0-9A-Fa-f]*)?[pP][+-]?[0-9]+  {
    try {
        float val = convertToFloatHex(yytext);
        return YaccParser::make_FLOAT_CONST(val, loc);
    } catch (const std::exception& e) {
        _parser.reportError(loc, std::string("Invalid hex float constant: ") + e.what());
        return YaccParser::make_ERR_TOKEN(yytext, loc);
    }
}

%{
// 2. 十进制带小数点的浮点数 (1.23, .5, 3.)
%}
([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)([eE][+-]?[0-9]+)?  {
    try {
        float val = convertToFloatDec(yytext);
        return YaccParser::make_FLOAT_CONST(val, loc);
    } catch (const std::exception& e) {
        _parser.reportError(loc, std::string("Invalid float constant: ") + e.what());
        return YaccParser::make_ERR_TOKEN(yytext, loc);
    }
}

%{
// 3. 科学计数法整数形式 (123e-2)
%}
[0-9]+([eE][+-]?[0-9]+)  {
    try {
        float val = convertToFloatDec(yytext);
        return YaccParser::make_FLOAT_CONST(val, loc);
    } catch (const std::exception& e) {
        _parser.reportError(loc, std::string("Invalid scientific float: ") + e.what());
        return YaccParser::make_ERR_TOKEN(yytext, loc);
    }
}

%{
// ---------- 整数 ---------- 
%}

%{
// 4. 十六进制整数 (0x1A3F)
%}
0[xX][0-9A-Fa-f]+     {
    try {
        bool isLL = false;
        long long result = convertToInt(yytext, '\0', isLL);

        if (result >= INT32_MIN && result <= INT32_MAX) {
            return YaccParser::make_INT_CONST(static_cast<int>(result), loc);
        } else {
            return YaccParser::make_LL_CONST(result, loc);
        }
    } catch (const std::exception& e) {
        _parser.reportError(loc, std::string("Invalid hex int: ") + e.what());
        return YaccParser::make_ERR_TOKEN(yytext, loc);
    }
}

%{
// 5. 八进制整数 (077)
%}
0[0-7]+              {
    try {
        bool isLL = false;
        long long result = convertToInt(yytext, '\0', isLL);

        if (result >= INT32_MIN && result <= INT32_MAX) {
            return YaccParser::make_INT_CONST(static_cast<int>(result), loc);
        } else {
            return YaccParser::make_LL_CONST(result, loc);
        }
    } catch (const std::exception& e) {
        _parser.reportError(loc, std::string("Invalid octal int: ") + e.what());
        return YaccParser::make_ERR_TOKEN(yytext, loc);
    }
}

%{
// 6. 十进制整数 (0, 123)
%}
0|[1-9][0-9]*        {
    try {
        bool isLL = false;
        long long result = convertToInt(yytext, '\0', isLL);

        if (result >= INT32_MIN && result <= INT32_MAX) {
            return YaccParser::make_INT_CONST(static_cast<int>(result), loc);
        } else {
            return YaccParser::make_LL_CONST(result, loc);
        }
    } catch (const std::exception& e) {
        _parser.reportError(loc, std::string("Invalid decimal int: ") + e.what());
        return YaccParser::make_ERR_TOKEN(yytext, loc);
    }
}



%{
// ---------- 标识符 & 字符串 ---------- 
%}

[A-Za-z_][A-Za-z0-9_]* {
    std::string str(yytext);
    return YaccParser::make_IDENT(str, loc);
}

\"[^\"]*\"  {
    std::string str(yytext);
    if (str.size() >= 2) str = str.substr(1, str.size() - 2);
    return YaccParser::make_STR_CONST(str, loc);
}

%{
// ---------- 文件结束 ---------- 
%}

<<EOF>>     { RETT(END, loc); }

%%

int handleTab()
{
    // 该函数用于处理制表符，根据当前位置计算制表符应占用的列数
    // 如，在TAB_WIDTH为4的情况下：
    // 对于" \t"，则会对 '\t' 返回 3
    // 对于"   \t"，则会对 '\t' 返回 1
    // 对于"    \t"，则会对 '\t' 返回 4

    int& c = loc.begin.column;
    return TAB_WIDTH - ((c - 1) % TAB_WIDTH) - 1;
}

long long convertToInt(const char* str, const char end, bool& isLongLong)
{
    // 该函数用于将字符串转换为整数，能正确处理格式无误的十进制、十六进制和八进制整数
    // 接受一个 isLongLong 引用参数，用于指示结果是否超出 int 范围

    int         base       = 10;
    long long   result     = 0;
    int         isNegative = 0;
    const char* ptr        = str;
    static int  zeroOffset = '0';
    static int  aOffset    = 'a' - 10;
    static int  AOffset    = 'A' - 10;
    int*        offset     = NULL;
    isLongLong             = false;

    if (*ptr == '-')
    {
        isNegative = 1;
        ++ptr;
    }
    else if (*ptr == '+') { ++ptr; }

    if (ptr[0] == '0' && (ptr[1] == 'x' || ptr[1] == 'X'))
    {
        base = 16;
        ptr += 2;
    }
    else if (ptr[0] == '0')
    {
        base = 8;
        ptr += 1;
    }

    while (*ptr != end)
    {
        int value = 0;

        if (base == 16)
        {
            if (*ptr >= '0' && *ptr <= '9')
                offset = &zeroOffset;
            else if (*ptr >= 'a' && *ptr <= 'f')
                offset = &aOffset;
            else if (*ptr >= 'A' && *ptr <= 'F')
                offset = &AOffset;
        }
        else { offset = &zeroOffset; }

        value  = *ptr - *offset;
        result = result * base + value;
        ++ptr;
    }

    if (isNegative) result = -result;

    if (result > std::numeric_limits<int>::max() || result < std::numeric_limits<int>::min())
    {
        isLongLong = true;
        if (result > std::numeric_limits<long long>::max() || result < std::numeric_limits<long long>::min())
        {
            throw std::out_of_range(str + std::string(" overflow or underflow for long long"));
        }
    }

    return result;
}

float convertToFloatDec(const char* str)
{
    // 该函数用于将字符串转换为浮点数，能正确处理格式无误的十进制浮点数

    const char* head = str;
    if (str == NULL) { return 0.0f; }

    int sign = 1;
    if (*str == '-')
    {
        sign = -1;
        str++;
    }
    else if (*str == '+') { str++; }

    double integerPart = 0.0;
    while (isdigit(*str))
    {
        integerPart = integerPart * 10 + (*str - '0');
        str++;
    }

    double fractionPart = 0.0;
    if (*str == '.')
    {
        str++;
        double divisor = 10.0;
        while (isdigit(*str))
        {
            fractionPart += (*str - '0') / divisor;
            divisor *= 10.0;
            str++;
        }
    }

    double value = integerPart + fractionPart;

    if (*str == 'e' || *str == 'E')
    {
        str++;
        int expSign = 1;
        if (*str == '-')
        {
            expSign = -1;
            str++;
        }
        else if (*str == '+') { str++; }

        int exponent = 0;
        while (isdigit(*str))
        {
            exponent = exponent * 10 + (*str - '0');
            str++;
        }

        value *= pow(10, expSign * exponent);
    }

    value = sign * value;

    if (value > std::numeric_limits<float>::max() || value < -std::numeric_limits<float>::max())
    {
        throw std::out_of_range(
            head + ((value > std::numeric_limits<float>::max()) ? std::string(" overflow") : std::string(" underflow")));
    }

    return static_cast<float>(value);
}

float convertToFloatHex(const char* str)
{
    // 该函数用于将字符串转换为浮点数，能正确处理格式无误的十六进制浮点数

    const char* head = str;
    if (str == NULL) { return 0.0f; }

    int sign = 1;
    if (*str == '-')
    {
        sign = -1;
        str++;
    }
    else if (*str == '+') { str++; }

    if (*str == '0' && (*(str + 1) == 'x' || *(str + 1) == 'X')) { str += 2; }

    unsigned long long integerPart = 0;
    while (isxdigit(*str))
    {
        int digit = 0;
        if (isdigit(*str)) { digit = (*str - '0'); }
        else if (*str >= 'a' && *str <= 'f') { digit = (*str - 'a' + 10); }
        else if (*str >= 'A' && *str <= 'F') { digit = (*str - 'A' + 10); }
        integerPart = integerPart * 16 + digit;
        str++;
    }

    double fractionPart = 0.0;
    if (*str == '.')
    {
        str++;
        unsigned long long numerator   = 0;
        unsigned long long denominator = 1;
        while (isxdigit(*str))
        {
            int digit = 0;
            if (isdigit(*str)) { digit = (*str - '0'); }
            else if (*str >= 'a' && *str <= 'f') { digit = (*str - 'a' + 10); }
            else if (*str >= 'A' && *str <= 'F') { digit = (*str - 'A' + 10); }
            numerator = numerator * 16 + digit;
            denominator *= 16;
            str++;
        }
        fractionPart = (double)numerator / (double)denominator;
    }

    double value = (double)integerPart + fractionPart;

    if (*str == 'p' || *str == 'P')
    {
        str++;
        int expSign = 1;
        if (*str == '-')
        {
            expSign = -1;
            str++;
        }
        else if (*str == '+') { str++; }

        int exponent = 0;
        while (isdigit(*str))
        {
            exponent = exponent * 10 + (*str - '0');
            str++;
        }

        value *= pow(2, expSign * exponent);
    }

    value = sign * value;

    if (value > std::numeric_limits<float>::max() || value < -std::numeric_limits<float>::max())
    {
        throw std::out_of_range(
            head + ((value > std::numeric_limits<float>::max()) ? std::string(" overflow") : std::string(" underflow")));
    }

    return static_cast<float>(value);
}
