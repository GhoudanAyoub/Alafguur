import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../../service/model/form/form_element_model.dart';
import '../../widget/form/form_builder_widget.dart';
import '../common_widget_style.dart';

FormRendererCallback defaultFormRenderer() {
  return (
    Map<String, Widget> presentationMap,
    Map<String, FormElementModel> elementMap,
    BuildContext context,
  ) {
    String? latestPresentationGroup;

    List<Widget> presentationElementsList = [];
    presentationMap.forEach((elementKey, element) {
      final FormElementModel elementModel = elementMap[elementKey]!;

      // add a form element group
      if (elementModel.group != null &&
          elementModel.group != latestPresentationGroup) {
        latestPresentationGroup = elementModel.group;

        presentationElementsList.add(infoItemHeaderSectionContainer(
          context,
          elementModel.group,
        ));
      }

      bool isRtlModeActive = isRtlMode(context);

      // collect all form elements
      presentationElementsList.add(Styled.widget(child: element).padding(
        left: !isRtlModeActive ? 16 : 0,
        right: isRtlModeActive ? 16 : 0,
      ));
    });

    return Column(
      children: presentationElementsList,
    );
  };
}

FormRendererCallback blankPagesFormRenderer() {
  return (
    Map<String, Widget> presentationMap,
    Map<String, FormElementModel> elementMap,
    BuildContext context,
  ) {
    List<Widget> presentationElementsList = [];
    presentationMap.forEach((elementKey, element) {
      // collect all form elements
      presentationElementsList.add(element);
    });

    return Column(
      children: presentationElementsList,
    );
  };
}
