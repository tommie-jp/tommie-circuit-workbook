#!/usr/bin/env python3
"""インストール済みの Verilator 5.042 の verilated.cpp に、5-1 の表の 3 と同じ趣旨の直し
(<iostream>・<sstream> を外し、文字列ストリームを固定の文に替える) を当てて Pico 用の写しを作る。
Soft-FPGA-Reversi の verilated.cpp は 5.048 用で、5.042 のヘッダでは通らないため、手元の確かめに使った。
使い方: python3 make-pico-runtime.py > verilated.cpp"""
import sys
s = open('/usr/local/share/verilator/include/verilated.cpp').read()
def rep(old, new):
    global s
    if old not in s:
        sys.exit('no match: ' + old[:40])
    s = s.replace(old, new)
rep('#include <iostream>\n', '')
rep('#include <sstream>\n', '#include <memory>\n')
rep('''                std::ostringstream oss;
                for (unsigned char c : *cstr) oss << std::hex << static_cast<int>(c);
                std::string hex_str = oss.str();''', '''                std::string hex_str;
                for (unsigned char c : *cstr) { char b[4]; snprintf(b, sizeof b, "%x", (int)c); hex_str += b; }''')
rep('''        std::ostringstream msg;
        msg << "VerilatedContext has " << m_threads << " threads but model '"
            << modelp->modelName() << "' (instantiated as '" << modelp->hierName()
            << "') was Verilated with --threads " << modelp->threads() << ".\\n";
        const std::string str = msg.str();
        VL_FATAL_MT(__FILE__, __LINE__, modelp->hierName(), str.c_str());''',
    '''        VL_FATAL_MT(__FILE__, __LINE__, modelp->hierName(), "thread count mismatch");''')
rep('''            std::stringstream ss;
            ss << "Argument '" << prefix << "' must be an unsigned integer";
            if (min != std::numeric_limits<uint64_t>::min()) ss << ", greater than " << min - 1;
            if (max != std::numeric_limits<uint64_t>::max()) ss << ", less than " << max + 1;
            if (!extra.empty()) ss << ". " << extra;
            const std::string& msg = ss.str();
            VL_FATAL_MT("COMMAND_LINE", 0, "", msg.c_str());''',
    '''            (void)extra;
            VL_FATAL_MT("COMMAND_LINE", 0, "", "Bad unsigned integer argument");''')
rep('''    std::ostringstream msg;
    msg << "SystemC's sc_set_time_resolution is 10^-" << sc_prec
        << ", which does not match Verilog timeprecision 10^-" << vl_prec
        << ". Suggest use 'sc_set_time_resolution(" << vl_time_str(vl_prec)
        << ")', or Verilator '--timescale-override " << vl_time_str(sc_prec) << "/"
        << vl_time_str(sc_prec) << "'";
    const std::string msgs = msg.str();
    VL_FATAL_MT("", 0, "", msgs.c_str());''', '''    (void)sc_prec; (void)vl_prec;
    VL_FATAL_MT("", 0, "", "SystemC time precision mismatch");''')
sys.stdout.write(s)
