/* ─────────────────────────────────────────────────────────────────────────────
 * SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
 * SPDX-License-Identifier: BSD-3-Clause OR Proprietary
 * SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
 * 
 * This file is part of the SAGE OS Project.
 *
 * ───────────────────────────────────────────────────────────────────────────── */
// Licensing:
// -----------
//                                 
//                                                                             
//   Licensed under the BSD 3-Clause License or a Commercial License.          
//   You may use this file under the terms of either license as specified in: 
//                                                                             
//      - BSD 3-Clause License (see ./LICENSE)                           
//      - Commercial License (see ./COMMERCIAL_TERMS.md or contact legal@your.org)  
//                                                                             
//   Redistribution and use in source and binary forms, with or without       
//   modification, are permitted under the BSD license provided that the      
//   following conditions are met:                                            
//                                                                             
//     * Redistributions of source code must retain the above copyright       
//       notice, this list of conditions and the following disclaimer.       
//     * Redistributions in binary form must reproduce the above copyright    
//       notice, this list of conditions and the following disclaimer in the  
//       documentation and/or other materials provided with the distribution. 
//     * Neither the name of the project nor the names of its contributors    
//       may be used to endorse or promote products derived from this         
//       software without specific prior written permission.                  
//                                                                             
//   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS  
//   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A          
//   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER 
//   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
//   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,      
//   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR       
//   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   
//   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING     
//   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS       
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
//
// By using this software, you agree to be bound by the terms of either license.
//
// Alternatively, commercial use with extended rights is available — contact the author for commercial licensing.
//
/* ─────────────────────────────────────────────────────────────────────────────
 * Contributor Guidelines:
 * ------------------------
 * Contributions are welcome under the terms of the Developer Certificate of Origin (DCO).
 * All contributors must certify that they have the right to submit the code and agree to
 * release it under the above license terms.
 *
 * Contributions must:
 *   - Be original or appropriately attributed
 *   - Include clear documentation and test cases where applicable
 *   - Respect the coding and security guidelines defined in CONTRIBUTING.md
 *
 * ───────────────────────────────────────────────────────────────────────────── */
// Terms of Use and Disclaimer:
// -----------------------------
// This software is provided "as is", without any express or implied warranty.
// In no event shall the authors, contributors, or copyright holders
// be held liable for any damages arising from the use of this software.
//
// Use of this software in critical systems (e.g., medical, nuclear, safety)
// is entirely at your own risk unless specifically licensed for such purposes.
//

#include "utils.h"
#include "types.h"

// Convert unsigned integer to string with given base
int utoa_base(unsigned int value, char* buffer, int base) {
    if (base < 2 || base > 36) {
        return 0;
    }
    
    char temp[32];
    int i = 0;
    
    if (value == 0) {
        buffer[0] = '0';
        buffer[1] = '\0';
        return 1;
    }
    
    while (value > 0) {
        int digit = value % base;
        if (digit < 10) {
            temp[i] = '0' + digit;
        } else {
            temp[i] = 'A' + (digit - 10);
        }
        i++;
        value /= base;
    }
    
    // Reverse the string
    int len = i;
    for (int j = 0; j < len; j++) {
        buffer[j] = temp[len - 1 - j];
    }
    buffer[len] = '\0';
    
    return len;
}

// Convert integer to string
int my_itoa(int value, char* buffer, int base) {
    if (value < 0) {
        buffer[0] = '-';
        return 1 + utoa_base(-value, buffer + 1, base);
    }
    return utoa_base(value, buffer, base);
}

// String length
size_t my_strlen(const char* str) {
    size_t len = 0;
    while (str[len]) len++;
    return len;
}

// String concatenation
char* my_strcat(char* dest, const char* src) {
    char* ptr = dest + my_strlen(dest);
    while (*src) {
        *ptr++ = *src++;
    }
    *ptr = '\0';
    return dest;
}

// String concatenation (alias for my_strcat)
char* strcat(char* dest, const char* src) {
    return my_strcat(dest, src);
}