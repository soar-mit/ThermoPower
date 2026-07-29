within ThermoPower.customModel.Examples;

model Deaeratort_test
  Deaerator deaerator(V = 30, pstart = 1e5)  annotation(
    Placement(transformation(origin = {-12, 68}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SourceMassFlow sourceMassFlow(T = 473.15, p0 = 1e5, use_T = true, w0 = 0.05) annotation(
    Placement(transformation(origin = {-52, 82}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SinkPressure sinkPressure(p0 = 1e5)  annotation(
    Placement(transformation(origin = {22, 68}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SourceMassFlow sourceMassFlow1(T = 323.15, p0 = 1e5, use_T = true, w0 = 1) annotation(
    Placement(transformation(origin = {-50, 58}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(sourceMassFlow.flange, deaerator.SteamIn) annotation(
    Line(points = {{-42, 82}, {-30, 82}, {-30, 74}, {-20, 74}}, color = {0, 0, 255}));
  connect(sourceMassFlow1.flange, deaerator.WaterIn) annotation(
    Line(points = {{-40, 58}, {-30, 58}, {-30, 62}, {-20, 62}}, color = {0, 0, 255}));
  connect(deaerator.CondOut, sinkPressure.flange) annotation(
    Line(points = {{-2, 68}, {12, 68}}, color = {0, 0, 255}));
annotation(
    experiment(StartTime = 0, StopTime = 10, Tolerance = 1e-06, Interval = 0.02));
end Deaeratort_test;
