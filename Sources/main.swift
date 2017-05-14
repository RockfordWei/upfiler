import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

func home(data : [String: Any]) throws -> RequestHandler {
  return {
    _ , r in
    r.setHeader(.contentType, value: "text/html").appendBody(string:
      "<html><head><title>Simple Uploads</title>" +
      "<meta http-equiv='Content-Type' content='text/html;charset=utf-8'></head>" +
      "<body><form method=POST enctype='multipart/form-data' action='/upload'>" +
      "<p>手机号<input type=text name=mobile></p>" +
      "<p>用户名<input type=text name=username></p>" +
      "File to upload: <input type=file name='fileup'>" +
      "<input type=submit></form></body></html>").completed()
  }
}

func upload(data : [String: Any]) throws -> RequestHandler {
  return {
    request, response in

    guard let uploads = request.postFileUploads else {
      response.status = .badGateway
      response.completed()
      return
    }//end guard
    let info = uploads.map { u-> String in
      let i:[String: String] = [
        "fieldName": u.fieldName,
        "fieldValue": u.fieldValue,
        "fileName": u.fileName,
        "fileSize": "\(u.fileSize)",
        "tmpFileName": u.tmpFileName
      ]
      return i.map { "\($0): \($1)" }.joined(separator: "<br>\n")
    }.joined(separator: "<hr>")
    response.setHeader(.contentType, value: "text/html")
      .appendBody(string: info).completed()
  }
}

do {
  try HTTPServer.launch(configurationData: [
    "servers": [
      [
        "name": "localhost",
        "port": 8080,
        "routes": [
          ["method":"post", "uri":"/upload", "handler": upload],
          ["method":"get", "uri":"/", "handler": home],
        ]
      ]
    ]
    ])
}catch{
  fatalError("\(error)")
}
