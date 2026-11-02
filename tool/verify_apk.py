"""Check that a packaged APK contains the runnable app and bundled UI assets."""
import hashlib
import sys
from pathlib import Path
from zipfile import ZipFile

apk = Path(sys.argv[1] if len(sys.argv) > 1 else 'artifacts/Balb-1.0.0-android.apk')
required = [
    'lib/arm64-v8a/libapp.so',
    'lib/x86_64/libapp.so',
    'assets/flutter_assets/assets/images/feed.png',
    'assets/flutter_assets/assets/fonts/PlusJakartaSans.ttf',
]
with ZipFile(apk) as archive:
    for name in required:
        assert archive.getinfo(name).file_size > 0, name
    assert archive.testzip() is None, 'APK archive is corrupt'
print(f'APK verified: {apk.name} ({apk.stat().st_size / 1024**2:.1f} MiB)')
print(f'SHA-256: {hashlib.sha256(apk.read_bytes()).hexdigest().upper()}')
