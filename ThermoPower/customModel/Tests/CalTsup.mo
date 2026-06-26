within ThermoPower.customModel.Tests;

model CalTsup "Calculates superheat (T - T_sat) from measured pressure and temperature.
   T_sat is computed from saturation curve of the working fluid."
  extends ThermoPower.Icons.Water.SensP;
  replaceable package Medium = ThermoPower.Water.StandardWater constrainedby
    Modelica.Media.Interfaces.PartialMedium "Medium model"
    annotation(choicesAllMatching = true);
  Modelica.Blocks.Interfaces.RealOutput Tsup(unit = "C") annotation (Placement(
        transformation(extent={{60,40},{100,80}}, rotation=0)));
  ThermoPower.Water.FlangeA flange(redeclare package Medium = Medium, m_flow(min=0))
    annotation (Placement(transformation(extent={{-20,-60},{20,-20}},
          rotation=0)));
equation
  flange.m_flow = 0;
  flange.h_outflow = 0;
  Tsup = Medium.temperature(Medium.setState_phX(flange.p, inStream(flange.h_outflow)))-Medium.saturationTemperature(flange.p);
  annotation (
    Diagram(graphics),
    Icon(graphics={Text(
          extent={{-40,84},{38,34}}, textString = "Tsup")}));
end CalTsup;
