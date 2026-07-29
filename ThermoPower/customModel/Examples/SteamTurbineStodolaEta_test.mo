within ThermoPower.customModel.Examples;

model SteamTurbineStodolaEta_test
  ThermoPower.Water.SourceMassFlow sourceMassFlow(T = 823.15, p0(displayUnit = "MPa") = 1.574e6, use_T = false, w0 = 50, h = 2950366, use_in_w0 = true) annotation(
    Placement(transformation(origin = {-94, 52}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SinkPressure sinkPressure(p0(displayUnit = "kPa") = 2e4, use_T = true, T = 331.15) annotation(
    Placement(transformation(origin = {-22, 52}, extent = {{-10, -10}, {10, 10}})));
  inner ThermoPower.System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
    Placement(transformation(origin = {-160, 68}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Electrical.Generator generator(Pnom(displayUnit = "MW") = 7.03e7) annotation(
    Placement(transformation(origin = {-24, 30}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp(height = 0, duration = 0, offset = 50, startTime = 10) annotation(
    Placement(transformation(origin = {-126, 52}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SourceMassFlow sourceMassFlow1(T = 823.15, h = 2950366, p0(displayUnit = "MPa") = 1.574e6, use_T = false, use_in_w0 = true, w0 = 50) annotation(
    Placement(transformation(origin = {-94, -28}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SinkPressure sinkPressure1(T = 331.15, p0(displayUnit = "kPa") = 2e4, use_T = true) annotation(
    Placement(transformation(origin = {-22, -28}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Electrical.Generator generator1(Pnom(displayUnit = "MW") = 7.03e7) annotation(
    Placement(transformation(origin = {-24, -50}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp1(duration = 0, height = -5, offset = 50, startTime = 10) annotation(
    Placement(transformation(origin = {-126, -28}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SourceMassFlow sourceMassFlow11(T = 823.15, h = 2950366, p0(displayUnit = "MPa") = 1.574e6, use_T = false, use_in_w0 = true, w0 = 50) annotation(
    Placement(transformation(origin = {50, 50}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SinkPressure sinkPressure11(T = 331.15, p0(displayUnit = "kPa") = 2e4, use_T = true) annotation(
    Placement(transformation(origin = {122, 50}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Electrical.Generator generator11(Pnom(displayUnit = "MW") = 7.03e7) annotation(
    Placement(transformation(origin = {120, 28}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp11(duration = 0, height = -5, offset = 50, startTime = 10) annotation(
    Placement(transformation(origin = {18, 50}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SourceMassFlow sourceMassFlow111(T = 823.15, h = 2950366, p0(displayUnit = "MPa") = 1.574e6, use_T = false, use_in_w0 = true, w0 = 50) annotation(
    Placement(transformation(origin = {56, -32}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Water.SinkPressure sinkPressure111(T = 331.15, p0(displayUnit = "kPa") = 2e4, use_T = true) annotation(
    Placement(transformation(origin = {128, -32}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.Electrical.Generator generator111(Pnom(displayUnit = "MW") = 7.03e7) annotation(
    Placement(transformation(origin = {126, -54}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Sources.Ramp ramp111(duration = 0, height = -5, offset = 50, startTime = 10) annotation(
    Placement(transformation(origin = {24, -32}, extent = {{-10, -10}, {10, 10}})));
  Models.SteamTurbineStodolaEta steamTurbineStodolaEta(wnom = 50, pnom(displayUnit = "MPa") = 1.573e6, eta_iso_nom = 0.85, Kt = 0.017, PRstart = 78.65)  annotation(
    Placement(transformation(origin = {-62, 44}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.customModel.Models.SteamTurbineStodolaEta steamTurbineStodolaEta1(Kt = 0.017, eta_iso_nom = 0.85, pnom(displayUnit = "MPa") = 1.573e6, wnom = 50, useMflowCorrection = true, PRstart = 78.65) annotation(
    Placement(transformation(origin = {86, 42}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.customModel.Models.SteamTurbineStodolaEta steamTurbineStodolaEta2(Kt = 0.017, eta_iso_nom = 0.85, pnom(displayUnit = "MPa") = 1.573e6, wnom = 50, useWetnessCorrection = true, PRstart = 78.65) annotation(
    Placement(transformation(origin = {-60, -36}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.customModel.Models.SteamTurbineStodolaEta steamTurbineStodolaEta21(Kt = 0.017, eta_iso_nom = 0.85, pnom(displayUnit = "MPa") = 1.573e6, wnom = 50, useWetnessCorrection = true, useMflowCorrection = true, PRstart = 78.65) annotation(
    Placement(transformation(origin = {92, -40}, extent = {{-10, -10}, {10, 10}})));
equation
  connect(ramp.y, sourceMassFlow.in_w0) annotation(
    Line(points = {{-115, 52}, {-109, 52}, {-109, 64}, {-99, 64}, {-99, 58}}, color = {0, 0, 127}));
  connect(ramp1.y, sourceMassFlow1.in_w0) annotation(
    Line(points = {{-115, -28}, {-109, -28}, {-109, -16}, {-99, -16}, {-99, -22}}, color = {0, 0, 127}));
  connect(ramp11.y, sourceMassFlow11.in_w0) annotation(
    Line(points = {{29, 50}, {35, 50}, {35, 62}, {45, 62}, {45, 56}}, color = {0, 0, 127}));
  connect(ramp111.y, sourceMassFlow111.in_w0) annotation(
    Line(points = {{35, -32}, {41, -32}, {41, -20}, {51, -20}, {51, -26}}, color = {0, 0, 127}));
  connect(sourceMassFlow.flange, steamTurbineStodolaEta.inlet) annotation(
    Line(points = {{-84, 52}, {-70, 52}}, color = {0, 0, 255}));
  connect(steamTurbineStodolaEta.outlet, sinkPressure.flange) annotation(
    Line(points = {{-54, 52}, {-32, 52}}, color = {0, 0, 255}));
  connect(steamTurbineStodolaEta.shaft_b, generator.shaft) annotation(
    Line(points = {{-56, 44}, {-48, 44}, {-48, 30}, {-32, 30}}));
  connect(sourceMassFlow11.flange, steamTurbineStodolaEta1.inlet) annotation(
    Line(points = {{60, 50}, {78, 50}}, color = {0, 0, 255}));
  connect(steamTurbineStodolaEta1.outlet, sinkPressure11.flange) annotation(
    Line(points = {{94, 50}, {112, 50}}, color = {0, 0, 255}));
  connect(steamTurbineStodolaEta1.shaft_b, generator11.shaft) annotation(
    Line(points = {{92, 42}, {98, 42}, {98, 28}, {112, 28}}));
  connect(sourceMassFlow1.flange, steamTurbineStodolaEta2.inlet) annotation(
    Line(points = {{-84, -28}, {-68, -28}}, color = {0, 0, 255}));
  connect(steamTurbineStodolaEta2.outlet, sinkPressure1.flange) annotation(
    Line(points = {{-52, -28}, {-32, -28}}, color = {0, 0, 255}));
  connect(steamTurbineStodolaEta2.shaft_b, generator1.shaft) annotation(
    Line(points = {{-54, -36}, {-46, -36}, {-46, -50}, {-32, -50}}));
  connect(sourceMassFlow111.flange, steamTurbineStodolaEta21.inlet) annotation(
    Line(points = {{66, -32}, {84, -32}}, color = {0, 0, 255}));
  connect(steamTurbineStodolaEta21.outlet, sinkPressure111.flange) annotation(
    Line(points = {{100, -32}, {118, -32}}, color = {0, 0, 255}));
  connect(steamTurbineStodolaEta21.shaft_b, generator111.shaft) annotation(
    Line(points = {{98, -40}, {108, -40}, {108, -54}, {118, -54}}));
  annotation(
    experiment(StartTime = 0, StopTime = 20, Tolerance = 1e-06, Interval = 0.2),
    Diagram(graphics = {Text(origin = {-72, 71}, extent = {{-18, 11}, {18, -11}}, textString = "No correction"), Text(origin = {-78, -4}, extent = {{-28, 14}, {28, -14}}, textString = "Wetness correction"), Text(origin = {83, 71}, extent = {{-23, 15}, {23, -15}}, textString = "mflow correction"), Text(origin = {85, -8}, extent = {{-23, 14}, {23, -14}}, textString = "Both correction")}, coordinateSystem(extent = {{-180, 100}, {140, -60}})));
end SteamTurbineStodolaEta_test;