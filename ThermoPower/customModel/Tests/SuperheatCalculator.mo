within ThermoPower.customModel.Tests;

block SuperheatCalculator "Calculates superheat (T - T_sat) from measured pressure and temperature.
   T_sat is computed from saturation curve of the working fluid."
  replaceable package Medium = ThermoPower.Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialMedium "Working fluid" annotation(
     choicesAllMatching = true);
  Modelica.Blocks.Interfaces.RealInput p(unit = "Pa") "Measured pressure [Pa]" annotation(
    Placement(transformation(extent = {{-120, 30}, {-80, 70}}), iconTransformation(origin = {30, -14}, extent = {{-120, 30}, {-80, 70}})));
  Modelica.Blocks.Interfaces.RealInput T(unit = "C") "Measured temperature [K]" annotation(
    Placement(transformation(extent = {{-120, -70}, {-80, -30}}), iconTransformation(origin = {30, 20}, extent = {{-120, -70}, {-80, -30}})));
  Modelica.Blocks.Interfaces.RealOutput Tsup(unit = "C") "Tsup = T-Tsat [K]" annotation(
    Placement(transformation(origin = {10, 0}, extent = {{90, -10}, {110, 10}}), iconTransformation(origin = {-40, 0}, extent = {{90, -10}, {110, 10}})));
  Modelica.SIunits.Temperature Tsat "Saturation temperature at measured pressure [K]";
equation
  Tsat = Medium.saturationTemperature(p);
  Tsup = T - Tsat;
  annotation(
    Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-50, 50}, {50, -50}}), Text(origin = {-18, 56},textColor = {0, 0, 127}, extent = {{-80, 30}, {-30, 10}}, textString = "p"), Text(origin = {-16, -46},textColor = {0, 0, 127}, extent = {{-80, -10}, {-30, -30}}, textString = "T"), Text(origin = {26, 30},textColor = {0, 0, 127}, extent = {{20, 10}, {80, -10}}, textString = "Tsup"), Text(textColor = {0, 0, 255}, extent = {{-100, -100}, {100, -120}}, textString = "%name")}),
    Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}})));
end SuperheatCalculator;
