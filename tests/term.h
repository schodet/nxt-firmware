#ifndef term_h
#define term_h
/*
 * Copyright (C) 2024 Nicolas Schodet
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

/**
 * Terminal like output using messages.
 */

int term_screen_line = LCD_LINE1;
string term_line = "";

inline void
TermTextSub(string s, bool nl)
{
    term_line = StrCat(term_line, s);
    if (nl) {
        TextOut(0, term_screen_line, term_line);
        if (term_screen_line)
            term_screen_line -= 8;
        else
            term_screen_line = LCD_LINE1;
        ClearLine(term_screen_line);
        SendMessage(10, term_line);
        Wait(2);
        term_line = "";
    }
}

#define TermText(s) TermTextSub(s, FALSE)
#define TermTextNl(s) TermTextSub(s, TRUE)
#define TermNum(num) TermText(NumToStr(num))
#define TermNumNl(num) TermTextNl(NumToStr(num))
#define TermNl(num) TermTextNl("")

#endif
