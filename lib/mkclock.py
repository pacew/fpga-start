#! /usr/bin/env python

import subprocess
import re
import sys

def mkclock(freq):
    result = subprocess.run(f'icepll -i 12 -o {freq/1e6} -m -f TMP.pll.v',
                            capture_output=True,
                            shell=True)
    if result.returncode != 0:
        print(result.stderr)
        sys.exit(1)

    pll = open('TMP.pll.v').read()

    pll = re.sub('(.*SB_PLL40_CORE)', 'wire clock_internal;\n\\1', pll)
    pll = re.sub('PLLOUTCORE\\(clock_out\\)', 
                 'PLLOUTGLOBAL(clock_internal)', pll)
    pll = re.sub('(endmodule)', 
                 ('SB_GB sbGlobalBuffer_inst(\n'
                  ' .USER_SIGNAL_TO_GLOBAL_BUFFER(clock_internal),\n'
                  ' .GLOBAL_BUFFER_OUTPUT(clock_out));\n\n'
                  '\\1'),
                 pll)

    with open('pll.v', 'w') as outf:
        outf.write(pll)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('usage: mkclock.py freq_mhz')
        sys.exit(1)

    freq = float(sys.argv[1]) * 1e6
    mkclock(freq)
