#####################################################################################
# The MIT License (MIT)
#
# Copyright (c) 2015-2022 Advanced Micro Devices, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#####################################################################################

function(eval_and_strip_genex OUTPUT_VAR INPUT)
    string(REPLACE "$<LINK_LANGUAGE:CXX>" "1" INPUT "${INPUT}")
    string(REPLACE "$<COMPILE_LANGUAGE:CXX>" "1" INPUT "${INPUT}")
    string(REPLACE "SHELL:" "" INPUT "${INPUT}")
    string(REPLACE "$<BOOL:>" "0" INPUT "${INPUT}")
    string(REGEX REPLACE "\\$<BOOL:(0|FALSE|false|OFF|off|N|n|IGNORE|ignore|NOTFOUND|notfound)>" "0" INPUT "${INPUT}")
    string(REGEX REPLACE "\\$<BOOL:[^<>]*-NOTFOUND>" "0" INPUT "${INPUT}")
    string(REGEX REPLACE "\\$<BOOL:[^$<>]*>" "1" INPUT "${INPUT}")
    string(REPLACE "$<NOT:0>" "1" INPUT "${INPUT}")
    string(REPLACE "$<NOT:1>" "0" INPUT "${INPUT}")
    string(REGEX REPLACE "\\$<0:[^<>]*>" "" INPUT "${INPUT}")
    string(REGEX REPLACE "\\$<1:([^<>]*)>" "\\1" INPUT "${INPUT}")
    string(GENEX_STRIP "${INPUT}" INPUT)
    set(${OUTPUT_VAR} "${INPUT}" PARENT_SCOPE)
endfunction()

function(get_target_property2 VAR TARGET PROPERTY)
    get_target_property(_pflags ${TARGET} ${PROPERTY})
    if(_pflags)
        eval_and_strip_genex(_pflags "${_pflags}")
        set(${VAR} ${_pflags} PARENT_SCOPE)
    else()
        set(${VAR} "" PARENT_SCOPE)
    endif()
endfunction()

function(flags_requires_arg OUTPUT_VAR FLAG)
    set(_args -x -isystem)
    if(FLAG IN_LIST _args)
        set(${OUTPUT_VAR} 1 PARENT_SCOPE)
    else()
        set(${OUTPUT_VAR} 0 PARENT_SCOPE)
    endif()
endfunction()

macro(append_flags FLAGS TARGET PROPERTY PREFIX)
    get_target_property2(_pflags ${TARGET} ${PROPERTY})
    set(_requires_arg 0)
    foreach(FLAG ${_pflags})
        string(STRIP "${FLAG}" FLAG)
        if(FLAG)
            if(TARGET ${FLAG} AND NOT _requires_arg)
                target_flags(_pflags2 ${FLAG})
                string(APPEND ${FLAGS} " ${_pflags2}")
            else()
                string(APPEND ${FLAGS} " ${PREFIX}${FLAG}")
            endif()
            flags_requires_arg(_requires_arg "${FLAG}")
        endif()
    endforeach()
endmacro()

macro(append_link_flags FLAGS TARGET PROPERTY)
    get_target_property2(_pflags ${TARGET} ${PROPERTY})
    set(_requires_arg 0)
    foreach(FLAG ${_pflags})
        string(STRIP "${FLAG}" FLAG)
        if(FLAG)
            if(TARGET ${FLAG} AND NOT _requires_arg)
                target_flags(_pflags2 ${FLAG})
                string(APPEND ${FLAGS} " ${_pflags2}")
            elseif(FLAG MATCHES "^-.*")
                string(APPEND ${FLAGS} " ${FLAG}")
            elseif(EXISTS ${FLAG})
                string(APPEND ${FLAGS} " ${FLAG}")
            else()
                string(APPEND ${FLAGS} " -l${FLAG}")
            endif()
            flags_requires_arg(_requires_arg "${FLAG}")
        endif()
    endforeach()
endmacro()

function(target_flags FLAGS TARGET)
    set(_flags)
    append_flags(_flags ${TARGET} "INTERFACE_COMPILE_OPTIONS" "")
    append_flags(_flags ${TARGET} "INTERFACE_COMPILE_DEFINITIONS" "-D")
    append_flags(_flags ${TARGET} "INTERFACE_INCLUDE_DIRECTORIES" "-isystem ")
    append_flags(_flags ${TARGET} "INTERFACE_LINK_DIRECTORIES" "-L ")
    append_flags(_flags ${TARGET} "INTERFACE_LINK_OPTIONS" "")
    append_link_flags(_flags ${TARGET} "INTERFACE_LINK_LIBRARIES" "")
    # message("_flags: ${_flags}")
    set(${FLAGS} ${_flags} PARENT_SCOPE)
endfunction()
