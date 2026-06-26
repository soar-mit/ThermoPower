within ThermoPower.customModel.Tests;

model LumpedVolume
  "General 0D mass/energy balance volume.
   Supports single-phase and two-phase, vector in/out flanges, fixed Q."
  replaceable package Medium = Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialMedium "Medium model";
  // ============================================================
  //  Parameters
  // ============================================================
  parameter Integer Nin = 1 "Number of inlet flanges";
  parameter Integer Nout = 1 "Number of outlet flanges";
  parameter SI.Volume V "Total volume";
  parameter SI.Power Q = 0 "External heat input (positive = heat added to fluid)";
  parameter Boolean allowFlowReversal = system.allowFlowReversal "= true to allow flow reversal";
  // -- Initialization --
  parameter SI.Pressure pstart = 1e5 "Start value of pressure" annotation(
    Dialog(tab = "Initialisation"));
  parameter SI.SpecificEnthalpy hstart = 1e5 "Start value of specific enthalpy" annotation(
    Dialog(tab = "Initialisation"));
  parameter Choices.Init.Options initOpt = system.initOpt "Initialisation option" annotation(
    Dialog(tab = "Initialisation"));
  outer System system "System wide properties";
  // ============================================================
  //  Variables
  // ============================================================
  Medium.ThermodynamicState state "Bulk thermodynamic state";
  Medium.AbsolutePressure p(start = pstart) "Internal pressure";
  Medium.SpecificEnthalpy h(start = hstart) "Bulk specific enthalpy";
  Medium.Temperature T "Bulk temperature";
  Medium.Density rho "Bulk density";
  SI.Mass M "Total mass";
  SI.Energy E "Total internal energy (U = H - p*V)";
  // ============================================================
  //  Connectors (vector flanges)
  // ============================================================
  Water.FlangeA inlet[Nin](redeclare each package Medium = Medium, each m_flow(min = if allowFlowReversal then -Modelica.Constants.inf else 0)) annotation(
    Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
  Water.FlangeB outlet[Nout](redeclare each package Medium = Medium, each m_flow(max = if allowFlowReversal then Modelica.Constants.inf else 0)) annotation(
    Placement(transformation(extent = {{90, -10}, {110, 10}})));
equation
// -- Bulk thermodynamic state from (p, h) --
  state = Medium.setState_phX(p, h);
  T = Medium.temperature(state);
  rho = Medium.density(state);
// -- Mass and internal energy --
  M = rho*V;
  E = M*h - p*V;
// Internal energy U = H - pV
// -- Mass balance --
  der(M) = sum(inlet.m_flow) + sum(outlet.m_flow);
// -- Energy balance --
// m_flow > 0 means into the volume.  h_in for inlet uses inStream,
// h_out for outlet is the bulk h (well-mixed assumption).
  der(E) = sum(inlet[i].m_flow*inStream(inlet[i].h_outflow) for i in 1:Nin) + sum(outlet[i].m_flow*inStream(outlet[i].h_outflow) for i in 1:Nout) + Q;
// -- Flange pressures: all equal to internal pressure (no dp) --
  for i in 1:Nin loop
    inlet[i].p = p;
  end for;
  for i in 1:Nout loop
    outlet[i].p = p;
  end for;
// -- Outflow enthalpy: well-mixed, equals bulk h --
// (Backflow: returns bulk h on inlets too)
  for i in 1:Nin loop
    inlet[i].h_outflow = h;
  end for;
  for i in 1:Nout loop
    outlet[i].h_outflow = h;
  end for;
initial equation
  if initOpt == Choices.Init.Options.noInit then
// do nothing
  elseif initOpt == Choices.Init.Options.fixedState then
    p = pstart;
    h = hstart;
  elseif initOpt == Choices.Init.Options.steadyState then
    der(M) = 0;
    der(E) = 0;
  else
    assert(false, "Unsupported initialisation option");
  end if;
  annotation(
    Icon(graphics = {Ellipse(extent = {{-80, 80}, {80, -80}}, lineColor = {0, 0, 255}, fillColor = {170, 213, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-60, 20}, {60, -20}}, textString = "0D"), Text(extent = {{-100, -90}, {100, -120}}, textColor = {0, 0, 255}, textString = "%name")}),
    Documentation(info = "<html>
<p>General 0D lumped volume with dynamic mass and energy balance.</p>

<p><b>State variables:</b> internal pressure <tt>p</tt> and specific enthalpy 
<tt>h</tt> (equivalently, total mass M and internal energy E).</p>

<p><b>Assumptions:</b></p>
<ul>
<li>Well-mixed: bulk state (p, h) characterizes entire volume.</li>
<li>No pressure drop: all flanges at internal pressure p.</li>
<li>External heat input Q is a parameter (positive = heat added).</li>
<li>Single-phase or two-phase: handled automatically by Medium.</li>
</ul>

<p><b>Usage examples:</b></p>
<ul>
<li>Condenser: connect outlet to SinkPressure (or pump suction); set Q
    to extract heat (negative when convention sets Q = removed; in this 
    model Q > 0 adds heat, so condenser uses Q &lt; 0 or external Q via 
    coolant model).</li>
<li>Deaerator: multiple inlets (LP extraction, drain, FW return).</li>
<li>FW heater: heat from extraction steam side via Q (parameter) or
    via an external steam-side volume connected through heat balance.</li>
</ul>
</html>"));
end LumpedVolume;
