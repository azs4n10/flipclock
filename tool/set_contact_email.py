"""Set the contact address used by the privacy policy and the feedback entry.

    py tool/set_contact_email.py hello@example.com
"""
import io
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent


def main() -> int:
    if len(sys.argv) != 2 or '@' not in sys.argv[1]:
        print(__doc__)
        return 1
    address = sys.argv[1]

    dart = ROOT / 'lib/services/app_actions.dart'
    text = dart.read_text(encoding='utf-8')
    new_text, n = re.subn(r"static const String contactEmail = '[^']*';",
                          f"static const String contactEmail = '{address}';",
                          text)
    if n != 1:
        print(f'could not find contactEmail in {dart}')
        return 1
    dart.write_text(new_text, encoding='utf-8')

    policy = ROOT / 'web/privacy.html'
    text = policy.read_text(encoding='utf-8')
    previous = re.search(r'mailto:([^"]+)"', text)
    if not previous:
        print(f'could not find the contact link in {policy}')
        return 1
    old = previous.group(1)
    policy.write_text(text.replace(old, address), encoding='utf-8')

    print(f'contact address set to {address}')
    print('files updated: lib/services/app_actions.dart, web/privacy.html')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
