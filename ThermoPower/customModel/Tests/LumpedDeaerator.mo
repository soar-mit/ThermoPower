within ThermoPower.customModel.Tests;

model LumpedDeaerator
  "Prescribed-pressure equilibrium deaerator with separated liquid and vapour inventories"

  replaceable package Medium = Water.StandardWater constrainedby
    Modelica.Media.Interfaces.PartialMedium
    "Medium model"
    annotation(choicesAllMatching = true);

  outer ThermoPower.System system "System-wide properties";

  // ------------------------------------------------------------------
  // Parameters
  // ------------------------------------------------------------------
  parameter Modelica.SIunits.Pressure p = 1.45e6
    "Prescribed deaerator pressure";

  parameter Modelica.SIunits.Volume Vtot = 25
    "Total internal fluid volume";

  parameter Modelica.SIunits.Volume Vlstart = 0.8*Vtot
    "Initial liquid volume"
    annotation(Dialog(tab = "Initialisation"));

  parameter Choices.Init.Options initOpt = system.initOpt
    "Initialisation option"
    annotation(Dialog(tab = "Initialisation"));

  parameter Boolean allowFlowReversal = system.allowFlowReversal
    "= true to allow flow reversal"
    annotation(Evaluate = true);

  // ------------------------------------------------------------------
  // Saturation properties
  // ------------------------------------------------------------------
  Medium.SaturationProperties sat
    "Saturation properties at prescribed pressure";

  Modelica.SIunits.Temperature Tsat
    "Saturation temperature";

  Medium.SpecificEnthalpy hl
    "Saturated-liquid specific enthalpy";

  Medium.SpecificEnthalpy hv
    "Saturated-vapour specific enthalpy";

  Modelica.SIunits.Density rhol
    "Saturated-liquid density";

  Modelica.SIunits.Density rhov
    "Saturated-vapour density";

  // ------------------------------------------------------------------
  // Inventories
  // ------------------------------------------------------------------
  Modelica.SIunits.Volume Vl(start = Vlstart, stateSelect = StateSelect.prefer)
    "Liquid volume";

  Modelica.SIunits.Volume Vv
    "Vapour volume";

  Modelica.SIunits.Mass Ml
    "Liquid mass";

  Modelica.SIunits.Mass Mv
    "Vapour mass";

  Modelica.SIunits.Mass M
    "Total fluid mass";

  Modelica.SIunits.Energy E
    "Total internal energy";

  // ------------------------------------------------------------------
  // Flow enthalpies
  // ------------------------------------------------------------------
  Medium.SpecificEnthalpy hCondIn
    "Actual condensate-inlet enthalpy";

  Medium.SpecificEnthalpy hSteamIn
    "Actual extraction-steam inlet enthalpy";

  Medium.SpecificEnthalpy hOut
    "Actual outlet enthalpy used in energy balance";

  // ------------------------------------------------------------------
  // Energy residual
  // ------------------------------------------------------------------
  Modelica.SIunits.HeatFlowRate Q
    "Ideal heat removal required to maintain prescribed pressure;
     positive when heat is removed";

  // ------------------------------------------------------------------
  // Diagnostic variables
  // ------------------------------------------------------------------
  Modelica.SIunits.MassFlowRate dMdt
    "Net rate of mass accumulation";

  Modelica.SIunits.EnergyFlowRate dEdt
    "Rate of internal-energy accumulation";

  Real liquidVolumeFraction(unit = "1")
    "Liquid volume fraction";

  Real vapourMassFraction(unit = "1")
    "Vapour mass fraction";

  Modelica.SIunits.Time residenceTime
    "Approximate liquid residence time";

  // ------------------------------------------------------------------
  // Connectors
  // ------------------------------------------------------------------
  Water.FlangeA condensateIn(
    redeclare package Medium = Medium,
    h_outflow(start = Medium.bubbleEnthalpy(
      Medium.setSat_p(p))),
    m_flow(min = if allowFlowReversal
      then -Modelica.Constants.inf else 0))
    "Condensate-water inlet"
    annotation(Placement(transformation(
      extent = {{-110, 35}, {-90, 55}})));

  Water.FlangeA steamIn(
    redeclare package Medium = Medium,
    h_outflow(start = Medium.dewEnthalpy(
      Medium.setSat_p(p))),
    m_flow(min = if allowFlowReversal
      then -Modelica.Constants.inf else 0))
    "Extraction-steam inlet"
    annotation(Placement(transformation(
      extent = {{-110, -55}, {-90, -35}})));

  Water.FlangeB waterOut(
    redeclare package Medium = Medium,
    h_outflow(start = Medium.bubbleEnthalpy(
      Medium.setSat_p(p))),
    m_flow(max = if allowFlowReversal
      then Modelica.Constants.inf else 0))
    "Saturated-liquid outlet"
    annotation(Placement(transformation(
      extent = {{90, -10}, {110, 10}})));

equation
  // ------------------------------------------------------------------
  // Saturation properties at prescribed pressure
  // ------------------------------------------------------------------
  sat.psat = p;
  sat.Tsat = Medium.saturationTemperature(p);

  Tsat = sat.Tsat;
  hl = Medium.bubbleEnthalpy(sat);
  hv = Medium.dewEnthalpy(sat);
  rhol = Medium.bubbleDensity(sat);
  rhov = Medium.dewDensity(sat);

  // ------------------------------------------------------------------
  // Pressure conditions
  // ------------------------------------------------------------------
  condensateIn.p = p;
  steamIn.p = p;
  waterOut.p = p;

  // ------------------------------------------------------------------
  // Stream conditions
  //
  // If reverse flow occurs:
  // - condensate line receives saturated liquid
  // - extraction-steam line receives saturated vapour
  // - normal outlet supplies saturated liquid
  // ------------------------------------------------------------------
  condensateIn.h_outflow = hl;
  steamIn.h_outflow = hv;
  waterOut.h_outflow = hl;

  hCondIn = homotopy(
    if not allowFlowReversal then
      inStream(condensateIn.h_outflow)
    else
      actualStream(condensateIn.h_outflow),
    inStream(condensateIn.h_outflow));

  hSteamIn = homotopy(
    if not allowFlowReversal then
      inStream(steamIn.h_outflow)
    else
      actualStream(steamIn.h_outflow),
    inStream(steamIn.h_outflow));

  hOut = homotopy(
    if not allowFlowReversal then
      hl
    else
      actualStream(waterOut.h_outflow),
    hl);

  // ------------------------------------------------------------------
  // Separated saturated inventories
  // ------------------------------------------------------------------
  Vtot = Vl + Vv;

  Ml = Vl*rhol;
  Mv = Vv*rhov;
  M = Ml + Mv;

  /*
    Total internal energy:

      E = Ml*ul + Mv*uv

    Since u = h - p/rho,

      E = Ml*hl + Mv*hv - p*(Vl + Vv)
        = Ml*hl + Mv*hv - p*Vtot
  */
  E = Ml*hl + Mv*hv - p*Vtot;

  // ------------------------------------------------------------------
  // Total mass and energy balances
  // ------------------------------------------------------------------
  dMdt =
      condensateIn.m_flow
    + steamIn.m_flow
    + waterOut.m_flow;

  der(M) = dMdt;

  dEdt =
      condensateIn.m_flow*hCondIn
    + steamIn.m_flow*hSteamIn
    + waterOut.m_flow*hOut
    - Q;

  der(E) = dEdt;

  // ------------------------------------------------------------------
  // Diagnostics
  // ------------------------------------------------------------------
  liquidVolumeFraction = Vl/Vtot;

  vapourMassFraction =
    noEvent(Mv/max(M, Modelica.Constants.eps));

  residenceTime =
    noEvent(Ml/max(abs(waterOut.m_flow),
      Modelica.Constants.eps));

  // Prevent nonphysical inventory during simulation
  assert(
    noEvent(Vl >= 0 and Vl <= Vtot),
    "LumpedDeaerator liquid volume is outside [0, Vtot]. "
    + "The inlet/outlet mass-flow imbalance has exhausted one phase.",
    AssertionLevel.error);

initial equation
  if initOpt == Choices.Init.Options.noInit then
    // No initial condition

  elseif initOpt == Choices.Init.Options.fixedState then
    Vl = Vlstart;

  elseif initOpt == Choices.Init.Options.steadyState then
    der(Vl) = 0;

  elseif initOpt == Choices.Init.Options.steadyStateNoP then
    der(Vl) = 0;

  else
    assert(false, "Unsupported initialisation option");
  end if;

  annotation(
    Documentation(info = "<html>
<p>
This model represents an ideal equilibrium deaerator at prescribed pressure.
The internal volume is separated into saturated-liquid and saturated-vapour
regions. The liquid outlet always supplies saturated liquid at the prescribed
pressure.
</p>

<p>
The liquid volume is the only independent inventory state because pressure
and total volume are prescribed. The variable Q is calculated from the energy
balance and represents the ideal heat removal or addition required to maintain
saturated equilibrium at the prescribed pressure.
</p>
</html>"));
end LumpedDeaerator;