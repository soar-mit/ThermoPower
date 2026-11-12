within ThermoPower.customModel.Models;

model BESS_Simple "Simplified BESS model that simulates only power/energy bulk behaviors"
  import SI = Modelica.SIunits;
  // Battery specifications
  parameter SI.Power Pmax = 10e6 "Maximum charging/discharging power";
  parameter SI.Energy Emax = 5e6*3600 "Nominal energy capacity";
  parameter Real SOC0 = 0.5 "Initial state of charge";
  parameter Real SOCmin = 0.1 "Minimum allowed SOC";
  parameter Real SOCmax = 0.9 "Maximum allowed SOC";
  parameter Real etaCh = 0.95 "Charging efficiency";
  parameter Real etaDis = 0.95 "Discharging efficiency";
  // Controller parameters
  parameter SI.Frequency fnom = 60 "Nominal frequency";
  parameter Real Kf(unit = "W/Hz") = 100e6 "Frequency feedback gain";
  //parameter SI.Time tau = 0.2 "BESS power response time constant";
  // Input connector
  Modelica.Blocks.Interfaces.RealInput f(unit = "Hz") "Grid frequency" annotation(
    Placement(transformation(extent = {{-120, -10}, {-100, 10}}), iconTransformation(extent = {{-120, -10}, {-100, 10}})));
  // Output connectors
  Modelica.Blocks.Interfaces.RealOutput P(unit = "W") "BESS power (+ discharge, - charge)" annotation(
    Placement(transformation(extent = {{100, -10}, {120, 10}}), iconTransformation(extent = {{100, -10}, {120, 10}})));
  Modelica.Blocks.Interfaces.RealOutput SOC "State of charge (0-1)" annotation(
    Placement(transformation(origin = {0, 100}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {0, 100}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  // Internal variables
  SI.Power Pref "Frequency controller power reference";
  SI.Power Pcmd "Power-limited command";
  //SI.Power Pfiltered(start = 0, fixed = true) "First-order power response";
  SI.Power Pfiltered;
  Real SOC_state(start = SOC0, fixed = true) "Internal SOC state";
  
  //Feedforward
    parameter Boolean withFeedForward = false "Use feed-forward input?" annotation(
    Evaluate = true,
    choices(checkBox = true));
    Modelica.Blocks.Interfaces.RealInput P_ff if withFeedForward "Optional connector of feed-forward input signal" annotation(
    Placement(transformation(origin = {60, -120}, extent = {{20, -20}, {-20, 20}}, rotation = 270)));
    parameter SI.Time ffStartTime = 0 "ff start time"  annotation(
    Dialog(enable = withFeedForward));
  // SOC-dependent power derating
  parameter Real SOCfade = 0.02 "SOC interval for smooth power derating";
  Real xCharge;
  Real xDischarge;
  Real gCharge;
  Real gDischarge;
  
  protected
  Modelica.Blocks.Interfaces.RealInput P_ff_internal;
equation
// Frequency feedback controller
  connect(P_ff, P_ff_internal);
  if not withFeedForward then
    P_ff_internal = 0;
  end if;
  Pref = Kf*(fnom-f)+(if time >= ffStartTime then P_ff_internal else 0);
  
// BESS power capacity limit
  Pcmd = max(-Pmax, min(Pmax, Pref));
// First-order power response
  //der(Pfiltered) = (Pcmd - Pfiltered)/tau;
  Pfiltered = Pcmd;
// Normalized distance from SOC limits
  xCharge = max(0, min(1,(SOCmax - SOC_state)/SOCfade));
  xDischarge = max(0, min(1,(SOC_state - SOCmin)/SOCfade));
// Smoothstep functions
  gCharge = xCharge^2*(3-2*xCharge);
  gDischarge = xDischarge^2*(3-2*xDischarge);
// SOC-dependent output derating
  P = if Pfiltered >= 0 then
        Pfiltered*gDischarge
      else
        Pfiltered*gCharge;
// SOC dynamics
  der(SOC_state) = if P >= 0 then -P/(etaDis*Emax) else -etaCh*P/Emax;
// SOC output
  SOC = SOC_state;
  annotation(
    Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(lineColor = {50, 80, 110}, fillColor = {235, 242, 248}, fillPattern = FillPattern.Solid, extent = {{-100, -100}, {100, 100}}, radius = 10), Rectangle(lineColor = {30, 110, 90}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-43, -30}, {43, 30}}), Rectangle(lineColor = {30, 110, 90}, fillColor = {30, 110, 90}, fillPattern = FillPattern.Solid, extent = {{43, -12}, {51, 12}}), Rectangle(lineColor = {30, 150, 110}, fillColor = {30, 150, 110}, fillPattern = FillPattern.Solid, extent = {{-36, -23}, {5, 23}}), Text(origin = {2, -74},extent = {{-90, -55}, {90, -35}}, textString = "%name"), Text(extent = {{-100, 5}, {-65, 30}}, textString = "f"), Text(extent = {{65, 5}, {100, 30}}, textString = "P"), Text(extent = {{15, 72}, {85, 95}}, textString = "SOC")}),
    Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
    Documentation(info = "<html>
<p>SOC fade is to prevent abrupt BESS power and accordingly grid response changes by giving smoothed BESS power reduction. Response time of BESS is negligible for now (tau is commented out)</p>
</html>"));
end BESS_Simple;