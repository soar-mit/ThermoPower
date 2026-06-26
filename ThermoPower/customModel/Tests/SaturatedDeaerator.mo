within ThermoPower.customModel.Tests;

model SaturatedDeaerator 
  "Mixer with saturated liquid outlet enforcement (deaerator/OFWH model).
   Identical to ThermoPower.Water.Mixer except outlet enthalpy is forced 
   to saturated liquid at deaerator pressure."
  
  replaceable package Medium = ThermoPower.Water.StandardWater constrainedby
    Modelica.Media.Interfaces.PartialTwoPhaseMedium "Medium model"
    annotation(choicesAllMatching = true);
  
  Medium.ThermodynamicState fluidState "Thermodynamic state of the fluid";
  
  parameter Modelica.SIunits.Volume V "Internal volume";
  parameter Modelica.SIunits.Area S = 0 "Internal surface";
  parameter Modelica.SIunits.CoefficientOfHeatTransfer gamma = 0
    "Internal Heat Transfer Coefficient" annotation (Evaluate = true);
  parameter Modelica.SIunits.HeatCapacity Cm = 0 "Metal Heat Capacity" 
    annotation (Evaluate = true);
  parameter Boolean allowFlowReversal = system.allowFlowReversal
    "= true to allow flow reversal, false restricts to design direction"
    annotation(Evaluate = true);
  outer ThermoPower.System system "System wide properties";
  
  parameter ThermoPower.Choices.FluidPhase.FluidPhases FluidPhaseStart = 
    ThermoPower.Choices.FluidPhase.FluidPhases.Liquid
    "Fluid phase (only for initialization!)"
    annotation (Dialog(tab = "Initialisation"));
  parameter Medium.AbsolutePressure pstart "Pressure start value"
    annotation (Dialog(tab = "Initialisation"));
  parameter Medium.SpecificEnthalpy hstart = 
    if FluidPhaseStart == ThermoPower.Choices.FluidPhase.FluidPhases.Liquid then 1e5
    elseif FluidPhaseStart == ThermoPower.Choices.FluidPhase.FluidPhases.Steam then 3e6 
    else 1e6 "Specific enthalpy start value"
    annotation (Dialog(tab = "Initialisation"));
  parameter Medium.Temperature Tmstart = 300 
    "Metal wall temperature start value"
    annotation (Dialog(tab = "Initialisation"));
  parameter ThermoPower.Choices.Init.Options initOpt = system.initOpt
    "Initialisation option"
    annotation (Dialog(tab = "Initialisation"));
  parameter Boolean noInitialPressure = false
    "Remove initial equation on pressure"
    annotation (Dialog(tab = "Initialisation"), choices(checkBox = true));
  parameter Boolean noInitialEnthalpy = false
    "Remove initial equation on enthalpy"
    annotation (Dialog(tab = "Initialisation"), choices(checkBox = true));
  
  ThermoPower.Water.FlangeA in1(
    h_outflow(start = hstart),
    redeclare package Medium = Medium,
    m_flow(min = if allowFlowReversal then -Modelica.Constants.inf else 0))
    "Condensate inlet"
    annotation (Placement(transformation(extent = {{-100, 40}, {-60, 80}}, 
      rotation = 0)));
  ThermoPower.Water.FlangeA in2(
    h_outflow(start = hstart),
    redeclare package Medium = Medium,
    m_flow(min = if allowFlowReversal then -Modelica.Constants.inf else 0))
    "Extraction steam inlet"
    annotation (Placement(transformation(extent = {{-100, -80}, {-60, -40}}, 
      rotation = 0)));
  ThermoPower.Water.FlangeB out(
    h_outflow(start = hstart),
    redeclare package Medium = Medium,
    m_flow(max = if allowFlowReversal then +Modelica.Constants.inf else 0))
    "Outlet (saturated liquid)"
    annotation (Placement(transformation(extent = {{80, -20}, {120, 20}}, 
      rotation = 0)));
  
  // States (same as Mixer)
  Medium.AbsolutePressure p(start = pstart, 
    stateSelect = if Medium.singleState then StateSelect.avoid else StateSelect.prefer) 
    "Fluid pressure";
  Medium.SpecificEnthalpy h(start = hstart, stateSelect = StateSelect.prefer)
    "Fluid specific enthalpy (lumped, may be subcooled if steam deficit)";
  
  Medium.SpecificEnthalpy hi1 "Inlet 1 specific enthalpy";
  Medium.SpecificEnthalpy hi2 "Inlet 2 specific enthalpy";
  Medium.SpecificEnthalpy ho "Outlet specific enthalpy";
  
  Modelica.SIunits.Mass M "Fluid mass";
  Modelica.SIunits.Energy E "Fluid energy";
  Modelica.SIunits.HeatFlowRate Q "Heat flow rate exchanged with the outside";
  Medium.Temperature T "Fluid temperature";
  Medium.Temperature Tm(start = Tmstart) "Wall temperature";
  Modelica.SIunits.Time Tr "Residence time";
  
  replaceable ThermoPower.Thermal.HT thermalPort "Internal surface of metal wall"
    annotation (Placement(transformation(extent = {{-24, 66}, {24, 80}}, rotation = 0)));
  
  // Saturation properties at current pressure (NEW)
  Medium.SaturationProperties sat "Saturation properties at p";
  Medium.SpecificEnthalpy h_l_sat "Saturated liquid enthalpy at p";
  Medium.Temperature T_sat "Saturation temperature at p";
  
  // Diagnostics
  Real subcooling_margin 
    "h - h_l_sat: positive = sat or superheated, negative = subcooled internal state";
  Boolean steam_sufficient 
    "True if internal state is at or above saturation";
  
equation
  // === Fluid properties (identical to Mixer) ===
  fluidState = Medium.setState_phX(p, h);
  T = Medium.temperature(fluidState);
  
  M = V * Medium.density(fluidState) "Fluid mass";
  E = M * Medium.specificInternalEnergy(fluidState) "Fluid energy";
  der(M) = in1.m_flow + in2.m_flow + out.m_flow "Fluid mass balance";
  der(E) = in1.m_flow * hi1 + in2.m_flow * hi2 + out.m_flow * ho 
           - gamma * S * (T - Tm) + Q "Fluid energy balance";
  
  if Cm > 0 and gamma > 0 then
    Cm * der(Tm) = gamma * S * (T - Tm) "Metal wall energy balance";
  else
    Tm = T;
  end if;
  
  // === Saturation calculation (NEW) ===
  sat = Medium.setSat_p(p);
  h_l_sat = Medium.bubbleEnthalpy(sat);
  T_sat = Medium.saturationTemperature(p);
  
  // === Inlet enthalpies (identical to Mixer) ===
  hi1 = homotopy(if not allowFlowReversal then inStream(in1.h_outflow) else
    actualStream(in1.h_outflow), inStream(in1.h_outflow));
  hi2 = homotopy(if not allowFlowReversal then inStream(in2.h_outflow) else
    actualStream(in2.h_outflow), inStream(in2.h_outflow));
  
  // === OUTLET ENTHALPY: saturated liquid (KEY CHANGE) ===
  // Mixer used:  ho = homotopy(if not allowFlowReversal then h else ..., h);
  //              out.h_outflow = h;
  // We override: out.h_outflow = h_l_sat (saturated liquid forced)
  ho = homotopy(if not allowFlowReversal then h_l_sat else 
    actualStream(out.h_outflow), h_l_sat);
  
  // Reverse-flow enthalpies (same as Mixer, use internal h)
  in1.h_outflow = h;
  in2.h_outflow = h;
  out.h_outflow = h_l_sat;   // <-- forced to saturated liquid
  
  // Pressure equality (identical to Mixer)
  in1.p = p;
  in2.p = p;
  out.p = p;
  
  thermalPort.Q_flow = Q;
  thermalPort.T = T;
  
  Tr = noEvent(M / max(abs(out.m_flow), Modelica.Constants.eps)) "Residence time";
  
  // === Diagnostics ===
  subcooling_margin = h - h_l_sat;
  steam_sufficient = subcooling_margin >= 0;
  
initial equation
  // Same as Mixer
  if initOpt == ThermoPower.Choices.Init.Options.noInit then
    // do nothing
  elseif initOpt == ThermoPower.Choices.Init.Options.fixedState then
    if not noInitialPressure then
      p = pstart;
    end if;
    if not noInitialEnthalpy then
      h = hstart;
    end if;
    if (Cm > 0 and gamma > 0) then
      Tm = Tmstart;
    end if;
  elseif initOpt == ThermoPower.Choices.Init.Options.steadyState then
    if not noInitialEnthalpy then
      der(h) = 0;
    end if;
    if (not Medium.singleState and not noInitialPressure) then
      der(p) = 0;
    end if;
    if (Cm > 0 and gamma > 0) then
      der(Tm) = 0;
    end if;
  elseif initOpt == ThermoPower.Choices.Init.Options.steadyStateNoP then
    if not noInitialEnthalpy then
      der(h) = 0;
    end if;
    if (Cm > 0 and gamma > 0) then
      der(Tm) = 0;
    end if;
  else
    assert(false, "Unsupported initialisation option");
  end if;
  
  annotation (
    Documentation(info = "<html>
<p><b>Saturated Deaerator</b> - Mixer variant with saturated liquid outlet.</p>

<p>Based on ThermoPower.Water.Mixer with identical mass/energy balance. The 
only difference: <tt>out.h_outflow = h_l_sat = bubbleEnthalpy(p)</tt> 
instead of <tt>out.h_outflow = h</tt>.</p>

<p>This mimics the direct-contact heat exchange in a real deaerator where 
the outlet is always saturated liquid at the deaerator pressure.</p>

<h4>Diagnostics</h4>
<ul>
<li><tt>subcooling_margin = h - h_l_sat</tt>: positive when internal state 
is at saturation (steam supply sufficient), negative when subcooled 
(steam deficit, real deaerator would lose pressure)</li>
<li><tt>steam_sufficient</tt>: boolean version of above</li>
</ul>

<h4>Energy accounting</h4>
<p>If internal h is below saturation (subcooling_margin &lt; 0), the 
out.h_outflow = h_l_sat is higher than the actual fluid state. This 
represents 'cheating' on energy balance, equivalent to assuming external 
heat input maintains saturation. Monitor subcooling_margin during simulation 
to verify physical validity.</p>
</html>"),
    Icon(graphics));
end SaturatedDeaerator;
