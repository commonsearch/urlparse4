// Copyright 2013 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// This file defines utility functions for working with strings.

#ifndef BASE_STRINGS_STRING_UTIL_H_
#define BASE_STRINGS_STRING_UTIL_H_

#include <ctype.h>
#include <stdarg.h>   // va_list

#include <string>
#include <vector>

#include "base/base_export.h"
#include "base/basictypes.h"
//#include "base/compiler_specific.h"
#include "base/strings/string16.h"
#include "base/strings/string_piece.h"  // For implicit conversions.

namespace base {

// ASCII-specific tolower.  The standard library's tolower is locale sensitive,
// so we don't want to use it here.
inline char ToLowerASCII(char c) {
  return (c >= 'A' && c <= 'Z') ? (c + ('a' - 'A')) : c;
}
inline char16 ToLowerASCII(char16 c) {
  return (c >= 'A' && c <= 'Z') ? (c + ('a' - 'A')) : c;
}

// Compare the lower-case form of the given string against the given
// previously-lower-cased ASCII string (typically a constant).
BASE_EXPORT bool LowerCaseEqualsASCII(StringPiece str,
                                      StringPiece lowecase_ascii);
BASE_EXPORT bool LowerCaseEqualsASCII(StringPiece16 str,
                                      StringPiece lowecase_ascii);

// Returns true if the specified string matches the criteria. How can a wide
// string be 8-bit or UTF8? It contains only characters that are < 256 (in the
// first case) or characters that use only 8-bits and whose 8-bit
// representation looks like a UTF-8 string (the second case).
//
// Note that IsStringUTF8 checks not only if the input is structurally
// valid but also if it doesn't contain any non-character codepoint
// (e.g. U+FFFE). It's done on purpose because all the existing callers want
// to have the maximum 'discriminating' power from other encodings. If
// there's a use case for just checking the structural validity, we have to
// add a new function for that.
//
// IsStringASCII assumes the input is likely all ASCII, and does not leave early
// if it is not the case.
BASE_EXPORT bool IsStringUTF8(const StringPiece& str);
BASE_EXPORT bool IsStringASCII(const StringPiece& str);
BASE_EXPORT bool IsStringASCII(const StringPiece16& str);
// A convenience adaptor for WebStrings, as they don't convert into
// StringPieces directly.
BASE_EXPORT bool IsStringASCII(const string16& str);
#if defined(WCHAR_T_IS_UTF32)
BASE_EXPORT bool IsStringASCII(const std::wstring& str);
#endif

}  // namespace base

#endif  // BASE_STRINGS_STRING_UTIL_H_
