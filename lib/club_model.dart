library hms_models;

//region Dependencies
//region Utils
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:equatable/equatable.dart';
export 'package:intl/intl.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:uuid/uuid.dart';
//endregion

// region State Management
export 'package:provider/provider.dart';
//endregion

// region Offline Database
export 'package:hive/hive.dart';
//endregion

//region UI
export 'package:cached_network_image/cached_network_image.dart';
export 'package:cupertino_icons/cupertino_icons.dart';
export 'package:font_awesome_flutter/font_awesome_flutter.dart';
export 'package:google_fonts/google_fonts.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
export 'package:flutter_spinkit/flutter_spinkit.dart';
export 'package:loading_animation_widget/loading_animation_widget.dart';
export 'package:shimmer/shimmer.dart';
export 'package:fluttertoast/fluttertoast.dart';
export 'package:top_snackbar_flutter/top_snack_bar.dart';
//endregion

//region Firebase
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:firebase_analytics/firebase_analytics.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
//endregion

// region Api Operations
export 'package:http/http.dart';
//endregion

// region File Operations
export 'package:file_picker/file_picker.dart';
export 'package:image_cropper/image_cropper.dart';
//endregion
//endregion

//region Backend
//region Analytics
export 'backend/analytics/analytics_controller.dart';
//endregion

//region App Theme
export 'backend/app_theme/app_theme_provider.dart';
//endregion

//region Common
export 'backend/common/app_controller.dart';
export 'backend/common/common_provider.dart';
export 'backend/common/data_controller.dart';
export 'backend/common/firestore_controller.dart';
//endregion

//region Connection
export 'backend/connection/connection_controller.dart';
export 'backend/connection/connection_provider.dart';
//endregion

//region Navigation
export 'backend/navigation/navigation_arguments.dart';
export 'backend/navigation/navigation_operation.dart';
export 'backend/navigation/navigation_operation_parameters.dart';
export 'backend/navigation/navigation_type.dart';
//endregion

//endregion

//region Configs
export 'configs/app_strings.dart';
export 'configs/app_theme.dart';
export 'configs/constants.dart';
export 'configs/error_codes_and_messages.dart';
export 'configs/styles.dart';
export 'configs/typedefs.dart';
//endregion

//region Models
// region AdminUser
export 'models/admin_user/data_model/admin_user_model.dart';
//endregion

//region Club
export 'models/club/data_model/club_model.dart';
//endregion

//region Common
export 'models/common/data_model/new_document_data_model.dart';
export 'models/common/data_model/property_model.dart';
//endregion

//region Location
export 'models/location/data_model/location_model.dart';
//endregion

//region Product
export 'models/product/data_model/product_model.dart';
//endregion

//region User
export 'models/user/data_model/user_model.dart';
export 'models/user/request_model/profile_update_request_model.dart';
//endregion
//endregion

//region Utils
export 'utils/date_representation.dart';
export 'utils/extensions.dart';
export 'utils/hive_manager.dart';
export 'utils/my_http_overrides.dart';
export 'utils/my_print.dart';
export 'utils/my_safe_state.dart';
export 'utils/my_toast.dart';
export 'utils/my_utils.dart';
export 'utils/parsing_helper.dart';
export 'utils/shared_pref_manager.dart';
//endregion

//region View
//region Common
//region Components
export 'view/common/components/loading_widget.dart';
export 'view/common/components/modal_progress_hud.dart';
//endregion
//endregion
//endregion
