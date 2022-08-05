python
import sys
import os
sys.path.insert(0, os.environ.get("OPT_APP_PATH")+'/gdb_printer')
print(sys.path)
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers(None)
end
