import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:voice_recorder/models/pdf_save_model.dart';
import 'package:voice_recorder/models/vocie_save_model.dart';
import 'package:voice_recorder/utils/pdf/save_pdf.dart';

// class PDFopen extends StatelessWidget {
//   PDFopen({this.pdfSaveModel, super.key});
//   PDFSaveModel? pdfSaveModel;

//   @override
//   Widget build(BuildContext context) {
//     return PdfPreview(
//         canChangeOrientation: false,
//         allowSharing: false,
//         canChangePageFormat: false,
//         allowPrinting: false,
//         canDebug: false,
//         build: (format) =>
//             PdfAttendanceApi.generate(pdfSaveModel: pdfSaveModel));
//   }
// }

class PdfAttendanceApi {
  Future<File> generate({
    PDFSaveModel? pdfSaveModel,
    VoiceSaveModel? voiceSaveModel,
    String? imageData,
    Map<String, dynamic>? item,
  }) async {
    final pdf = pw.Document();

    pw.TextStyle pdfStyleTwo =
        const pw.TextStyle(fontSize: 55, color: PdfColor.fromInt(0xFF6E6E6E));

    pw.TextStyle pdfStyleCursive = pw.TextStyle(
        fontSize: 63,
        color: PdfColor.fromHex("#6E6E6E"),
        fontStyle: pw.FontStyle.italic,
        letterSpacing: 1.3);

    final assetImage = await imageFromAssetBundle('assets/proof/proof_raw.png');

    final data = jsonEncode({
      'voiceSaveModel': voiceSaveModel?.toJson(),
      'imageData': imageData ?? '',
      'allowMediaSharing': true,
      'item': item.toString(),
      'eventDescription': 'description',
    });

    var qrImage = await getQrImage(data, pdfSaveModel!.hash.toString());

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(
              top: 0, left: 12, right: 12, bottom: -20),
          child: pw.Center(
            child: pw.Column(
              children: [
                pw.Align(
                  alignment: pw.Alignment.topCenter,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.SizedBox(height: 1280),
                      pw.Text(pdfSaveModel.userName.toString(),
                          style: pw.TextStyle(
                              color: PdfColor.fromHex("#34567F"),
                              fontSize: 95,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 200),
                      pw.Text('"${pdfSaveModel.fileName}"',
                          style: pdfStyleCursive),
                      pw.SizedBox(height: 280),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 75),
                        child: pw.Text(
                          pdfSaveModel.description.toString(),
                          maxLines: 6,
                          style: pdfStyleTwo,
                          textAlign: pw.TextAlign.center,
                          overflow: pw.TextOverflow.clip,
                        ),
                      ),
                      pw.SizedBox(height: 35),
                      pw.Text(
                        'Bc Proof: ',
                        maxLines: 1,
                        style: pdfStyleCursive,
                        textAlign: pw.TextAlign.center,
                        overflow: pw.TextOverflow.clip,
                      ),
                      pw.Text(
                        pdfSaveModel.bcProof.toString(),
                        maxLines: 6,
                        style: pdfStyleTwo,
                        textAlign: pw.TextAlign.center,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.bottomCenter,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(pdfSaveModel.timeStamp.toString(),
                          maxLines: 1, style: pdfStyleTwo),
                      pw.SizedBox(height: 188),
                      pw.Text(pdfSaveModel.registeredContent.toString(),
                          style: pdfStyleTwo, maxLines: 1),
                      pw.SizedBox(height: 188),
                      pw.Text(pdfSaveModel.transactionID.toString(),
                          maxLines: 1, style: pdfStyleTwo),
                      pw.SizedBox(height: 188),
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 10),
                        child: pw.UrlLink(
                          child: pw.Text(
                              pdfSaveModel.bcExplorer
                                  .toString()
                                  .replaceAll("https://", ""),
                              style: pdfStyleTwo,
                              maxLines: 2,
                              overflow: pw.TextOverflow.clip),
                          destination: pdfSaveModel.bcExplorer.toString(),
                        ),
                      ),
                      pw.SizedBox(height: 315),
                      pw.Padding(
                          child: pw.Image(
                              pw.MemoryImage(qrImage.readAsBytesSync()),
                              width: 190,
                              height: 190),
                          padding: pw.EdgeInsets.only(left: 5)),
                      pw.SizedBox(height: 288),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat(3000, 4000),
          theme: pw.ThemeData.withFont(),
          buildBackground: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(assetImage, fit: pw.BoxFit.fill)),
        ),
      ),
    );
    //return pdf.save();
    return SavePdf.saveDocument(name: '${pdfSaveModel.fileName}.pdf', pdf: pdf);
  }

  String removeLastLetters(String text, int count) {
    return text.substring(0, text.length - count);
  }

  String removeSubStringAfterDot(String text) {
    return text.substring(0, text.indexOf('.'));
  }

  Future<File> getQrImage(String data, String hash) async {
    var localimg = await getQrImageLocally(hash);
    if (localimg != null) return localimg;

    var requrl =
        "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$data&bgcolor=E9B94B";
    return getTemporaryDirectory().then((dir) {
      String fileName = "${Random().nextInt(1000)}.png";
      File file = File('${dir.path}/$fileName');
      if (file.existsSync()) {
        return file;
      } else {
        return Dio()
            .get(requrl, options: Options(responseType: ResponseType.bytes))
            .then((res) {
          return file.writeAsBytes(res.data).then((file) async {
            print("QR Code length: " + res.data.length.toString());
            await saveQrImageLocally(file, hash);
            return file;
          });
        });
      }
    });
  }

  Future<void> saveQrImageLocally(File qrImage, String hash) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/$hash.png');
    await file.writeAsBytes(qrImage.readAsBytesSync());
    print("Saved generated qrcode: $path/$hash.png");
    return;
  }

  Future<File?> getQrImageLocally(String hash) async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/$hash.png');
    if (file.existsSync()) {
      return file;
    } else {
      print("Not found generated qrcode: $path/$hash.png");
      return null;
    }
  }
}
