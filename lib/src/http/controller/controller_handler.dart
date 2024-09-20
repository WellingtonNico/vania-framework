import 'package:vania/src/exception/validation_exception.dart';
import 'package:vania/src/route/route_data.dart';
import 'package:vania/vania.dart';

class ControllerHandler {
  void create({
    required RouteData route,
    required Request request,
  }) async {
    List<dynamic> positionalArguments = [];

    if (route.params != null) {
      positionalArguments = route.params!.values
          .map((param) => int.tryParse(param) ?? param)
          .toList();
    }

    if (route.hasRequest) {
      positionalArguments.insert(0, request);
    }

    try {
      Response response = await Function.apply(
        route.action,
        positionalArguments,
        {},
      );

      response.makeResponse(request.response);
    } on ValidationException catch (error) {
      print(request.headers['accept']);
      print(request.headers['accept'].contains('html'));
      error
          .response(request.headers['accept'].toString().contains('html'))
          .makeResponse(request.response);
    } catch (error) {
      _response(request, error.toString());
    }
  }
}

void _response(Request req, message, [statusCode = 400]) {
  if (req.headers['accept'].toString().contains('html')) {
     Response.html(message).makeResponse(req.response);
  } else {
    Response.json(
      {
        "message": message,
      },
      statusCode,
    ).makeResponse(req.response);
  }
}
