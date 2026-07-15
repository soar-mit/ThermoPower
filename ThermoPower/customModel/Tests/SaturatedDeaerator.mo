within ThermoPower.customModel.Tests;

model SaturatedDeaerator 
  "Deaerator with two inlets (condensate + extraction steam) at prescribed pressure.
   Outlet is always saturated liquid at the deaerator pressure.
   Based on LumpedCondenser pattern - both inlets, one outlet, prescribed p."
  
  replaceable package Medium = ThermoPower.Water.StandardWater constrainedby
    Modelica.Media.Interfaces.PartialTwoPhaseMedium "Medium model";
  
  // ============================================================
  //  Parameters
  // ============================================================
  parameter Modelica.SIunits.Pressure pstart = 1.45e6 
    "Initial deaerator pressure (start value only)"
    annotation(Dialog(tab = "Initialisation"));
  parameter Modelica.SIunits.Volume Vtot = 25 
    "Total volume of the deaerator";
  parameter Modelica.SIunits.Volume Vlstart = 0.7*Vtot 
    "Start value of the liquid volume (storage section)"
    annotation(Dialog(tab = "Initialisation"));
  parameter ThermoPower.Choices.Init.Options initOpt = system.initOpt 
    "Initialisation option"
    annotation(Dialog(tab = "Initialisation"));
  
  outer ThermoPower.System system "System object";
  
  // ============================================================
  //  Variables
  // ============================================================
  Modelica.SIunits.Pressure p(start = pstart) 
    "Deaerator pressure (= steam inlet pressure)";
  Modelica.SIunits.Density rhol "Density of saturated liquid";
  Modelica.SIunits.Density rhov "Density of saturated steam";
  Medium.SaturationProperties sat "Saturation properties";
  Medium.SpecificEnthalpy hl "Saturated liquid enthalpy";
  Medium.SpecificEnthalpy hv "Saturated vapor enthalpy";
  Medium.Temperature Tsat "Saturation temperature";
  
  Medium.SpecificEnthalpy h_cond_actual "Actual condensate inlet enthalpy";
  Medium.SpecificEnthalpy h_steam_actual "Actual extraction steam inlet enthalpy";
  
  Modelica.SIunits.Mass M "Total mass (liquid + vapor)";
  Modelica.SIunits.Mass Ml "Liquid mass";
  Modelica.SIunits.Mass Mv "Vapor mass";
  Modelica.SIunits.Volume Vl(start = Vlstart) "Liquid volume";
  Modelica.SIunits.Volume Vv "Vapor volume";
  Modelica.SIunits.Energy E "Internal energy";
  
  // Diagnostic: how well is deaerator functioning?
  Modelica.SIunits.Power Q_condense 
    "Heat released by steam condensation";
  Modelica.SIunits.Power Q_heat_condensate 
    "Heat needed to heat condensate to saturation";
  Real balance 
    "Q_condense - Q_heat_condensate (positive = steam supply sufficient)";
  Boolean steam_sufficient 
    "True when steam supply exceeds condensate heating demand";
  
  // ============================================================
  //  Connectors
  // ============================================================
  ThermoPower.Water.FlangeA condensateIn(redeclare package Medium = Medium) 
    "Condensate inlet (from CdPump)"
    annotation(Placement(transformation(extent = {{-120, 40}, {-80, 80}})));
  ThermoPower.Water.FlangeA steamIn(redeclare package Medium = Medium) 
    "Extraction steam inlet (from turbine bleed)"
    annotation(Placement(transformation(extent = {{-120, -80}, {-80, -40}})));
  ThermoPower.Water.FlangeB waterOut(redeclare package Medium = Medium) 
    "Feedwater outlet (saturated liquid)"
    annotation(Placement(transformation(extent = {{80, -20}, {120, 20}})));

equation
  // ============================================================
  //  Pressure: dictated by steam inlet
  //  All ports share the same pressure (deaerator is one control volume)
  // ============================================================
  p = steamIn.p;                   // p follows extraction steam pressure
  condensateIn.p = p;              // all ports at same p
  waterOut.p = p;
  
  // ============================================================
  //  Saturation properties at current p
  // ============================================================
  sat = Medium.setSat_p(p);
  Tsat = Medium.saturationTemperature(p);
  hl = Medium.bubbleEnthalpy(sat);
  hv = Medium.dewEnthalpy(sat);
  rhol = Medium.bubbleDensity(sat);
  rhov = Medium.dewDensity(sat);
  
  // ============================================================
  //  Outlet and reverse-flow enthalpies (all saturated liquid)
  // ============================================================
  waterOut.h_outflow = hl;         // outlet: saturated liquid (physics)
  condensateIn.h_outflow = hl;     // backflow: saturated liquid
  steamIn.h_outflow = hl;          // backflow: saturated liquid
  
  // ============================================================
  //  Actual inlet enthalpies (upstream-determined)
  // ============================================================
  h_cond_actual = inStream(condensateIn.h_outflow);
  h_steam_actual = inStream(steamIn.h_outflow);
  
  // ============================================================
  //  Volume, mass, energy
  // ============================================================
  Ml = Vl * rhol;
  Mv = Vv * rhov;
  Vtot = Vv + Vl;
  M = Ml + Mv;
  // Internal energy: assume liquid at hl, vapor at hv (saturated)
  // -p*Vtot converts h to u (internal energy)
  E = Ml*hl + Mv*hv - p*Vtot;
  
  // ============================================================
  //  Mass and Energy Balances
  // ============================================================
  der(M) = condensateIn.m_flow + steamIn.m_flow + waterOut.m_flow;
  der(E) = condensateIn.m_flow * h_cond_actual 
         + steamIn.m_flow * h_steam_actual 
         + waterOut.m_flow * hl;
  
  // ============================================================
  //  Diagnostics
  // ============================================================
  Q_condense = steamIn.m_flow * (h_steam_actual - hl);
  Q_heat_condensate = condensateIn.m_flow * (hl - h_cond_actual);
  balance = Q_condense - Q_heat_condensate;
  steam_sufficient = balance > 0;

initial equation
  if initOpt == ThermoPower.Choices.Init.Options.noInit then
    // do nothing
  elseif initOpt == ThermoPower.Choices.Init.Options.fixedState then
    Vl = Vlstart;
  elseif initOpt == ThermoPower.Choices.Init.Options.steadyState then
    der(Vl) = 0;
  else
    assert(false, "Unsupported initialisation option");
  end if;

  annotation(
    Icon(graphics = {
      Rectangle(extent = {{-90, 80}, {90, -80}}, lineColor = {0, 0, 255},
                lineThickness = 0.5, fillColor = {220, 235, 255}, 
                fillPattern = FillPattern.Solid),
      Rectangle(extent = {{-90, -20}, {90, -80}}, lineColor = {0, 0, 255},
                fillColor = {100, 150, 255}, fillPattern = FillPattern.Solid),
      Line(points = {{-70, 60}, {-70, 40}}, color = {0, 0, 200}, thickness = 0.5),
      Line(points = {{-40, 60}, {-40, 40}}, color = {0, 0, 200}, thickness = 0.5),
      Line(points = {{-10, 60}, {-10, 40}}, color = {0, 0, 200}, thickness = 0.5),
      Line(points = {{20, 60}, {20, 40}}, color = {0, 0, 200}, thickness = 0.5),
      Line(points = {{50, 60}, {50, 40}}, color = {0, 0, 200}, thickness = 0.5),
      Text(extent = {{-110, 70}, {-70, 50}}, textString = "cond",
           textColor = {0, 0, 0}),
      Text(extent = {{-110, -50}, {-70, -70}}, textString = "steam",
           textColor = {0, 0, 0}),
      Text(extent = {{60, 10}, {100, -10}}, textString = "sat.liq",
           textColor = {0, 0, 0}),
      Text(extent = {{-100, -100}, {100, -130}}, lineColor = {85, 170, 255},
           textString = "%name")
    }),
    Documentation(info = "<html>
<p><b>Saturated Deaerator</b> - based on LumpedCondenser pattern.</p>

<h4>Structure</h4>
<ul>
<li>Two inlets: condensate (from CdPump) + extraction steam (from turbine)</li>
<li>One outlet: saturated liquid feedwater (to FwPump)</li>
<li>Prescribed pressure (like LumpedCondenser)</li>
</ul>

<h4>Physics</h4>
<p>All ports at prescribed p. Deaerator internally maintains 
two-phase equilibrium at saturation. Outlet always saturated liquid 
(direct-contact heat exchange).</p>

<h4>State variable</h4>
<p><tt>Vl</tt>: liquid volume (level indicator). Mass and energy balances 
determine der(Vl) implicitly through M and E.</p>

<h4>Diagnostics</h4>
<ul>
<li><tt>Q_condense</tt>: heat released by steam condensation</li>
<li><tt>Q_heat_condensate</tt>: heat needed to heat condensate to saturation</li>
<li><tt>balance</tt>: positive if steam supply is sufficient</li>
<li><tt>steam_sufficient</tt>: boolean indicator</li>
</ul>

<h4>Assumptions</h4>
<ul>
<li>Pressure prescribed (not dynamic)</li>
<li>Instantaneous phase equilibrium (no thermal inertia between phases)</li>
<li>Outlet always saturated liquid (no metastable subcooling)</li>
<li>No heat loss to environment</li>
</ul>
</html>"));
end SaturatedDeaerator;