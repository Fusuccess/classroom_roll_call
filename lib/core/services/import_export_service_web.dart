import 'dart:convert';
import 'dart:html' as html;

/// Web 平台的文件下载实现
void downloadFileWeb(String content, String fileName) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
