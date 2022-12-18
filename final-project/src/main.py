import sys

import all_report
import bsr_report
import dips_report
import pythagorean_report


def main() -> int:
    pythagorean_report.report_pythagoreans()
    bsr_report.report_bsrs()
    dips_report.report_dips()
    all_report.report_all()
    return 0


if __name__ == "__main__":
    sys.exit(main())
