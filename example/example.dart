import 'package:flutter/material.dart';
import 'package:link_previewer_aad/link_previewer_aad.dart';

Widget build() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      LinkPreviewerAad(
        link: "https://www.linkedin.com/feed/",
        direction: ContentDirection.horizontal,
      ),
      LinkPreviewerAad(
        link: "https://www.linkedin.com/feed/",
        direction: ContentDirection.vertical,
      ),
    ],
  );
}
