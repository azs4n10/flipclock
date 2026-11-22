import 'package:shared_preferences/shared_preferences.dart';

import 'background_photo_store.dart';

BackgroundPhotoStore createBackgroundPhotoStore(SharedPreferences prefs) =>
    PrefsBackgroundPhotoStore(prefs);
