import 'package:aixformation/aixformation.dart';
import 'package:cafetoria/cafetoria.dart';
import 'package:calendar/calendar.dart';
import 'package:frame/main.dart';
import 'package:substitution_plan/substitution_plan.dart';
import 'package:timetable/timetable.dart';

void main() => startApp(
      name: 'ViktoriaApp',
      features: [
        TimetableFeature(),
        SubstitutionPlanFeature(),
        CalendarFeature(),
        CafetoriaFeature(),
        AiXformationFeature(),
      ],
    );
