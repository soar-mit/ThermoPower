within ThermoPower.customModel.Models;

model Deaerator
replaceable package Medium = Water.StandardWater
  constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium
  "Medium model"
  annotation(choicesAllMatching=true);
  parameter SI.Volume V "Total volume of condensation cavity";
  parameter SI.Pressure pstart "Pressure start value"
    annotation (Dialog(tab="Initialisation"));
  parameter SI.Volume Vlstart = 0.15*V "Start value of the liquid water volume"
    annotation (Dialog(tab="Initialisation"));
  parameter ThermoPower.Choices.Init.Options initOpt=system.initOpt
    "Initialisation option" annotation (Dialog(tab="Initialisation"));
  parameter Boolean allowFlowReversal=system.allowFlowReversal
    "= true to allow flow reversal, false restricts to design direction";
  outer ThermoPower.System system "System wide properties";

  SI.Mass Ml "Liquid water mass";
  SI.Mass Mv "Steam mass";
  SI.Mass M "Total liquid+steam mass";
  SI.Energy E "Total liquid+steam energy";
  SI.Volume Vl(start=Vlstart, stateSelect=StateSelect.prefer)
    "Liquid water total volume";
  SI.Volume Vv "Steam volume";
  Medium.SaturationProperties sat "Saturation properties";
  Medium.AbsolutePressure p(start=pstart,stateSelect=StateSelect.prefer)
    "Drum pressure";
  Medium.SpecificEnthalpy hl "Specific enthalpy of saturated liquid";
  Medium.SpecificEnthalpy hv "Specific enthalpy of saturated steam";
  Medium.Temperature Ts "Saturation temperature";
  Medium.Density rhol "Density of saturated liquid";
  Medium.Density rhov "Density of saturated steam";
  Medium.SpecificEnthalpy hWaterIn "Actual water inlet enthalpy";
  Medium.SpecificEnthalpy hSteamIn "Actual steam inlet enthalpy";
  Medium.SpecificEnthalpy hCondOut "Actual condensate water outlet enthalpy";

  ThermoPower.Water.FlangeA SteamIn(
    redeclare package Medium = Medium,
    m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0))
    annotation (Placement(transformation(extent={{-100,40},{-60,80}},
          rotation=0)));
  ThermoPower.Water.FlangeA WaterIn(
    redeclare package Medium = Medium,
    m_flow(min=if allowFlowReversal then -Modelica.Constants.inf else 0))
    annotation (Placement(transformation(extent={{-100,-80},{-60,-40}},
          rotation=0)));
  ThermoPower.Water.FlangeB CondOut(
    redeclare package Medium = Medium,
    m_flow(max=if allowFlowReversal then +Modelica.Constants.inf else 0))
    annotation (Placement(transformation(extent={{80,-20},{120,20}}, rotation=
           0)));
equation
  Ml = Vl*rhol "Mass of liquid";
  Mv = Vv*rhov "Mass of vapour";
  M = Ml + Mv "Total mass";
  V = Vl + Vv "Total volume";
  E = Ml*hl + Mv*hv - p*V "Total liquid+steam energy";
  
  SteamIn.h_outflow = hv;
  WaterIn.h_outflow = hl;
  CondOut.h_outflow = hl;
  hWaterIn = homotopy(if not allowFlowReversal then inStream(WaterIn.h_outflow) else actualStream(WaterIn.h_outflow), inStream(WaterIn.h_outflow));
  hSteamIn = homotopy(if not allowFlowReversal then inStream(SteamIn.h_outflow) else actualStream(SteamIn.h_outflow), inStream(SteamIn.h_outflow));
  hCondOut = homotopy(if not allowFlowReversal then hl else actualStream(CondOut.h_outflow), hl);
  
  der(M) = SteamIn.m_flow + WaterIn.m_flow + CondOut.m_flow "Mass balance";
  der(E) = SteamIn.m_flow*hSteamIn + WaterIn.m_flow*hWaterIn + CondOut.m_flow*hCondOut "Energy balance (liquid+steam)";

  // Boundary conditions
  p = SteamIn.p;
  p = WaterIn.p;
  p = CondOut.p;

  // Fluid properties
  sat.psat = p;
  sat.Tsat = Medium.saturationTemperature(p);

  Ts = sat.Tsat;
  rhol = Medium.bubbleDensity(sat);
  rhov = Medium.dewDensity(sat);
  hl = Medium.bubbleEnthalpy(sat);
  hv = Medium.dewEnthalpy(sat);
  
initial equation
  if initOpt == ThermoPower.Choices.Init.Options.noInit then
    // do nothing
  elseif initOpt == ThermoPower.Choices.Init.Options.fixedState then
    p = pstart;
    Vl = Vlstart;
  elseif initOpt == ThermoPower.Choices.Init.Options.steadyState then
    der(M) = 0;
    der(E) = 0;
  else
    assert(false, "Unsupported initialisation option");
  end if;
  
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
Simplified Deaerator model. Likewise Condenser model, this model assumes homoginized water/steam mixture volume while outlet saturation is assumed.
</p>
</html>"));
end Deaerator;
