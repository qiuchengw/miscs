python
import sys
sys.path.insert(0, '/configs/gdb_printer')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers(None)
end
