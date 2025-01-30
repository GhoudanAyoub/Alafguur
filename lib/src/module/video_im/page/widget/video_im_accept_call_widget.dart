import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../../../base/page/style/common_widget_style.dart';
import '../../../base/page/widget/modal_widget_mixin.dart';
import '../../../base/service/localization_service.dart';
import '../../service/model/video_im_call_data_model.dart';
import '../state/video_im_accept_call_state.dart';
import '../style/video_im_widget_style.dart';

final serviceLocator = GetIt.instance;

class VideoImAcceptCallWidget extends StatefulWidget with ModalWidgetMixin {
  final VideoImCallDataModel callData;

  VideoImAcceptCallWidget({
    required this.callData,
  });

  @override
  _VideoImAcceptCallWidgetState createState() =>
      _VideoImAcceptCallWidgetState();
}

class _VideoImAcceptCallWidgetState extends State<VideoImAcceptCallWidget> {
  late final VideoImAcceptCallState _state;

  @override
  void initState() {
    super.initState();

    _state = serviceLocator.get<VideoImAcceptCallState>();
    _state.init();
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldContainer(
      context,
      body: Observer(
        builder: (_) => videoImWidgetBlurBackroundWrapperContainer(
          Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
                          children: [
                            // "Incoming call from" text.
                            videoImWidgetActionTextContainer(
                              LocalizationService.of(context).t(
                                'vim_incoming_call',
                              ),
                              false,
                            ),
                            // Caller display name.
                            videoImWidgetNameTextContainer(
                              widget.callData.interlocutorDisplayName,
                            ),
                          ],
                        ),
                        videoImWidgetContWrapperContainer(
                          [
                            // Caller avatar.
                            videoImWidgetAvatarContainer(
                              widget.callData.interlocutorAvatarUrl,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Offer controls pane.
                  videoImWidgetButtonsWrapperContainer(
                    [
                      // Ringtone toggle button.
                      videoImWidgetRingtoneIconContainer(
                        context,
                        _state.isRingtoneEnabled
                            ? LocalizationService.of(context).t(
                                'vim_tooltip_disable_ringtone',
                              )
                            : LocalizationService.of(context).t(
                                'vim_tooltip_enable_ringtone',
                              ),
                        () => _changeRingtoneMode(),
                        _state.isRingtoneEnabled,
                      ),

                      // Accept call button.
                      videoImWidgetCallIconContainer(
                        context,
                        LocalizationService.of(context).t('vim_tooltip_accept'),
                        () => _acceptCall(),
                      ),

                      // Reject call button.
                      videoImWidgetEndCallIconContainer(
                        context,
                        LocalizationService.of(context).t('vim_tooltip_reject'),
                        () => _declineCall(),
                      ),

                      // Block caller button.
                      videoImWidgetBlockUserIconContainer(
                        context,
                        LocalizationService.of(context).t('vim_tooltip_block'),
                        () => _blockUser(),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
          widget.callData.interlocutorAvatarUrl,
        ),
      ),
    );
  }

  /// Enable or disable ringtone depending on its current state.
  void _changeRingtoneMode() {
    if (_state.isRingtoneEnabled) {
      _state.pauseRingtone();
    } else {
      _state.enableRingtone();
    }
  }

  /// Accept the incoming call.
  Future<void> _acceptCall() async {
    await _state.disableRingtone();

    if (_state.storedCandidates.isNotEmpty) {
      widget.callData.candidates = _state.storedCandidates;
    }

    Navigator.pop(context);

    _state.setActiveCallData(widget.callData);
  }

  /// Decline the incoming call.
  Future<void> _declineCall() async {
    await _state.disableRingtone();

    Navigator.pop(context);

    _state.declineCall(widget.callData);
  }

  /// Block the calling user.
  void _blockUser() {
    widget.showConfirmation(
      context,
      'vim_block_user_confirmation',
      () {
        Navigator.pop(context);
        _state.blockCaller(widget.callData);
      },
      yesLabel: 'ok',
      noLabel: 'cancel',
    );
  }
}
