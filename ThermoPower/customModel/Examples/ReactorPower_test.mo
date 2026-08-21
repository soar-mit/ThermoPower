within ThermoPower.customModel.Examples;

model ReactorPower_test
  Models.ReactorPower reactorPower(P0 = 1, usePKE = true, useRhoExt = true, n_start = 1, useXe = false)  annotation(
    Placement(transformation(origin = {10, 54}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp(offset = 0.00657*0.25, startTime = 10, height = -0.00657*0.25, duration = 0)  annotation(
    Placement(transformation(origin = {-74, 34}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Logical.Switch switch1 annotation(
    Placement(transformation(origin = {-24, 54}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant const(k = 0)  annotation(
    Placement(transformation(origin = {-74, 78}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.BooleanExpression booleanExpression(y = time < 1) annotation(
    Placement(transformation(origin = {-74, 54}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.customModel.Models.ReactorPower reactorPower1(P0 = 1, n_start = 1, usePKE = true, useRhoExt = true, useXe = true) annotation(
    Placement(transformation(origin = {10, -36}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp1(duration = 0, height = -0.05, offset = 0, startTime = 5) annotation(
    Placement(transformation(origin = {-74, -56}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Logical.Switch switch11 annotation(
    Placement(transformation(origin = {-24, -36}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Constant const1(k = 0) annotation(
    Placement(transformation(origin = {-74, -12}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.BooleanExpression booleanExpression1(y = time < 5) annotation(
    Placement(transformation(origin = {-74, -36}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(const.y, switch1.u1) annotation(
    Line(points = {{-63, 78}, {-53, 78}, {-53, 62}, {-37, 62}}, color = {0, 0, 127}));
  connect(booleanExpression.y, switch1.u2) annotation(
    Line(points = {{-63, 54}, {-36, 54}}, color = {255, 0, 255}));
  connect(ramp.y, switch1.u3) annotation(
    Line(points = {{-63, 34}, {-53, 34}, {-53, 46}, {-37, 46}}, color = {0, 0, 127}));
  connect(switch1.y, reactorPower.rho_ext) annotation(
    Line(points = {{-13, 54}, {1, 54}}, color = {0, 0, 127}));
  connect(const1.y, switch11.u1) annotation(
    Line(points = {{-63, -12}, {-53, -12}, {-53, -28}, {-37, -28}}, color = {0, 0, 127}));
  connect(booleanExpression1.y, switch11.u2) annotation(
    Line(points = {{-63, -36}, {-36, -36}}, color = {255, 0, 255}));
  connect(ramp1.y, switch11.u3) annotation(
    Line(points = {{-63, -56}, {-53, -56}, {-53, -44}, {-37, -44}}, color = {0, 0, 127}));
  connect(switch11.y, reactorPower1.rho_ext) annotation(
    Line(points = {{-13, -36}, {1, -36}}, color = {0, 0, 127}));
  annotation(
    experiment(StartTime = 0, StopTime = 180000, Tolerance = 1e-06, Interval = 60),
  Diagram(graphics = {Text(origin = {-24, 88}, extent = {{-16, 8}, {16, -8}}, textString = "Case1"), Text(origin = {-24, -6}, extent = {{-16, 8}, {16, -8}}, textString = "Case2")}));
end ReactorPower_test;