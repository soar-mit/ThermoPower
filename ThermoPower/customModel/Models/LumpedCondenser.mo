within ThermoPower.customModel.Models;

model LumpedCondenser
  "Modified ThermoPower.Examples.RankineCycle.Models.PrescribedPressureCondenser"
  replaceable package Medium = Water.StandardWater constrainedby
    Modelica.Media.Interfaces.PartialMedium "Medium model";
  //Parameters
  parameter Modelica.SIunits.Pressure p "Nominal inlet pressure";
  parameter Modelica.SIunits.Volume Vtot=10
    "Total volume of the fluid side";
  parameter Modelica.SIunits.Volume Vlstart=0.15*Vtot
    "Start value of the liquid water volume"
    annotation (Dialog(tab="Initialisation"));
  parameter Choices.Init.Options initOpt=system.initOpt
    "Initialisation option"
    annotation (Dialog(tab="Initialisation"));

  outer System system "System object";

//Variables
  Modelica.SIunits.Density rhol "Density of saturated liquid";
  Modelica.SIunits.Density rhov "Density of saturated steam";
  Medium.SaturationProperties sat "Saturation properties";
  Medium.SpecificEnthalpy hl "Specific enthalpy of saturated liquid";
  Medium.SpecificEnthalpy hv "Specific enthalpy of saturated vapour";
  Medium.SpecificEnthalpy h_in_actual "Actual inlet enthalpy";
  Modelica.SIunits.Mass M "Total mass, steam+liquid";
  Modelica.SIunits.Mass Ml "Liquid mass";
  Modelica.SIunits.Mass Mv "Steam mass";
  Modelica.SIunits.Volume Vl(start=Vlstart) "Liquid volume";
  Modelica.SIunits.Volume Vv "Steam volume";
  Modelica.SIunits.Energy E "Internal energy";
  Modelica.SIunits.Power Q "Thermal power";

//Connectors
  Water.FlangeA steamIn(redeclare package Medium = Medium) annotation (
      Placement(transformation(extent={{-20,80},{20,120}}, rotation=0)));
  Water.FlangeB waterOut(redeclare package Medium = Medium) annotation (
      Placement(transformation(extent={{-20,-120},{20,-80}}, rotation=0)));

equation
  steamIn.p = p;
  steamIn.h_outflow = hl; // backflow gives saturated liquid
  sat.psat = p;
  sat.Tsat = Medium.saturationTemperature(p);
  hl = Medium.bubbleEnthalpy(sat);
  hv = Medium.dewEnthalpy(sat);
  waterOut.p = p;
  waterOut.h_outflow = hl;  // outlet gives saturated liquid
  rhol = Medium.bubbleDensity(sat);
  rhov = Medium.dewDensity(sat);

  h_in_actual = inStream(steamIn.h_outflow);

  Ml = Vl*rhol;
  Mv = Vv*rhov;
  Vtot = Vv + Vl;
  M = Ml + Mv;
  E = Ml*hl + Mv*hv - p*Vtot;
//Energy and Mass Balances
  der(M) = steamIn.m_flow + waterOut.m_flow;
  der(E) = steamIn.m_flow*h_in_actual + waterOut.m_flow*hl - Q;

initial equation
  if initOpt == Choices.Init.Options.noInit then
// do nothing
  elseif initOpt == Choices.Init.Options.fixedState then
    Vl = Vlstart;
  elseif initOpt == Choices.Init.Options.steadyState then
    der(Vl) = 0;
  else
    assert(false, "Unsupported initialisation option");
  end if;

  annotation (
    Icon(graphics={
        Ellipse(
          extent={{-90,100},{90,-80}},
          lineColor={0,0,255},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{44,-40},{-50,-40},{8,10},{-50,60},{44,60}},
          color={0,0,255},
          thickness=0.5),
        Rectangle(
          extent={{-48,-66},{48,-100}},
          lineColor={0,0,255},
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-100,-115},{100,-145}},
          lineColor={85,170,255},
          textString="%name")}),
    Diagram(graphics),
    Documentation(info="<html>
    <p> Now inlet takes actual enthalpy (h_in_actual) instead of hv. Outlet still remains hl.
    <p> Tested in LumpedCondenser_test.
</html>"));
  
end LumpedCondenser;
