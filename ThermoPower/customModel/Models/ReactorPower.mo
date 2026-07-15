within ThermoPower.customModel.Models;

model ReactorPower "Point Kinetics Equations with 6 delayed neutron groups and temperature feedback"
  // ============================================================
  //  Power parameters
  // ============================================================
  parameter SI.Power P0 "Nominal (initial) thermal power [W]";
  parameter Boolean usePKE = false "Enable point kinetics";
  parameter Boolean useTf = false "Enable Fuel temperature feedback" annotation(
    Dialog(enable = usePKE));
  parameter Boolean useTm = false "Enable Moderator temperature feedback" annotation(
    Dialog(enable = usePKE));
  parameter Boolean useTc = false "Enable Coolant temperature feedback" annotation(
    Dialog(enable = usePKE));
  parameter Boolean useRhoExt = false "Enable external reactivity insertion" annotation(
    Dialog(enable = usePKE));
  // ============================================================
  //  Neutron kinetics parameters
  // ============================================================
  parameter Real Lambda = 0.0003712 "Prompt neutron generation time [s]" annotation(
    Dialog(enable = usePKE));
  parameter Real beta_total = 0.00657 "Total delayed neutron fraction" annotation(Dialog(enable = usePKE));
  parameter Real beta[6] = {0.00020, 0.00113, 0.00138, 0.00244, 0.00103, 0.00039} "Delayed neutron fractions per group" annotation(
    Dialog(enable = usePKE));
  parameter Real lambda[6] = {0.01243983, 0.03050824, 0.11143845, 0.30136834, 1.13630685, 3.01368339} "Delayed neutron precursor decay constants [1/s]" annotation(
    Dialog(enable = usePKE));
  // ============================================================
  //  Temperature feedback parameters
  // ============================================================
  parameter Real alpha_f = 0 "Fuel temperature reactivity coefficient [dk/k/K]" annotation(
    Dialog(enable = usePKE and useTf));
  parameter Real alpha_m = 0 "Moderator temperature reactivity coefficient [dk/k/K]" annotation(
    Dialog(enable = usePKE and useTm));
  parameter Real alpha_c = 0 "Coolant temperature reactivity coefficient [dk/k/K]" annotation(
    Dialog(enable = usePKE and useTc));
  parameter SI.Temperature Tf0(displayUnit="K") = 0 "Reference fuel temperature [K]" annotation(
    Dialog(enable = usePKE and useTf));
  parameter SI.Temperature Tm0(displayUnit="K") = 0 "Reference moderator temperature [K]" annotation(
    Dialog(enable = usePKE and useTm));
  parameter SI.Temperature Tc0(displayUnit="K") = 0 "Reference coolant temperature [K]" annotation(
    Dialog(enable = usePKE and useTc));
  // ============================================================
  //  Initialisation
  // ============================================================
  parameter Choices.Init.Options initOpt = system.initOpt "Initialisation option" annotation(
    Dialog(tab = "Initialisation"));
  // ============================================================
  //  Variables
  // ============================================================
  Real n(start = 1) "Relative neutron density (n/n0) [-]";
  Real C[6](start = {beta[i]/(Lambda*lambda[i]) for i in 1:6}) "Delayed neutron precursor concentrations (relative)";
  SI.Power P "Absolute thermal power [W]";
  Real rho "Total reactivity [dk/k]";
  Real rho_feedback "Temperature feedback reactivity [dk/k]";
  //Real rho_ext_internal "Internal copy of external reactivity";
  outer ThermoPower.System system "System wide properties";
  // ============================================================
  //  Connectors - Inputs
  // ============================================================
  Modelica.Blocks.Interfaces.RealInput rho_ext if usePKE and useRhoExt "External reactivity input [dk/k]" annotation(
    Placement(transformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-90, 0}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Interfaces.RealInput Tf if usePKE and useTf "Fuel temperature input [K]" annotation(
    Placement(transformation(origin = {-60, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {-60, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Interfaces.RealInput Tm if usePKE and useTm "Moderator temperature input [K]" annotation(
    Placement(transformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {0, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Interfaces.RealInput Tc if usePKE and useTc "Coolant temperature input [K]" annotation(
    Placement(transformation(origin = {60, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90), iconTransformation(origin = {60, -90}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  // ============================================================
  //  Connectors - Outputs
  // ============================================================
  Modelica.Blocks.Interfaces.RealOutput Power "Absolute thermal power output [W]" annotation(
    Placement(transformation(extent = {{90, -10}, {110, 10}}), iconTransformation(origin = {-10, 0}, extent = {{90, -10}, {110, 10}})));
protected
  Real Tf_internal;
  Real Tm_internal;
  Real Tc_internal;
  Real rho_ext_internal;
public
equation
// ============================================================
//  Power calculation
// ============================================================
  if useTf then
    Tf_internal = Tf;
  else
    Tf_internal = Tf0;
  end if;

  if useTm then
    Tm_internal = Tm;
  else
    Tm_internal = Tm0;
  end if;

  if useTc then
    Tc_internal = Tc;
  else
    Tc_internal = Tc0;
  end if;
  
  if useRhoExt then
    rho_ext_internal = rho_ext;
  else
    rho_ext_internal = 0;
  end if;

  if usePKE then
// reactivity calculation
    rho_feedback = alpha_f*(Tf_internal - Tf0) + alpha_m*(Tm_internal - Tm0) + alpha_c*(Tc_internal - Tc0);
    rho = rho_ext_internal + rho_feedback;
// PKE calculation
    der(n) = (rho - beta_total)/Lambda*n + sum(lambda[i]*C[i] for i in 1:6);
    for i in 1:6 loop
      der(C[i]) = (beta[i]/Lambda)*n - lambda[i]*C[i];
    end for;
  else
// constant power
    rho_feedback = 0;
    rho = 0;
    n = 1;
    for i in 1:6 loop
      C[i] = beta[i]/(Lambda*lambda[i]);
    end for;
  end if;
// ============================================================
//  Power output
// ============================================================
  P = n*P0;
  Power = P;
// ============================================================
//  Initial conditions
// ============================================================
initial equation
  der(n) = 0;
  for i in 1:6 loop
    C[i] = beta[i]/(Lambda*lambda[i]);
  end for;
  annotation(
    Icon(graphics = {Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-80, 80}, {80, -80}}), Text(textColor = {0, 0, 255}, extent = {{-60, 40}, {60, -40}}, textString = "Power"), Text( origin = {-60, 32},textColor = {191, 95, 0}, extent = {{-20, -80}, {20, -110}}, textString = "Tf"), Text(origin = {0, 32}, textColor = {191, 95, 0}, extent = {{-20, -80}, {20, -110}}, textString = "Tm"), Text(origin = {58, 32}, textColor = {191, 95, 0}, extent = {{-20, -80}, {20, -110}}, textString = "Tc"), Text(origin = {-114, 118}, textColor = {191, 95, 0}, extent = {{-20, -80}, {20, -110}}, textString = "rho_ext")}),
    Documentation(info = "<HTML>
<p>Point Kinetics Equations (PKE) model with 6 delayed neutron groups.</p>

<p><b>Features:</b></p>
<ul>
<li>6-group delayed neutron precursor equations</li>
<li>External reactivity input via RealInput (can be 0)</li>
<li>Optional fuel/coolant temperature feedback:
  rho_fb = alpha_f*(Tf - Tf0) + alpha_c*(Tc - Tc0)</li>
<li>Absolute (W) and relative power outputs</li>
</ul>

<p><b>Connectors:</b></p>
<ul>
<li><tt>rho_ext</tt>: external reactivity [dk/k]</li>
<li><tt>Tf</tt>: fuel temperature [K] (conditional)</li>
<li><tt>Tc</tt>: coolant temperature [K] (conditional)</li>
<li><tt>Power</tt>: absolute thermal power [W]</li>
<li><tt>relPower</tt>: relative power [-]</li>
</ul>
</HTML>"),
    experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-06, Interval = 0.002),
    Diagram(graphics));
end ReactorPower;