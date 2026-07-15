within ThermoPower.customModel.Tests;

model IdealDeaerator
  "Prescribed-pressure deaerator with mass storage and ideal heat source"

  replaceable package Medium = Water.StandardWater constrainedby
    Modelica.Media.Interfaces.PartialMedium;

  parameter Modelica.SIunits.Pressure p = 1.45e6
    "Prescribed deaerator pressure";

  parameter Modelica.SIunits.Volume Vtot = 25
    "Nominal deaerator/storage volume";

  parameter Modelica.SIunits.Mass Mstart = 0.8*Vtot*850
    "Initial liquid inventory";

  parameter Modelica.SIunits.Mass Mmin = 1e-3
    "Minimum inventory for diagnostics";

  // Saturation properties
  Medium.SaturationProperties sat;
  Medium.SpecificEnthalpy hl "Saturated liquid enthalpy";
  Medium.SpecificEnthalpy hv "Saturated vapour enthalpy";
  Modelica.SIunits.Density rhol "Saturated liquid density";
  Modelica.SIunits.Temperature Tsat;

  // Storage state
  Modelica.SIunits.Mass M(start=Mstart, fixed=true)
    "Stored liquid mass";

  Modelica.SIunits.Volume Vl
    "Equivalent liquid volume";

  Real level
    "Pseudo liquid level fraction";

  // Actual inlet enthalpies
  Medium.SpecificEnthalpy h_cond_in;
  Medium.SpecificEnthalpy h_steam_in;

  // Ideal heat source
  Modelica.SIunits.Power Qideal
    "Ideal heat added to maintain saturated-liquid outlet enthalpy";

  Modelica.SIunits.Power Qflow
    "Net enthalpy flow imbalance before ideal heat correction";

  Modelica.SIunits.MassFlowRate m_residual
    "Mass imbalance, positive means inventory increases";

  // Connectors
  Water.FlangeA condensateIn(redeclare package Medium = Medium)
    annotation(Placement(transformation(origin={0,-120}, extent={{-120,40},{-80,80}})));

  Water.FlangeA steamIn(redeclare package Medium = Medium)
    annotation(Placement(transformation(origin={0,120}, extent={{-120,-80},{-80,-40}})));

  Water.FlangeB waterOut(redeclare package Medium = Medium)
    annotation(Placement(transformation(extent={{80,-20},{120,20}})));

equation
  // Prescribed pressure
  condensateIn.p = p;
  steamIn.p = p;
  waterOut.p = p;

  // Saturated liquid condition at deaerator pressure
  sat.psat = p;
  sat.Tsat = Medium.saturationTemperature(p);
  Tsat = sat.Tsat;

  hl = Medium.bubbleEnthalpy(sat);
  hv = Medium.dewEnthalpy(sat);
  rhol = Medium.bubbleDensity(sat);

  // All outflow from the deaerator is saturated liquid
  condensateIn.h_outflow = hl;
  steamIn.h_outflow = hl;
  waterOut.h_outflow = hl;

  // Actual incoming enthalpies
  h_cond_in = inStream(condensateIn.h_outflow);
  h_steam_in = inStream(steamIn.h_outflow);

  // Mass balance with storage
  m_residual = condensateIn.m_flow + steamIn.m_flow + waterOut.m_flow;
  der(M) = m_residual;

  // Pseudo level diagnostic
  Vl = M/rhol;
  level = Vl/Vtot;

  // Ideal energy correction
  //
  // If the outgoing saturated-liquid enthalpy requires more energy than
  // provided by incoming streams, Qideal becomes positive.
  //
  // Sign convention:
  //   m_flow > 0 into component
  //   waterOut.m_flow < 0 during normal outflow
  Qflow =
      condensateIn.m_flow*h_cond_in
    + steamIn.m_flow*h_steam_in
    + waterOut.m_flow*hl;

  // Enforce no net energy accumulation beyond saturated-liquid storage assumption.
  // The missing/excess energy is supplied/removed by Qideal.
  Qideal = -Qflow;

  annotation(
    Icon(graphics={
      Rectangle(
        extent={{-90,80},{90,-80}},
        lineColor={0,0,255},
        fillColor={220,235,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{-90,-20},{90,-80}},
        lineColor={0,0,255},
        fillColor={100,150,255},
        fillPattern=FillPattern.Solid),
      Text(
        extent={{-100,-100},{100,-130}},
        textString="%name",
        textColor={85,170,255})}),
    Documentation(info="<html>
<p>
Ideal prescribed-pressure deaerator with liquid mass storage.
The outlet enthalpy is forced to saturated liquid at the prescribed pressure.
Mass imbalance changes the stored liquid inventory, while the energy imbalance
is compensated by an ideal heat source/sink Qideal.
</p>
</html>"));
end IdealDeaerator;