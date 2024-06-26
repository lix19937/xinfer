/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2015-2022 Advanced Micro Devices, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
#ifndef MIGRAPHX_GUARD_RTGLIB_QUANTIZE_INT8_HPP
#define MIGRAPHX_GUARD_RTGLIB_QUANTIZE_INT8_HPP

#include <string>
#include <vector>
#include <functional>
#include <migraphx/argument.hpp>
#include <migraphx/config.hpp>

namespace migraphx {
inline namespace MIGRAPHX_INLINE_NS {

struct program;
struct module;

/**
 * capture inputs of operators to be quantized to int8
 */
struct MIGRAPHX_EXPORT capture_arguments_pass
{
    std::vector<std::string> ins_names = {"dot", "convolution"};
    std::function<void(std::size_t, std::vector<argument>)> f{};
    std::size_t* param_index = nullptr;
    std::string name() const { return "capture_arguments"; }
    void apply(module& m) const;
};

/**
 * quantize a program to int8
 */
struct MIGRAPHX_EXPORT quantize_int8_pass
{
    std::vector<std::string> ins_names = {"dot", "convolution"};
    std::vector<std::pair<float, float>> quant_params;
    std::string name() const { return "quantize_int8"; }
    void apply(module& m) const;
};

} // namespace MIGRAPHX_INLINE_NS
} // namespace migraphx

#endif
