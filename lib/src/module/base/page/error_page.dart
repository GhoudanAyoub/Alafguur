import 'package:flutter/material.dart';

import '../../../app/exception/http/complete_account_exception.dart';
import '../../../app/exception/http/complete_profile_exception.dart';
import '../../../app/exception/http/disapproved_exception.dart';
import '../../../app/exception/http/email_not_verified_exception.dart';
import '../../../app/exception/http/maintenance_exception.dart';
import '../../../app/exception/http/no_internet_exception.dart';
import '../../../app/exception/http/not_found_exception.dart';
import '../../../app/exception/http/phone_code_not_verified_exception.dart';
import '../../../app/exception/http/phone_number_not_verified_exception.dart';
import '../../../app/exception/http/server_exception.dart';
import '../../../app/exception/http/suspended_exception.dart';
import '../../../app/exception/http/unauthorized_exception.dart';
import '../../login/page/login_page.dart';
import 'widget/error/complete_account_widget.dart';
import 'widget/error/complete_profile_widget.dart';
import 'widget/error/general_error_widget.dart';
import 'widget/error/maintenance_widget.dart';
import 'widget/error/no_internet_widget.dart';
import 'widget/error/not_found_widget.dart';
import 'widget/error/user_disapproved_widget.dart';
import 'widget/error/user_suspended_widget.dart';
import 'widget/error/verify_email_widget.dart';
import 'widget/error/verify_phone_code_widget.dart';
import 'widget/error/verify_phone_number_widget.dart';

class ErrorPage extends StatelessWidget {
  // the base type might be either 'Exception' or 'Error'
  final error;
  final StackTrace? stackTrace;
  final bool isAppLoaded;

  const ErrorPage({
    Key? key,
    required this.error,
    this.stackTrace,
    this.isAppLoaded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _logError();

    if (error is Error) {
      return _errorWidget();
    }

    return _exceptionWidget();
  }

  void _logError() {
    print('Caught error: $error');
    print('stackTrace: $stackTrace');
  }

  Widget _errorWidget() {
    return GeneralErrorWidget(isAppLoaded: isAppLoaded);
  }

  Widget _exceptionWidget() {
    final exceptionType = error.runtimeType;
    final apiResponseData = error is ServerException && error.response != null
        ? error.response.data
        : null;

    switch (exceptionType) {
      case NoInternetException:
        return NoInternetWidget();

      case UnauthorizedException:
        return LoginPage(clearCredentials: true);

      case MaintenanceException:
        return MaintenanceWidget();

      case NotFoundException:
        return NotFoundWidget();

      case SuspendedException:
        return UserSuspendedWidget(
          exceptionResponseBody: apiResponseData,
        );

      case DisapprovedException:
        return UserDisapprovedWidget();

      case CompleteProfileException:
        return CompleteProfileWidget();

      case EmailNotVerifiedException:
        return VerifyEmailWidget();

      case PhoneNumberNotVerifiedException:
        return VerifyPhoneNumberWidget();

      case PhoneCodeNotVerifiedException:
        return VerifyPhoneCodeWidget();

      case CompleteAccountException:
        return CompleteAccountWidget();

      default:
    }

    return GeneralErrorWidget(isAppLoaded: isAppLoaded);
  }
}
