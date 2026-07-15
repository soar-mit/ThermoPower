within ThermoPower.customModel.Tests;

model IdeaDeaerator_test
  inner System system(initOpt = ThermoPower.Choices.Init.Options.fixedState)  annotation(
    Placement(transformation(origin = {86, 84}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SourcePressure sourcePressure1(p0 = 3e5, use_T = true, T = 573.15)  annotation(
    Placement(transformation(origin = {-70, 80}, extent = {{-10, -10}, {10, 10}})));
  Water.SourceMassFlow sourceMassFlow(w0 = 10, p0 = 3e5, use_T = true, T = 371.15)  annotation(
    Placement(transformation(origin = {-72, 54}, extent = {{-10, -10}, {10, 10}})));
  IdealDeaerator idealDeaerator(pstart = 3e5)  annotation(
    Placement(transformation(origin = {-30, 70}, extent = {{-10, -10}, {10, 10}})));
  Water.Tank tank(A = 10, V0 = 1000, ystart = 10+ 10.3133)  annotation(
    Placement(transformation(origin = {14, 76}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(idealDeaerator.waterOut, tank.inlet) annotation(
    Line(points = {{-20, 70}, {6, 70}}, color = {0, 0, 255}));
  connect(sourcePressure1.flange, idealDeaerator.condensateIn) annotation(
    Line(points = {{-60, 80}, {-52, 80}, {-52, 76}, {-40, 76}}, color = {0, 0, 255}));
  connect(sourceMassFlow.flange, idealDeaerator.steamIn) annotation(
    Line(points = {{-62, 54}, {-50, 54}, {-50, 66}, {-40, 66}, {-40, 64}}, color = {0, 0, 255}));
  annotation(
    experiment(StartTime = 0, StopTime = 100, Tolerance = 1e-06, Interval = 0.2));
end IdeaDeaerator_test;