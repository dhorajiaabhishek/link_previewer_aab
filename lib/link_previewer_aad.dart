library link_previewer_aad;

import 'package:flutter/material.dart' hide Element;
import 'package:url_launcher/url_launcher.dart';

import 'parser/web_page_parser.dart';

part 'package:link_previewer_aad/content_direction.dart';
part 'package:link_previewer_aad/horizontal_link_view.dart';
part 'package:link_previewer_aad/vertical_link_preview.dart';

class LinkPreviewerAad extends StatefulWidget {
  LinkPreviewerAad({
    Key? key,
    required this.link,
    this.titleFontSize,
    this.bodyFontSize,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.deepOrangeAccent,
    this.titleTextColor = Colors.black,
    this.bodyTextColor = Colors.grey,
    this.defaultPlaceholderColor,
    this.borderRadius,
    this.placeholder,
    this.showTitle = true,
    this.showBody = true,
    this.direction = ContentDirection.horizontal,
    this.bodyTextOverflow,
    this.bodyMaxLines,
  }) : super(key: key);

  final String link;
  final double? titleFontSize;
  final double? bodyFontSize;
  final Color backgroundColor;
  final Color borderColor;
  final Color? defaultPlaceholderColor;
  final Color titleTextColor;
  final Color bodyTextColor;
  final double? borderRadius;
  final ContentDirection direction;
  final Widget? placeholder;
  final bool showTitle;
  final bool showBody;
  final TextOverflow? bodyTextOverflow;
  final int? bodyMaxLines;

  @override
  _LinkPreviewer createState() => _LinkPreviewer();
}

class _LinkPreviewer extends State<LinkPreviewerAad> {
  Map? _metaData;
  double? _height;
  String? _link;
  Color? _placeholderColor;
  bool _failedToLoadImage = false;

  @override
  void initState() {
    super.initState();
    _link = widget.link.trim();
    if (_link!.startsWith("https")) {
      _link = "http" + _link!.split("https")[1];
    }
    _placeholderColor = widget.defaultPlaceholderColor == null
        ? Color.fromRGBO(235, 235, 235, 1.0)
        : widget.defaultPlaceholderColor;
    _fetchData();
  }

  double _computeHeight(double screenHeight) {
    if (widget.direction == ContentDirection.horizontal) {
      return screenHeight * 0.12;
    } else {
      return screenHeight * 0.25;
    }
  }

  void _fetchData() {
    if (!isValidUrl(_link)) {
      throw Exception("Invalid link");
    } else {
      _getMetaData(_link);
    }
  }

  void _validateImageUri(uri) {
    precacheImage(NetworkImage(uri), context, onError: (e, stackTrace) {
      setState(() {
        _failedToLoadImage = true;
      });
    });
  }

  String? _getUriWithPrefix(uri) {
    return WebPageParser.addWWWPrefixIfNotExists(uri);
  }

  void _getMetaData(link) async {
    Map data = await WebPageParser.getData(link);
    if (data != null) {
      _validateImageUri(data['image']);
      setState(() {
        _metaData = data;
      });
    } else {
      setState(() {
        _metaData = null;
      });
    }
  }

  bool isValidUrl(link) {
    String regexSource =
        "^(https?)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";
    final regex = RegExp(regexSource);
    final matches = regex.allMatches(link);
    for (Match match in matches) {
      if (match.start == 0 && match.end == link.length) {
        return true;
      }
    }
    return false;
  }

  void _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    _height = _computeHeight(MediaQuery.of(context).size.height);

    return _metaData == null
        ? widget.placeholder == null
            ? _buildPlaceHolder(_placeholderColor, _height)
            : widget.placeholder!
        : _buildLinkContainer();
  }

  Widget _buildPlaceHolder(Color? color, double? defaultHeight) {
    return Container(
      height: defaultHeight,
      child: LayoutBuilder(builder: (context, constraints) {
        var layoutWidth = constraints.biggest.width;
        var layoutHeight = constraints.biggest.height;

        return Container(
          decoration: new BoxDecoration(
            color: color,
            border: Border.all(
              color: widget.borderColor == null
                  ? widget.backgroundColor
                  : widget.borderColor,
              width: widget.borderColor == null ? 0.0 : 1.0,
            ),
            borderRadius: BorderRadius.all(Radius.circular(
                widget.borderRadius == null ? 3.0 : widget.borderRadius!)),
          ),
          width: layoutWidth,
          height: layoutHeight,
        );
      }),
    );
  }

  Widget _buildLinkContainer() {
    return Container(
      decoration: new BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(
          color: widget.borderColor == null
              ? widget.backgroundColor
              : widget.borderColor,
          width: widget.borderColor == null ? 0.0 : 1.0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(
            widget.borderRadius == null ? 3.0 : widget.borderRadius!)),
      ),
      height: _height,
      child: _buildLinkView(
          _link,
          _metaData!['title'] == null ? "" : _metaData!['title'],
          _metaData!['description'] == null ? "" : _metaData!['description'],
          _metaData!['image'] == null ? "" : _metaData!['image'],
          _launchURL,
          widget.showTitle,
          widget.showBody,
          widget.borderRadius == null ? 3.0 : widget.borderRadius),
    );
  }

  Widget _buildLinkView(link, title, description, imageUri, onTap, showTitle,
      showBody, borderRadius) {
    if (widget.direction == ContentDirection.horizontal) {
      return HorizontalLinkView(
        url: link,
        title: title,
        description: description,
        imageUri: _failedToLoadImage == false
            ? imageUri
            : _getUriWithPrefix(imageUri)!,
        onTap: onTap,
        showTitle: showTitle,
        showBody: showBody,
        bodyTextOverflow: widget.bodyTextOverflow,
        bodyMaxLines: widget.bodyMaxLines,
        titleTextColor: widget.titleTextColor,
        bodyTextColor: widget.bodyTextColor,
        borderRadius: borderRadius,
      );
    } else {
      return VerticalLinkPreview(
        url: link,
        title: title,
        description: description,
        imageUri: _failedToLoadImage == false
            ? imageUri
            : _getUriWithPrefix(imageUri)!,
        onTap: onTap,
        showTitle: showTitle,
        showBody: showBody,
        bodyTextOverflow: widget.bodyTextOverflow,
        bodyMaxLines: widget.bodyMaxLines,
        titleTextColor: widget.titleTextColor,
        bodyTextColor: widget.bodyTextColor,
        borderRadius: borderRadius,
      );
    }
  }
}
